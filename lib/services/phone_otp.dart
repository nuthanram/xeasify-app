import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/config.dart';

class PhoneOtpException implements Exception {
  final String message;
  const PhoneOtpException(this.message);

  @override
  String toString() => message;
}

/// Phone OTP through Firebase Auth: Firebase sends the SMS and checks the code; the app
/// keeps only the resulting Firebase ID token, which the backend verifies
/// (POST /accounts/creator/verify-phone/). The Firebase session itself is signed out
/// straight away; the Xeasify login stays the JWT.
class PhoneOtp {
  static bool get isConfigured =>
      kFirebaseApiKey.isNotEmpty && kFirebaseAppId.isNotEmpty && kFirebaseProjectId.isNotEmpty;

  ConfirmationResult? _webConfirmation;
  String? _verificationId;
  int? _resendToken;
  PhoneAuthCredential? _autoCredential;

  static Future<FirebaseAuth> _auth() async {
    if (!isConfigured) {
      throw const PhoneOtpException('Phone verification is not configured in this build.');
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: kFirebaseApiKey,
          appId: kFirebaseAppId,
          projectId: kFirebaseProjectId,
          messagingSenderId: kFirebaseMessagingSenderId,
          authDomain: kFirebaseAuthDomain.isEmpty ? '$kFirebaseProjectId.firebaseapp.com' : kFirebaseAuthDomain,
        ),
      );
    }
    return FirebaseAuth.instance;
  }

  /// Sends an SMS code to [phone] (E.164, e.g. +919812345678). On the web Firebase runs
  /// an invisible reCAPTCHA first; on Android the code may be read automatically.
  Future<void> sendCode(String phone) async {
    final auth = await _auth();
    _autoCredential = null;
    try {
      if (kIsWeb) {
        _webConfirmation = await auth.signInWithPhoneNumber(phone);
        return;
      }
      final sent = Completer<void>();
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) {
          _autoCredential = credential;
          if (!sent.isCompleted) sent.complete();
        },
        verificationFailed: (e) {
          if (!sent.isCompleted) sent.completeError(friendlyError(e));
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!sent.isCompleted) sent.complete();
        },
        codeAutoRetrievalTimeout: (verificationId) => _verificationId = verificationId,
      );
      await sent.future;
    } on FirebaseAuthException catch (e) {
      throw friendlyError(e);
    }
  }

  /// Checks [code] with Firebase and returns the Firebase ID token for the backend.
  Future<String> confirm(String code) async {
    final auth = await _auth();
    try {
      final UserCredential result;
      if (kIsWeb) {
        final confirmation = _webConfirmation;
        if (confirmation == null) throw const PhoneOtpException('Request a code first.');
        result = await confirmation.confirm(code);
      } else {
        final verificationId = _verificationId;
        final credential = _autoCredential ??
            (verificationId == null
                ? null
                : PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code));
        if (credential == null) throw const PhoneOtpException('Request a code first.');
        result = await auth.signInWithCredential(credential);
      }
      final token = await result.user?.getIdToken();
      if (token == null) throw const PhoneOtpException('Firebase did not return a sign-in token.');
      return token;
    } on FirebaseAuthException catch (e) {
      throw friendlyError(e);
    } finally {
      if (auth.currentUser != null) await auth.signOut();
    }
  }

  @visibleForTesting
  static PhoneOtpException friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return const PhoneOtpException('That phone number is not valid. Include the country code, e.g. +91.');
      case 'invalid-verification-code':
        return const PhoneOtpException('Incorrect code. Check the SMS and try again.');
      case 'session-expired':
      case 'code-expired':
        return const PhoneOtpException('The code has expired. Request a new one.');
      case 'too-many-requests':
        return const PhoneOtpException('Too many attempts from this device. Try again later.');
      case 'quota-exceeded':
        return const PhoneOtpException('The SMS limit for today has been reached. Try again tomorrow.');
      case 'operation-not-allowed':
      case 'billing-not-enabled':
        return const PhoneOtpException('Phone sign-in is not enabled for this app yet.');
      case 'captcha-check-failed':
        return const PhoneOtpException('The security check failed. Reload the page and try again.');
      default:
        return PhoneOtpException(e.message ?? 'Phone verification failed (${e.code}).');
    }
  }

  /// Turns what the user typed into E.164: spaces and dashes dropped, a bare 10-digit
  /// Indian number gets +91. Returns null when it still doesn't look like a phone number.
  static String? normalize(String input) {
    var phone = input.replaceAll(RegExp(r'[\s\-()]'), '');
    if (RegExp(r'^\d{10}$').hasMatch(phone)) phone = '+91$phone';
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone) ? phone : null;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeasify_app/services/phone_otp.dart';

void main() {
  group('normalize', () {
    test('a bare 10-digit Indian number gets +91', () {
      expect(PhoneOtp.normalize('98123 45678'), '+919812345678');
    });

    test('spaces, dashes and brackets are dropped', () {
      expect(PhoneOtp.normalize('+91 (981) 234-5678'), '+919812345678');
      expect(PhoneOtp.normalize('+1 415 555 0100'), '+14155550100');
    });

    test('anything that is not a phone number is refused', () {
      for (final bad in ['', '+91 ', '12345', '+0123456789', 'phone', '+91981234567890123']) {
        expect(PhoneOtp.normalize(bad), isNull, reason: bad);
      }
    });
  });

  test('Firebase errors become messages a creator can act on', () {
    String message(String code) => PhoneOtp.friendlyError(FirebaseAuthException(code: code)).message;
    expect(message('invalid-verification-code'), contains('Incorrect code'));
    expect(message('session-expired'), contains('expired'));
    expect(message('too-many-requests'), contains('Too many attempts'));
    expect(message('operation-not-allowed'), contains('not enabled'));
    expect(PhoneOtp.friendlyError(FirebaseAuthException(code: 'odd', message: 'Raw')).message, 'Raw');
  });

  test('without Firebase settings the build reports phone verification as off', () {
    expect(PhoneOtp.isConfigured, isFalse);
  });
}

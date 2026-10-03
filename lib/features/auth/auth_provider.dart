import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/secure_storage.dart';
import 'auth_repository.dart';

class AuthState {
  final String? accessToken;
  final String? role;
  final String? userId;
  // Monotonic creator onboarding state: social_linked → metrics_granted → verified
  final String? signupState;

  const AuthState({this.accessToken, this.role, this.userId, this.signupState});

  bool get isAuthenticated => accessToken != null;

  /// Creators must reach 'verified' before they can see campaigns.
  bool get isCreatorVerified => signupState == 'verified';

  AuthState copyWith({
    String? accessToken,
    String? role,
    String? userId,
    String? signupState,
  }) =>
      AuthState(
        accessToken: accessToken ?? this.accessToken,
        role: role ?? this.role,
        userId: userId ?? this.userId,
        signupState: signupState ?? this.signupState,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _restore();
  }

  Future<void> _restore() async {
    final token = await SecureStorage.getAccessToken();
    final role = await SecureStorage.getRole();
    final userId = await SecureStorage.getUserId();
    final signupState = await SecureStorage.getSignupState();
    if (token != null) {
      state = AuthState(
        accessToken: token,
        role: role,
        userId: userId,
        signupState: signupState,
      );
    }
  }

  Future<void> login(String email, String password) async {
    final result = await _repo.login(email, password);
    await SecureStorage.saveAccessToken(result['access']);
    await SecureStorage.saveRefreshToken(result['refresh']);
    await SecureStorage.saveRole(result['role']);
    await SecureStorage.saveUserId(result['user_id']);
    state = AuthState(
      accessToken: result['access'],
      role: result['role'],
      userId: result['user_id'],
    );
  }

  Future<void> socialLogin(String provider, String accessToken) async {
    final result = await _repo.socialAuth(
      provider: provider,
      accessToken: accessToken,
    );
    await SecureStorage.saveAccessToken(result['access']);
    await SecureStorage.saveRefreshToken(result['refresh']);
    await SecureStorage.saveRole(result['role']);
    await SecureStorage.saveUserId(result['user_id']);
    await SecureStorage.saveSignupState(result['signup_state'] as String? ?? '');
    state = AuthState(
      accessToken: result['access'],
      role: result['role'],
      userId: result['user_id'],
      signupState: result['signup_state'] as String?,
    );
  }

  /// Called by the marketplace screen after fetching /me/ to sync onboarding state.
  Future<void> updateSignupState(String signupState) async {
    await SecureStorage.saveSignupState(signupState);
    state = state.copyWith(signupState: signupState);
  }

  Future<void> logout() async {
    await _repo.logout();
    await SecureStorage.clear();
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

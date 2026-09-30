import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/secure_storage.dart';
import 'auth_repository.dart';

class AuthState {
  final String? accessToken;
  final String? role;
  final String? userId;

  const AuthState({this.accessToken, this.role, this.userId});

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({String? accessToken, String? role, String? userId}) => AuthState(
    accessToken: accessToken ?? this.accessToken,
    role: role ?? this.role,
    userId: userId ?? this.userId,
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
    if (token != null) state = AuthState(accessToken: token, role: role, userId: userId);
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

import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<UserModel> _users = [];
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  String? register(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos.';
    }
    if (!email.contains('@')) {
      return 'E-mail inválido.';
    }
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    final exists = _users.any((u) => u.email == email);
    if (exists) {
      return 'Este e-mail já está cadastrado.';
    }
    final name = email.split('@').first;
    _users.add(UserModel(email: email, password: password, name: name));
    return null; // success
  }

  String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos.';
    }
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      return null; // success
    } catch (_) {
      return 'E-mail ou senha incorretos.';
    }
  }

  void logout() {
    _currentUser = null;
  }
}

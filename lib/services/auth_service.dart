import '../models/user_model.dart';

class AuthService {
  static const String hardcodeEmail = 'admin@amazesys.com';
  static const String hardcodePassword = '123456';

  static List<User> registeredUsers = [
    User(
      id: '1',
      email: hardcodeEmail,
      name: 'Admin Amazesys',
    ),
  ];

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == hardcodeEmail && password == hardcodePassword) {
      return registeredUsers.first;
    }
    
    for (var user in registeredUsers) {
      if (user.email == email) {
        return user;
      }
    }
    
    return null;
  }

  Future<bool> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    
    bool emailExists = registeredUsers.any((user) => user.email == email);
    if (emailExists) {
      return false;
    }
    
    User newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );
    
    registeredUsers.add(newUser);
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
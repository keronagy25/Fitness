import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Register new user
  Future<bool> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if email already exists
    String? existingEmail = prefs.getString('user_email');
    if (existingEmail == email) {
      return false; // User already exists
    }

    // Save user data
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    return true;
  }

  // Login user
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString('user_email');
    String? savedPassword = prefs.getString('user_password');

    if (savedEmail == email && savedPassword == password) {
      await prefs.setBool('is_logged_in', true);
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}
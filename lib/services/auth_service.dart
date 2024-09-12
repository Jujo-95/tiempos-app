import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get instance => _instance;
  bool isAuthenticated = false;

  Future<void> checkAuthentication() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String authToken = prefs.getString('authToken')!;
    if (authToken != null) {
      isAuthenticated = true;
    }
  }

  void login(String authToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', authToken);

    isAuthenticated = true;
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    isAuthenticated = false;
  }

  signInWithEmailAndPassword(email, password) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    FirebasePaths.instance.currentUserId = userCredential.user!.email!;
  }
}

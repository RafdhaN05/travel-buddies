import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // 1. Create an instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. SIGN UP function
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Sign Up Error: ${e.toString()}");
      return null;
    }
  }

  // 3. LOGIN function
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: ${e.toString()}");
      return null;
    }
  }

  // 4. LOGOUT function
  Future<void> logout() async {
    await _auth.signOut();
  }
}
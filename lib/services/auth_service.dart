import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<bool> register(String name, String email, String password) async {
    try {
      print('Starting registration...');

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Auth success! UID: ${cred.user!.uid}');

      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'weight': '',
        'height': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Firestore write success!');
      return true;

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') return false;
      rethrow;
    } catch (e, stack) {
      print('Unknown error: $e');
      print('Stack: $stack');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}
import 'package:firebase_auth/firebase_auth.dart' show User;

abstract class IAuthService {
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<User?> authStateChanges();

  User? get currentUser;
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Updated Sign Up: Sends Verification Email immediately
  Future<String?> signUp({required String email, required String password, required String name}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Create user profile in Firestore
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // SEND VERIFICATION EMAIL
        await user.sendEmailVerification();
        return null;
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Updated Sign In: Checks for Verification
  Future<String?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        if (!result.user!.emailVerified) {
          await _auth.signOut(); // Kick them out
          return "Please verify your email address. Check your inbox.";
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
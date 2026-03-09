import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({required String email, required String password, required String name}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // 1. Update Firebase Auth Profile Name (CRUCIAL for user.displayName)
        await user.updateDisplayName(name);
        await user.reload();

        // 2. Create user profile in Firestore
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Send Verification Email
        await user.sendEmailVerification();
        return null;
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        if (!result.user!.emailVerified) {
          await _auth.signOut();
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
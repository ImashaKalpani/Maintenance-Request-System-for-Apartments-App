import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();

  // ========== NEW METHODS ADDED ==========

  /// Get the currently logged in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Delete user account with re-authentication
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Re-authenticate the user
        final authCredential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );

        await user.reauthenticateWithCredential(authCredential);

        // Delete user from Firebase Authentication
        await user.delete();

        // Sign out
        await _auth.signOut();
      } catch (e) {
        rethrow; // Pass error to caller
      }
    }
  }

  /// Delete account without re-authentication (for testing/alternative)
  Future<void> deleteAccountWithoutAuth() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
        await _auth.signOut();
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Get current user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get current user's UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}

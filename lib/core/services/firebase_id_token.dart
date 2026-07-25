import 'package:firebase_auth/firebase_auth.dart';

/// Returns the current user's Firebase ID token, or null if signed out.
/// Isolated here so the AI gateway stays transport-focused.
Future<String?> firebaseIdTokenImpl() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return user.getIdToken();
}

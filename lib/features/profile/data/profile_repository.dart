import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_profile.dart';

/// Reads/writes the user profile document and performs server-side data
/// deletion. Demo mode uses [NoopProfileRepository] instead.
abstract class ProfileRepository {
  Future<UserProfile?> load(String uid);
  Future<void> ensureProfile(UserProfile profile);
  Future<void> update(UserProfile profile);

  /// Deletes the profile document and all owned subcollections. Storage files
  /// are handled by the diagnosis repository during data deletion.
  Future<void> deleteUserDocument(String uid);
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<UserProfile?> load(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(uid, snap.data() ?? {});
  }

  @override
  Future<void> ensureProfile(UserProfile profile) async {
    final snap = await _doc(profile.uid).get();
    if (snap.exists) return;
    await _doc(profile.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(UserProfile profile) async {
    await _doc(profile.uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteUserDocument(String uid) async {
    // Delete known subcollections in batches, then the profile document.
    for (final String sub in const ['reminders']) {
      final snap = await _doc(uid).collection(sub).get();
      final WriteBatch batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    await _doc(uid).delete();
  }
}

/// No-op used in demo mode (no Firestore).
class NoopProfileRepository implements ProfileRepository {
  const NoopProfileRepository();

  @override
  Future<UserProfile?> load(String uid) async => null;
  @override
  Future<void> ensureProfile(UserProfile profile) async {}
  @override
  Future<void> update(UserProfile profile) async {}
  @override
  Future<void> deleteUserDocument(String uid) async {}
}

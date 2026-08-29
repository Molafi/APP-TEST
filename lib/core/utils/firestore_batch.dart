import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore caps a single [WriteBatch] at 500 operations. Deleting a
/// collection with more documents than that in one batch throws, so these
/// helpers split the work into commit-sized chunks.
class FirestoreBatch {
  const FirestoreBatch._();

  /// Maximum number of operations Firestore allows in a single [WriteBatch].
  static const int maxOpsPerBatch = 500;

  /// Splits [items] into consecutive chunks of at most [size] elements.
  ///
  /// Pure and side-effect free so it can be unit-tested without Firestore.
  static List<List<T>> chunk<T>(List<T> items, [int size = maxOpsPerBatch]) {
    assert(size > 0, 'chunk size must be positive');
    if (items.isEmpty) return <List<T>>[];
    final List<List<T>> chunks = <List<T>>[];
    for (int i = 0; i < items.length; i += size) {
      chunks.add(
        items.sublist(i, i + size > items.length ? items.length : i + size),
      );
    }
    return chunks;
  }

  /// Deletes every reference in [refs] using as many [WriteBatch] commits as
  /// needed to stay within Firestore's [maxOpsPerBatch] limit. Each chunk is
  /// committed before the next begins.
  static Future<void> deleteAll(
    FirebaseFirestore db,
    List<DocumentReference<Object?>> refs,
  ) async {
    for (final List<DocumentReference<Object?>> group in chunk(refs)) {
      final WriteBatch batch = db.batch();
      for (final DocumentReference<Object?> ref in group) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }
}

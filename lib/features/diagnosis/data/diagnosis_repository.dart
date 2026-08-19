import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/local_cache_service.dart';
import '../domain/diagnosis_model.dart';

/// Persistence for saved diagnoses plus optional image retention. Images are
/// only uploaded when the user has enabled retention; otherwise no image bytes
/// leave the analysis flow.
abstract class DiagnosisRepository {
  Future<List<Diagnosis>> load();

  /// Saves a diagnosis. When [imageBytes] is provided AND retention is enabled,
  /// the compressed image is stored and referenced; otherwise it is discarded.
  Future<Diagnosis> save(
    Diagnosis diagnosis, {
    Uint8List? imageBytes,
    required bool retainImage,
  });

  Future<void> delete(String id);
  Future<void> deleteAll();
}

/// Local (SharedPreferences) store used in demo/offline. Never stores raw image
/// bytes — only the structured result — honouring the "no base64 in storage"
/// rule.
class LocalDiagnosisRepository implements DiagnosisRepository {
  LocalDiagnosisRepository(this._cache);

  static const String _key = 'diagnoses_local';
  final LocalCacheService _cache;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Diagnosis>> load() async {
    final String? raw = _cache.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => Diagnosis.fromStored(m['id'] as String? ?? '', m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<Diagnosis> save(
    Diagnosis diagnosis, {
    Uint8List? imageBytes,
    required bool retainImage,
  }) async {
    final String id = diagnosis.id ?? _uuid.v4();
    final Diagnosis stored = diagnosis.withMeta(
      id: id,
      createdAt: DateTime.now(),
    );
    final List<Diagnosis> all = await load();
    all.insert(0, stored);
    await _persist(all);
    return stored;
  }

  @override
  Future<void> delete(String id) async {
    final List<Diagnosis> all = await load();
    all.removeWhere((d) => d.id == id);
    await _persist(all);
  }

  @override
  Future<void> deleteAll() => _cache.remove(_key);

  Future<void> _persist(List<Diagnosis> all) async {
    final List<Map<String, dynamic>> list = all
        .map(
          (d) => {
            'id': d.id,
            ...d.toMap(),
            'createdAt': (d.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
          },
        )
        .toList();
    await _cache.setString(_key, jsonEncode(list));
  }
}

/// Firestore + Storage store: users/{uid}/diagnoses/{id}. Compressed images go
/// to Storage under the same user path, only when retention is enabled.
class FirestoreDiagnosisRepository implements DiagnosisRepository {
  FirestoreDiagnosisRepository({
    required this.uid,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final String uid;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('diagnoses');

  @override
  Future<List<Diagnosis>> load() async {
    final snap = await _col
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => Diagnosis.fromStored(d.id, d.data())).toList();
  }

  @override
  Future<Diagnosis> save(
    Diagnosis diagnosis, {
    Uint8List? imageBytes,
    required bool retainImage,
  }) async {
    final String id = diagnosis.id ?? _uuid.v4();
    String? imageRef;

    if (retainImage && imageBytes != null) {
      final Reference ref = _storage.ref().child(
        'users/$uid/diagnoses/$id.jpg',
      );
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageRef = ref.fullPath;
    }

    final Diagnosis stored = diagnosis.withMeta(
      id: id,
      imageReference: imageRef,
    );
    await _col.doc(id).set({
      'diagnosis': diagnosis.toMap(),
      'imageReference': imageRef,
      'locationContext': diagnosis.locationContext,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return stored;
  }

  @override
  Future<void> delete(String id) async {
    // Best-effort image cleanup, then the document.
    try {
      await _storage.ref().child('users/$uid/diagnoses/$id.jpg').delete();
    } catch (_) {}
    await _col.doc(id).delete();
  }

  @override
  Future<void> deleteAll() async {
    final snap = await _col.get();
    final WriteBatch batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

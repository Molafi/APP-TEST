import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/local_cache_service.dart';
import '../../../core/utils/firestore_batch.dart';
import '../domain/soil_report_model.dart';

/// Persistence for saved soil reports plus optional image retention. Images are
/// only uploaded when the user has enabled retention; otherwise no image bytes
/// leave the analysis flow.
abstract class SoilReportRepository {
  Future<List<SoilReport>> load();

  /// Saves a report. When [imageBytes] is provided AND retention is enabled,
  /// the compressed image is stored and referenced; otherwise it is discarded.
  Future<SoilReport> save(
    SoilReport report, {
    Uint8List? imageBytes,
    required bool retainImage,
  });

  Future<void> delete(String id);
  Future<void> deleteAll();
}

/// Local (SharedPreferences) store used in demo/offline. Never stores raw image
/// bytes — only the structured result — honouring the "no base64 in storage"
/// rule.
class LocalSoilReportRepository implements SoilReportRepository {
  LocalSoilReportRepository(this._cache);

  static const String _key = 'soil_reports_local';
  final LocalCacheService _cache;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<SoilReport>> load() async {
    final String? raw = _cache.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => SoilReport.fromStored(m['id'] as String? ?? '', m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<SoilReport> save(
    SoilReport report, {
    Uint8List? imageBytes,
    required bool retainImage,
  }) async {
    final String id = report.id ?? _uuid.v4();
    final SoilReport stored = report.withMeta(
      id: id,
      createdAt: DateTime.now(),
    );
    final List<SoilReport> all = await load();
    all.insert(0, stored);
    await _persist(all);
    return stored;
  }

  @override
  Future<void> delete(String id) async {
    final List<SoilReport> all = await load();
    all.removeWhere((d) => d.id == id);
    await _persist(all);
  }

  @override
  Future<void> deleteAll() => _cache.remove(_key);

  Future<void> _persist(List<SoilReport> all) async {
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

/// Firestore + Storage store: users/{uid}/soilReports/{id}. Compressed images
/// go to Storage under the same user path, only when retention is enabled.
class FirestoreSoilReportRepository implements SoilReportRepository {
  FirestoreSoilReportRepository({
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
      _db.collection('users').doc(uid).collection('soilReports');

  @override
  Future<List<SoilReport>> load() async {
    final snap = await _col
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => SoilReport.fromStored(d.id, d.data())).toList();
  }

  @override
  Future<SoilReport> save(
    SoilReport report, {
    Uint8List? imageBytes,
    required bool retainImage,
  }) async {
    final String id = report.id ?? _uuid.v4();
    String? imageRef;

    if (retainImage && imageBytes != null) {
      final Reference ref = _storage.ref().child(
        'users/$uid/soilReports/$id.jpg',
      );
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageRef = ref.fullPath;
    }

    final SoilReport stored = report.withMeta(id: id, imageReference: imageRef);
    await _col.doc(id).set({
      'report': report.toMap(),
      'imageReference': imageRef,
      'locationContext': report.locationContext,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return stored;
  }

  @override
  Future<void> delete(String id) async {
    // Best-effort image cleanup, then the document.
    try {
      await _storage.ref().child('users/$uid/soilReports/$id.jpg').delete();
    } catch (_) {}
    await _col.doc(id).delete();
  }

  @override
  Future<void> deleteAll() async {
    final snap = await _col.get();
    await FirestoreBatch.deleteAll(
      _db,
      snap.docs.map((doc) => doc.reference).toList(),
    );
  }
}

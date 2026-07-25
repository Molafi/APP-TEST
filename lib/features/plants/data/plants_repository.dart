import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/local_cache_service.dart';
import '../domain/plant_model.dart';

/// Persistence for the "My Plants" journal.
abstract class PlantsRepository {
  Future<List<Plant>> load();
  Future<void> upsert(Plant plant);
  Future<void> delete(String id);
  Future<void> deleteAll();
}

/// SharedPreferences-backed store used in demo mode and offline.
class LocalPlantsRepository implements PlantsRepository {
  LocalPlantsRepository(this._cache);

  static const String _key = 'plants_local';
  final LocalCacheService _cache;

  @override
  Future<List<Plant>> load() async =>
      Plant.decodeList(_cache.getString(_key));

  @override
  Future<void> upsert(Plant plant) async {
    final List<Plant> all = await load();
    final int i = all.indexWhere((p) => p.id == plant.id);
    if (i >= 0) {
      all[i] = plant;
    } else {
      all.insert(0, plant);
    }
    await _cache.setString(_key, Plant.encodeList(all));
  }

  @override
  Future<void> delete(String id) async {
    final List<Plant> all = await load();
    all.removeWhere((p) => p.id == id);
    await _cache.setString(_key, Plant.encodeList(all));
  }

  @override
  Future<void> deleteAll() => _cache.remove(_key);
}

/// Firestore-backed store: users/{uid}/plants/{id}.
class FirestorePlantsRepository implements PlantsRepository {
  FirestorePlantsRepository({required this.uid, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('plants');

  @override
  Future<List<Plant>> load() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => Plant.fromMap(d.data())).toList();
  }

  @override
  Future<void> upsert(Plant plant) async {
    await _col.doc(plant.id).set({
      ...plant.toMap(),
      'createdAt': plant.createdAt == null
          ? FieldValue.serverTimestamp()
          : plant.createdAt!.toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<void> deleteAll() async {
    final snap = await _col.get();
    final WriteBatch batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

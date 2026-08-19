import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/environment.dart';
import '../../../core/services/local_cache_service.dart';
import '../../auth/application/auth_provider.dart';
import '../data/plants_repository.dart';
import '../domain/plant_model.dart';

final plantsRepositoryProvider = Provider<PlantsRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (!Environment.isDemo && user != null) {
    return FirestorePlantsRepository(uid: user.uid);
  }
  return LocalPlantsRepository(ref.watch(localCacheServiceProvider));
});

@immutable
class PlantsState {
  const PlantsState({this.plants = const [], this.isLoading = true});
  final List<Plant> plants;
  final bool isLoading;

  bool get isEmpty => plants.isEmpty;

  PlantsState copyWith({List<Plant>? plants, bool? isLoading}) => PlantsState(
    plants: plants ?? this.plants,
    isLoading: isLoading ?? this.isLoading,
  );
}

class PlantsController extends StateNotifier<PlantsState> {
  PlantsController(this._ref) : super(const PlantsState()) {
    _load();
  }

  final Ref _ref;
  final Uuid _uuid = const Uuid();

  PlantsRepository get _repo => _ref.read(plantsRepositoryProvider);

  Future<void> _load() async {
    try {
      final List<Plant> plants = await _repo.load();
      if (!mounted) return;
      state = PlantsState(plants: plants, isLoading: false);
    } catch (_) {
      if (!mounted) return;
      state = const PlantsState(plants: [], isLoading: false);
    }
  }

  Future<Plant> addOrUpdate({
    Plant? existing,
    required String name,
    String? species,
    required PlantPlace place,
    String? notes,
    int? wateringIntervalDays,
  }) async {
    final Plant plant =
        existing?.copyWith(
          name: name,
          species: species,
          place: place,
          notes: notes,
          wateringIntervalDays: wateringIntervalDays,
        ) ??
        Plant(
          id: _uuid.v4(),
          name: name,
          species: species,
          place: place,
          notes: notes,
          wateringIntervalDays: wateringIntervalDays,
          createdAt: DateTime.now(),
        );
    await _repo.upsert(plant);
    _replaceInState(plant);
    return plant;
  }

  Future<void> markWatered(Plant plant) async {
    final Plant updated = plant.copyWith(lastWateredAt: DateTime.now());
    await _repo.upsert(updated);
    _replaceInState(updated);
  }

  Future<void> remove(Plant plant) async {
    await _repo.delete(plant.id);
    state = state.copyWith(
      plants: state.plants.where((p) => p.id != plant.id).toList(),
    );
  }

  void _replaceInState(Plant plant) {
    final List<Plant> list = [...state.plants];
    final int i = list.indexWhere((p) => p.id == plant.id);
    if (i >= 0) {
      list[i] = plant;
    } else {
      list.insert(0, plant);
    }
    state = state.copyWith(plants: list);
  }
}

final plantsControllerProvider =
    StateNotifierProvider<PlantsController, PlantsState>((ref) {
      return PlantsController(ref);
    });

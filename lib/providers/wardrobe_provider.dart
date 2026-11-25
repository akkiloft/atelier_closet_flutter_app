import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

const _uuid = Uuid();

class WardrobeNotifier extends StateNotifier<List<ClothingItem>> {
  final Box<String> _box;

  WardrobeNotifier(this._box) : super([]) {
    _loadInitialData();
  }

  void _loadInitialData() {
    if (_box.isEmpty) {
      final samples = _seedSampleWardrobe();
      _box.putAll({for (final item in samples) item.id: item.toJson()});
      state = samples;
    } else {
      state = _box.values.map((json) => ClothingItem.fromJson(json)).toList();
    }
  }

  Future<void> addItem(ClothingItem item) async {
    await _box.put(item.id, item.toJson());
    state = [item, ...state];
  }

  Future<void> incrementWearCount(List<String> itemIds) async {
    final updated = <ClothingItem>[];
    final updates = <String, String>{};
    for (final item in state) {
      if (itemIds.contains(item.id)) {
        final next = item.copyWith(wearCount: item.wearCount + 1);
        updates[next.id] = next.toJson();
        updated.add(next);
      } else {
        updated.add(item);
      }
    }
    if (updates.isNotEmpty) {
      await _box.putAll(updates);
    }
    state = updated;
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  List<ClothingItem> _seedSampleWardrobe() {
    final now = DateTime.now();
    return [
      ClothingItem(
        id: 'sample_1',
        name: 'Boxy Heavyweight Tee',
        imagePath: 'icon:shirt',
        isAsset: true,
        category: ClothingCategory.tops,
        brand: 'Uniqlo U',
        colorHex: '#F5F5F4',
        seasons: ['Summer', 'All-Season'],
        occasions: ['Casual', 'Travel'],
        purchasePrice: 1490,
        purchaseDate: now.subtract(const Duration(days: 120)),
        wearCount: 18,
      ),
      ClothingItem(
        id: 'sample_2',
        name: 'Relaxed Linen Oxford',
        imagePath: 'icon:shirt_formal',
        isAsset: true,
        category: ClothingCategory.tops,
        brand: 'Massimo Dutti',
        colorHex: '#93C5FD',
        seasons: ['Summer', 'Monsoon'],
        occasions: ['Work', 'Smart Casual'],
        purchasePrice: 4200,
        purchaseDate: now.subtract(const Duration(days: 90)),
        wearCount: 11,
      ),
      ClothingItem(
        id: 'sample_3',
        name: 'Pleated Wide Trousers',
        imagePath: 'icon:pants',
        isAsset: true,
        category: ClothingCategory.bottoms,
        brand: 'Zara Studio',
        colorHex: '#27272A',
        seasons: ['All-Season'],
        occasions: ['Work', 'Evening'],
        purchasePrice: 3590,
        purchaseDate: now.subtract(const Duration(days: 150)),
        wearCount: 22,
      ),
      ClothingItem(
        id: 'sample_4',
        name: 'Selvedge Straight Denim',
        imagePath: 'icon:jeans',
        isAsset: true,
        category: ClothingCategory.bottoms,
        brand: 'Levi’s 501',
        colorHex: '#1D4ED8',
        seasons: ['All-Season', 'Winter'],
        occasions: ['Casual', 'Weekend'],
        purchasePrice: 4999,
        purchaseDate: now.subtract(const Duration(days: 200)),
        wearCount: 31,
      ),
      ClothingItem(
        id: 'sample_5',
        name: 'Cropped Workwear Jacket',
        imagePath: 'icon:jacket',
        isAsset: true,
        category: ClothingCategory.outerwear,
        brand: 'Carhartt WIP',
        colorHex: '#92400E',
        seasons: ['Winter', 'Monsoon'],
        occasions: ['Casual', 'Travel'],
        purchasePrice: 8900,
        purchaseDate: now.subtract(const Duration(days: 80)),
        wearCount: 9,
      ),
      ClothingItem(
        id: 'sample_6',
        name: 'Retro Suede Runners',
        imagePath: 'icon:shoes',
        isAsset: true,
        category: ClothingCategory.footwear,
        brand: 'New Balance',
        colorHex: '#78716C',
        seasons: ['All-Season'],
        occasions: ['Casual', 'Travel'],
        purchasePrice: 7999,
        purchaseDate: now.subtract(const Duration(days: 180)),
        wearCount: 40,
      ),
      ClothingItem(
        id: 'sample_7',
        name: 'Chunky Penny Loafers',
        imagePath: 'icon:loafers',
        isAsset: true,
        category: ClothingCategory.footwear,
        brand: 'GH Bass',
        colorHex: '#18181B',
        seasons: ['All-Season'],
        occasions: ['Work', 'Evening'],
        purchasePrice: 9500,
        purchaseDate: now.subtract(const Duration(days: 75)),
        wearCount: 6,
      ),
    ];
  }
}

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, List<ClothingItem>>((ref) {
  final box = Hive.box<String>('wardrobe_box');
  return WardrobeNotifier(box);
});

final selectedCategoryFilterProvider =
    StateProvider<ClothingCategory?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredWardrobeProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(wardrobeProvider);
  final category = ref.watch(selectedCategoryFilterProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return items.where((item) {
    final matchesCat = category == null || item.category == category;
    final matchesQuery = query.isEmpty ||
        item.name.toLowerCase().contains(query) ||
        item.brand.toLowerCase().contains(query) ||
        item.occasions.any((o) => o.toLowerCase().contains(query));
    return matchesCat && matchesQuery;
  }).toList();
});

class OutfitsNotifier extends StateNotifier<List<Outfit>> {
  final Box<String> _box;

  OutfitsNotifier(this._box) : super([]) {
    state = _box.values.map((e) => Outfit.fromJson(e)).toList();
  }

  Future<Outfit> saveOutfit({
    required String name,
    required List<String> itemIds,
    List<CanvasItemPlacement> canvasPlacements = const [],
    String occasion = 'Casual',
  }) async {
    final outfit = Outfit(
      id: _uuid.v4(),
      name: name,
      itemIds: itemIds,
      canvasPlacements: canvasPlacements,
      occasion: occasion,
      createdAt: DateTime.now(),
    );
    await _box.put(outfit.id, outfit.toJson());
    state = [outfit, ...state];
    return outfit;
  }
}

final outfitsProvider =
    StateNotifierProvider<OutfitsNotifier, List<Outfit>>((ref) {
  return OutfitsNotifier(Hive.box<String>('outfits_box'));
});

class CalendarNotifier extends StateNotifier<List<CalendarEntry>> {
  final Box<String> _box;
  final Ref _ref;

  CalendarNotifier(this._box, this._ref) : super([]) {
    state = _box.values.map((e) => CalendarEntry.fromJson(e)).toList();
  }

  Future<void> scheduleOutfit({
    required String dateKey,
    required String outfitId,
    bool logAsWorn = true,
  }) async {
    for (final existing in state.where((e) => e.dateKey == dateKey)) {
      await _box.delete(existing.id);
    }

    final entry = CalendarEntry(
      id: _uuid.v4(),
      dateKey: dateKey,
      outfitId: outfitId,
      isLoggedWorn: logAsWorn,
    );
    await _box.put(entry.id, entry.toJson());
    state = [...state.where((e) => e.dateKey != dateKey), entry];

    if (logAsWorn) {
      final outfit = _ref
          .read(outfitsProvider)
          .where((o) => o.id == outfitId)
          .firstOrNull;
      if (outfit != null) {
        await _ref
            .read(wardrobeProvider.notifier)
            .incrementWearCount(outfit.itemIds);
      }
    }
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, List<CalendarEntry>>((ref) {
  return CalendarNotifier(Hive.box<String>('calendar_box'), ref);
});

class PackingNotifier extends StateNotifier<List<PackingTrip>> {
  final Box<String> _box;

  PackingNotifier(this._box) : super([]) {
    if (_box.isEmpty) {
      const demo = PackingTrip(
        id: 'trip_1',
        title: 'Weekend Getaway',
        destination: 'Coorg / Goa',
        days: 3,
        itemIds: ['sample_1', 'sample_4', 'sample_5', 'sample_6'],
        packedItemIds: ['sample_1', 'sample_6'],
      );
      _box.put(demo.id, demo.toJson());
      state = [demo];
    } else {
      state = _box.values.map((e) => PackingTrip.fromJson(e)).toList();
    }
  }

  Future<void> createTrip(PackingTrip trip) async {
    await _box.put(trip.id, trip.toJson());
    state = [trip, ...state];
  }

  Future<void> togglePacked(String tripId, String itemId) async {
    state = [
      for (final trip in state)
        if (trip.id == tripId)
          () {
            final packed = Set<String>.from(trip.packedItemIds);
            packed.contains(itemId) ? packed.remove(itemId) : packed.add(itemId);
            final updated = trip.copyWith(packedItemIds: packed.toList());
            _box.put(updated.id, updated.toJson());
            return updated;
          }()
        else
          trip
    ];
  }
}

final packingProvider =
    StateNotifierProvider<PackingNotifier, List<PackingTrip>>((ref) {
  return PackingNotifier(Hive.box<String>('packing_box'));
});

import 'dart:convert';

class CanvasItemPlacement {
  final String itemId;
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final int zIndex;

  const CanvasItemPlacement({
    required this.itemId,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
  });

  CanvasItemPlacement copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
    int? zIndex,
  }) {
    return CanvasItemPlacement(
      itemId: itemId,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'x': x,
        'y': y,
        'scale': scale,
        'rotation': rotation,
        'zIndex': zIndex,
      };

  factory CanvasItemPlacement.fromMap(Map<String, dynamic> map) =>
      CanvasItemPlacement(
        itemId: map['itemId'] as String,
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (map['rotation'] as num?)?.toDouble() ?? 0.0,
        zIndex: (map['zIndex'] as int?) ?? 0,
      );
}

class Outfit {
  final String id;
  final String name;
  final List<String> itemIds;
  final List<CanvasItemPlacement> canvasPlacements;
  final String occasion;
  final DateTime createdAt;
  final bool isFavorite;

  const Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    this.canvasPlacements = const [],
    this.occasion = 'Casual',
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'itemIds': itemIds,
        'canvasPlacements': canvasPlacements.map((e) => e.toMap()).toList(),
        'occasion': occasion,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Outfit.fromMap(Map<String, dynamic> map) => Outfit(
        id: map['id'] as String,
        name: map['name'] as String,
        itemIds: List<String>.from(map['itemIds'] ?? []),
        canvasPlacements: (map['canvasPlacements'] as List<dynamic>? ?? [])
            .map((e) => CanvasItemPlacement.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        occasion: (map['occasion'] as String?) ?? 'Casual',
        createdAt: DateTime.parse(map['createdAt'] as String),
        isFavorite: (map['isFavorite'] as bool?) ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory Outfit.fromJson(String source) =>
      Outfit.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class CalendarEntry {
  final String id;
  final String dateKey; // yyyy-MM-dd
  final String outfitId;
  final bool isLoggedWorn;

  const CalendarEntry({
    required this.id,
    required this.dateKey,
    required this.outfitId,
    this.isLoggedWorn = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateKey': dateKey,
        'outfitId': outfitId,
        'isLoggedWorn': isLoggedWorn,
      };

  factory CalendarEntry.fromMap(Map<String, dynamic> map) => CalendarEntry(
        id: map['id'] as String,
        dateKey: map['dateKey'] as String,
        outfitId: map['outfitId'] as String,
        isLoggedWorn: (map['isLoggedWorn'] as bool?) ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory CalendarEntry.fromJson(String source) =>
      CalendarEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class PackingTrip {
  final String id;
  final String title;
  final String destination;
  final int days;
  final List<String> itemIds;
  final List<String> packedItemIds;

  const PackingTrip({
    required this.id,
    required this.title,
    required this.destination,
    required this.days,
    required this.itemIds,
    this.packedItemIds = const [],
  });

  PackingTrip copyWith({
    List<String>? itemIds,
    List<String>? packedItemIds,
  }) =>
      PackingTrip(
        id: id,
        title: title,
        destination: destination,
        days: days,
        itemIds: itemIds ?? this.itemIds,
        packedItemIds: packedItemIds ?? this.packedItemIds,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'destination': destination,
        'days': days,
        'itemIds': itemIds,
        'packedItemIds': packedItemIds,
      };

  factory PackingTrip.fromMap(Map<String, dynamic> map) => PackingTrip(
        id: map['id'] as String,
        title: map['title'] as String,
        destination: map['destination'] as String,
        days: (map['days'] as int?) ?? 3,
        itemIds: List<String>.from(map['itemIds'] ?? []),
        packedItemIds: List<String>.from(map['packedItemIds'] ?? []),
      );

  String toJson() => jsonEncode(toMap());
  factory PackingTrip.fromJson(String source) =>
      PackingTrip.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

import 'dart:convert';

enum ClothingCategory {
  tops('Tops'),
  bottoms('Bottoms'),
  outerwear('Outerwear'),
  footwear('Footwear'),
  accessories('Accessories');

  final String label;
  const ClothingCategory(this.label);

  static ClothingCategory fromString(String value) {
    return ClothingCategory.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => ClothingCategory.tops,
    );
  }
}

class ClothingItem {
  final String id;
  final String name;
  final String imagePath;
  final bool isAsset;
  final ClothingCategory category;
  final String brand;
  final String colorHex;
  final List<String> seasons;
  final List<String> occasions;
  final double purchasePrice;
  final DateTime purchaseDate;
  final int wearCount;
  final bool isWishlist;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isAsset = false,
    required this.category,
    this.brand = '',
    this.colorHex = '#18181B',
    this.seasons = const ['All-Season'],
    this.occasions = const ['Casual'],
    this.purchasePrice = 0.0,
    required this.purchaseDate,
    this.wearCount = 0,
    this.isWishlist = false,
  });

  double get costPerWear {
    if (purchasePrice <= 0) return 0;
    return wearCount == 0 ? purchasePrice : purchasePrice / wearCount;
  }

  ClothingItem copyWith({
    String? name,
    String? imagePath,
    bool? isAsset,
    ClothingCategory? category,
    String? brand,
    String? colorHex,
    List<String>? seasons,
    List<String>? occasions,
    double? purchasePrice,
    DateTime? purchaseDate,
    int? wearCount,
    bool? isWishlist,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      colorHex: colorHex ?? this.colorHex,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      wearCount: wearCount ?? this.wearCount,
      isWishlist: isWishlist ?? this.isWishlist,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'isAsset': isAsset,
        'category': category.name,
        'brand': brand,
        'colorHex': colorHex,
        'seasons': seasons,
        'occasions': occasions,
        'purchasePrice': purchasePrice,
        'purchaseDate': purchaseDate.toIso8601String(),
        'wearCount': wearCount,
        'isWishlist': isWishlist,
      };

  factory ClothingItem.fromMap(Map<String, dynamic> map) => ClothingItem(
        id: map['id'] as String,
        name: map['name'] as String,
        imagePath: map['imagePath'] as String,
        isAsset: (map['isAsset'] as bool?) ?? false,
        category: ClothingCategory.fromString(map['category'] as String),
        brand: (map['brand'] as String?) ?? '',
        colorHex: (map['colorHex'] as String?) ?? '#18181B',
        seasons: List<String>.from(map['seasons'] ?? ['All-Season']),
        occasions: List<String>.from(map['occasions'] ?? ['Casual']),
        purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
        purchaseDate: DateTime.parse(map['purchaseDate'] as String),
        wearCount: (map['wearCount'] as int?) ?? 0,
        isWishlist: (map['isWishlist'] as bool?) ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory ClothingItem.fromJson(String source) =>
      ClothingItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

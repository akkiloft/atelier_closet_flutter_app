import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

class GarmentVisual extends StatelessWidget {
  final ClothingItem item;
  final double size;

  const GarmentVisual({
    super.key,
    required this.item,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    if (!item.isAsset && File(item.imagePath).existsSync()) {
      return Image.file(
        File(item.imagePath),
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    final tint = _parseHex(item.colorHex);
    IconData icon;
    switch (item.category) {
      case ClothingCategory.tops:
        icon = Icons.checkroom_rounded;
        break;
      case ClothingCategory.bottoms:
        icon = Icons.straighten_rounded;
        break;
      case ClothingCategory.outerwear:
        icon = Icons.dry_cleaning_rounded;
        break;
      case ClothingCategory.footwear:
        icon = Icons.ice_skating_outlined;
        break;
      case ClothingCategory.accessories:
        icon = Icons.watch_rounded;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size * 0.46, color: tint),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              item.category.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return const Color(0xFF18181B);
  }
}

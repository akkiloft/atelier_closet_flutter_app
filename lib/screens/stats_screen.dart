import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/garment_visual.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wardrobeProvider);

    final totalPieces = items.length;
    final totalValue =
        items.fold<double>(0, (sum, item) => sum + item.purchasePrice);
    final wornItems = items.where((e) => e.wearCount > 0).toList();
    final avgCpw = wornItems.isEmpty
        ? 0.0
        : wornItems.fold<double>(0, (s, e) => s + e.costPerWear) /
            wornItems.length;
    final utilization =
        totalPieces == 0 ? 0 : ((wornItems.length / totalPieces) * 100).round();

    final bestCpw = [...wornItems]
      ..sort((a, b) => a.costPerWear.compareTo(b.costPerWear));

    return Scaffold(
      appBar: AppBar(title: const Text('Closet Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _StatBox(label: 'TOTAL PIECES', value: '$totalPieces'),
              _StatBox(
                label: 'CLOSET VALUE',
                value: '₹${totalValue.toStringAsFixed(0)}',
              ),
              _StatBox(
                label: 'AVG COST / WEAR',
                value: '₹${avgCpw.toStringAsFixed(0)}',
                highlight: true,
              ),
              _StatBox(label: 'UTILIZATION', value: '$utilization%'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Best Cost-Per-Wear Gems',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...bestCpw.take(5).map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDED9CE)),
                  ),
                  child: Row(
                    children: [
                      GarmentVisual(item: item, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${item.brand} • Worn ${item.wearCount} times',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.costPerWear.toStringAsFixed(0)}/wear',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC85A32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatBox({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF18181B) : const Color(0xFFEFECE6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDED9CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: highlight ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: highlight ? const Color(0xFFFBBF24) : const Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/garment_visual.dart';
import 'add_item_sheet.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredWardrobeProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterPill(
                  label: 'All',
                  selected: selectedCategory == null,
                  onTap: () => ref
                      .read(selectedCategoryFilterProvider.notifier)
                      .state = null,
                ),
                ...ClothingCategory.values.map(
                  (cat) => _FilterPill(
                    label: cat.label,
                    selected: selectedCategory == cat,
                    onTap: () => ref
                        .read(selectedCategoryFilterProvider.notifier)
                        .state = cat,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('No pieces match this filter. Tap + to add!'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.80,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _GarmentCard(item: item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFF7F5F0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const AddItemSheet(),
        ),
        backgroundColor: const Color(0xFFC85A32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Add Piece'),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final controller =
        TextEditingController(text: ref.read(searchQueryProvider));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Closet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Brand, item name, or occasion...',
          ),
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).state = val,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF18181B),
        backgroundColor: const Color(0xFFEFECE6),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF18181B),
          fontWeight: FontWeight.w600,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? const Color(0xFF18181B) : const Color(0xFFDED9CE),
          ),
        ),
      ),
    );
  }
}

class _GarmentCard extends StatelessWidget {
  final ClothingItem item;

  const _GarmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDED9CE)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${item.costPerWear.toStringAsFixed(0)}/wear',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC85A32),
                  ),
                ),
              ),
              Text(
                '${item.wearCount}x',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(child: GarmentVisual(item: item, size: 100)),
          ),
          Text(
            item.brand.isEmpty ? item.category.label : item.brand.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }
}

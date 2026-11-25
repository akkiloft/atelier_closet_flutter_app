import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/garment_visual.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  bool _isCanvasMode = false;
  final _random = Random();

  // Shuffle mode state
  int _topIndex = 0;
  int _bottomIndex = 0;
  int _shoeIndex = 0;
  bool _lockTop = false;
  bool _lockBottom = false;
  bool _lockShoe = false;

  // Moodboard canvas state
  final List<CanvasItemPlacement> _canvasItems = [];
  String? _selectedCanvasItemId;

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(wardrobeProvider);
    final tops = allItems
        .where((e) =>
            e.category == ClothingCategory.tops ||
            e.category == ClothingCategory.outerwear)
        .toList();
    final bottoms =
        allItems.where((e) => e.category == ClothingCategory.bottoms).toList();
    final shoes =
        allItems.where((e) => e.category == ClothingCategory.footwear).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Shuffle')),
                ButtonSegment(value: true, label: Text('Canvas')),
              ],
              selected: {_isCanvasMode},
              onSelectionChanged: (set) =>
                  setState(() => _isCanvasMode = set.first),
            ),
          ),
        ],
      ),
      body: _isCanvasMode
          ? _buildMoodboardCanvas(allItems)
          : _buildShuffleView(tops, bottoms, shoes),
    );
  }

  Widget _buildShuffleView(
    List<ClothingItem> tops,
    List<ClothingItem> bottoms,
    List<ClothingItem> shoes,
  ) {
    final currentTop = tops.isEmpty ? null : tops[_topIndex % tops.length];
    final currentBottom =
        bottoms.isEmpty ? null : bottoms[_bottomIndex % bottoms.length];
    final currentShoe = shoes.isEmpty ? null : shoes[_shoeIndex % shoes.length];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _CarouselSlot(
              label: 'TOP / LAYER',
              item: currentTop,
              locked: _lockTop,
              onToggleLock: () => setState(() => _lockTop = !_lockTop),
              onPrevious: () => setState(() {
                if (tops.isNotEmpty) {
                  _topIndex = (_topIndex - 1 + tops.length) % tops.length;
                }
              }),
              onNext: () => setState(() => _topIndex++),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _CarouselSlot(
              label: 'BOTTOMS',
              item: currentBottom,
              locked: _lockBottom,
              onToggleLock: () => setState(() => _lockBottom = !_lockBottom),
              onPrevious: () => setState(() {
                if (bottoms.isNotEmpty) {
                  _bottomIndex =
                      (_bottomIndex - 1 + bottoms.length) % bottoms.length;
                }
              }),
              onNext: () => setState(() => _bottomIndex++),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _CarouselSlot(
              label: 'FOOTWEAR',
              item: currentShoe,
              locked: _lockShoe,
              onToggleLock: () => setState(() => _lockShoe = !_lockShoe),
              onPrevious: () => setState(() {
                if (shoes.isNotEmpty) {
                  _shoeIndex = (_shoeIndex - 1 + shoes.length) % shoes.length;
                }
              }),
              onNext: () => setState(() => _shoeIndex++),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      if (!_lockTop && tops.isNotEmpty) {
                        _topIndex = _random.nextInt(tops.length);
                      }
                      if (!_lockBottom && bottoms.isNotEmpty) {
                        _bottomIndex = _random.nextInt(bottoms.length);
                      }
                      if (!_lockShoe && shoes.isNotEmpty) {
                        _shoeIndex = _random.nextInt(shoes.length);
                      }
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC85A32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Dress Me (Shuffle)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final ids = [
                      if (currentTop != null) currentTop.id,
                      if (currentBottom != null) currentBottom.id,
                      if (currentShoe != null) currentShoe.id,
                    ];
                    _promptSaveOutfit(ids);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Look'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodboardCanvas(List<ClothingItem> allItems) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDED9CE), width: 1.5),
            ),
            child: Stack(
              children: [
                if (_canvasItems.isEmpty)
                  const Center(
                    child: Text(
                      'Tap pieces below to add & drag on canvas',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ..._canvasItems.map((placement) {
                  final item = allItems
                      .where((e) => e.id == placement.itemId)
                      .firstOrNull;
                  if (item == null) return const SizedBox.shrink();
                  final isSelected = _selectedCanvasItemId == item.id;

                  return Positioned(
                    left: placement.x,
                    top: placement.y,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCanvasItemId = item.id),
                      onPanUpdate: (details) {
                        setState(() {
                          final idx = _canvasItems
                              .indexWhere((e) => e.itemId == item.id);
                          _canvasItems[idx] = placement.copyWith(
                            x: placement.x + details.delta.dx,
                            y: placement.y + details.delta.dy,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFC85A32), width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GarmentVisual(
                          item: item,
                          size: 105 * placement.scale,
                        ),
                      ),
                    ),
                  );
                }),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.icon(
                    onPressed: _canvasItems.isEmpty
                        ? null
                        : () => _promptSaveOutfit(
                              _canvasItems.map((e) => e.itemId).toList(),
                              placements: _canvasItems,
                            ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                    ),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Save Canvas'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_canvasItems.any((e) => e.itemId == item.id)) {
                      _canvasItems.add(
                        CanvasItemPlacement(
                          itemId: item.id,
                          x: 60.0 + (_canvasItems.length * 22),
                          y: 40.0 + (_canvasItems.length * 28),
                        ),
                      );
                    }
                  });
                },
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDED9CE)),
                  ),
                  child: GarmentVisual(item: item, size: 54),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _promptSaveOutfit(
    List<String> itemIds, {
    List<CanvasItemPlacement> placements = const [],
  }) {
    if (itemIds.isEmpty) return;
    final ctrl = TextEditingController(text: 'Everyday Look');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Outfit'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Outfit Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(outfitsProvider.notifier).saveOutfit(
                    name: ctrl.text.trim().isEmpty
                        ? 'Saved Look'
                        : ctrl.text.trim(),
                    itemIds: itemIds,
                    canvasPlacements: placements,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Outfit saved to your lookbook!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _CarouselSlot extends StatelessWidget {
  final String label;
  final ClothingItem? item;
  final bool locked;
  final VoidCallback onToggleLock;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _CarouselSlot({
    required this.label,
    required this.item,
    required this.locked,
    required this.onToggleLock,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: locked ? const Color(0xFFC85A32) : const Color(0xFFDED9CE),
          width: locked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: locked ? null : onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: item == null
                ? Center(child: Text('No $label added'))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GarmentVisual(item: item!, size: 78),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              item!.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          IconButton(
            onPressed: locked ? null : onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          IconButton(
            onPressed: onToggleLock,
            icon: Icon(
              locked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: locked ? const Color(0xFFC85A32) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

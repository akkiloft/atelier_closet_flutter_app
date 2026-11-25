import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/garment_visual.dart';

class CalendarPackingScreen extends ConsumerStatefulWidget {
  const CalendarPackingScreen({super.key});

  @override
  ConsumerState<CalendarPackingScreen> createState() =>
      _CalendarPackingScreenState();
}

class _CalendarPackingScreenState extends ConsumerState<CalendarPackingScreen> {
  bool _showPacking = false;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showPacking ? 'Trip Packing' : 'OOTD Planner'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Calendar')),
                ButtonSegment(value: true, label: Text('Packing')),
              ],
              selected: {_showPacking},
              onSelectionChanged: (s) => setState(() => _showPacking = s.first),
            ),
          ),
        ],
      ),
      body: _showPacking ? _buildPackingView() : _buildCalendarView(),
    );
  }

  Widget _buildCalendarView() {
    final entries = ref.watch(calendarProvider);
    final outfits = ref.watch(outfitsProvider);
    final wardrobe = ref.watch(wardrobeProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final entry = entries.where((e) => e.dateKey == dateKey).firstOrNull;
    final scheduledOutfit = entry == null
        ? null
        : outfits.where((o) => o.id == entry.outfitId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, idx) {
                final day = DateTime.now().add(Duration(days: idx - 3));
                final key = DateFormat('yyyy-MM-dd').format(day);
                final isSelected = key == dateKey;
                final hasOutfit = entries.any((e) => e.dateKey == key);

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 58,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF18181B)
                          : const Color(0xFFEFECE6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDED9CE)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF18181B),
                          ),
                        ),
                        if (hasOutfit)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC85A32),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDED9CE)),
              ),
              child: scheduledOutfit == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No outfit scheduled for this day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: outfits.isEmpty
                              ? null
                              : () => _pickOutfitForDate(dateKey),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC85A32),
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(
                            outfits.isEmpty
                                ? 'Save an outfit in Studio first'
                                : 'Assign Saved Look',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(_selectedDate),
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          scheduledOutfit.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: scheduledOutfit.itemIds.map((id) {
                                final item = wardrobe
                                    .where((w) => w.id == id)
                                    .firstOrNull;
                                if (item == null) return const SizedBox.shrink();
                                return GarmentVisual(item: item, size: 95);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF15803D), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Logged as worn — item Cost-Per-Wear updated',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickOutfitForDate(String dateKey) {
    final outfits = ref.read(outfitsProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose Outfit to Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...outfits.map(
            (o) => ListTile(
              title: Text(o.name),
              subtitle: Text('${o.itemIds.length} pieces'),
              trailing: const Icon(Icons.check_rounded),
              onTap: () async {
                await ref.read(calendarProvider.notifier).scheduleOutfit(
                      dateKey: dateKey,
                      outfitId: o.id,
                      logAsWorn: true,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingView() {
    final trips = ref.watch(packingProvider);
    final wardrobe = ref.watch(wardrobeProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFECE6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDED9CE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${trip.title} • ${trip.destination}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.packedItemIds.length}/${trip.itemIds.length} packed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC85A32),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...trip.itemIds.map((id) {
                final item = wardrobe.where((w) => w.id == id).firstOrNull;
                if (item == null) return const SizedBox.shrink();
                final isPacked = trip.packedItemIds.contains(id);

                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isPacked,
                  activeColor: const Color(0xFFC85A32),
                  title: Text(item.name),
                  subtitle: Text(item.category.label),
                  secondary: GarmentVisual(item: item, size: 42),
                  onChanged: (_) => ref
                      .read(packingProvider.notifier)
                      .togglePacked(trip.id, id),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

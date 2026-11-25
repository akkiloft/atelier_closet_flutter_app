import 'dart:io';

import 'package:atelier_closet/main.dart';
import 'package:atelier_closet/models/clothing_item.dart';
import 'package:atelier_closet/models/outfit.dart';
import 'package:atelier_closet/providers/wardrobe_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atelier_closet_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<String>('wardrobe_box');
    await Hive.openBox<String>('outfits_box');
    await Hive.openBox<String>('calendar_box');
    await Hive.openBox<String>('packing_box');
  });

  tearDown(() async {
    await Hive.close().timeout(
      const Duration(seconds: 2),
      onTimeout: () => <void>[],
    );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Data models', () {
    test('ClothingItem costPerWear handles zero and positive wear counts', () {
      final unworn = ClothingItem(
        id: '1',
        name: 'Linen Shirt',
        imagePath: 'icon:shirt',
        category: ClothingCategory.tops,
        purchasePrice: 2000,
        purchaseDate: DateTime(2026, 1, 1),
        wearCount: 0,
      );
      expect(unworn.costPerWear, 2000);

      final worn = unworn.copyWith(wearCount: 4);
      expect(worn.costPerWear, 500);

      final free = unworn.copyWith(purchasePrice: 0);
      expect(free.costPerWear, 0);
    });

    test('ClothingItem and Outfit round-trip JSON serialization', () {
      final item = ClothingItem(
        id: 'item_1',
        name: 'Trousers',
        imagePath: 'icon:pants',
        isAsset: true,
        category: ClothingCategory.bottoms,
        brand: 'Studio',
        purchasePrice: 3000,
        purchaseDate: DateTime(2026, 5, 10),
        wearCount: 3,
      );
      final decodedItem = ClothingItem.fromJson(item.toJson());
      expect(decodedItem.id, item.id);
      expect(decodedItem.category, ClothingCategory.bottoms);
      expect(decodedItem.wearCount, 3);

      final outfit = Outfit(
        id: 'outfit_1',
        name: 'Office Look',
        itemIds: const ['item_1'],
        canvasPlacements: const [
          CanvasItemPlacement(itemId: 'item_1', x: 10, y: 20, scale: 1.2),
        ],
        createdAt: DateTime(2026, 5, 10),
      );
      final decodedOutfit = Outfit.fromJson(outfit.toJson());
      expect(decodedOutfit.name, 'Office Look');
      expect(decodedOutfit.canvasPlacements.first.scale, 1.2);
    });

    test('CalendarNotifier replaces existing entry for same date in Hive',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final outfit1 = await container.read(outfitsProvider.notifier).saveOutfit(
        name: 'Look 1',
        itemIds: const ['sample_1'],
      );
      final outfit2 = await container.read(outfitsProvider.notifier).saveOutfit(
        name: 'Look 2',
        itemIds: const ['sample_2'],
      );

      final calendar = container.read(calendarProvider.notifier);
      await calendar.scheduleOutfit(
        dateKey: '2026-11-25',
        outfitId: outfit1.id,
        logAsWorn: false,
      );
      await calendar.scheduleOutfit(
        dateKey: '2026-11-25',
        outfitId: outfit2.id,
        logAsWorn: false,
      );

      final calendarBox = Hive.box<String>('calendar_box');
      expect(calendarBox.length, 1);
      expect(container.read(calendarProvider).single.outfitId, outfit2.id);
    });
  });

  group('AtelierClosetApp widget flows', () {
    testWidgets('renders Closet, Studio, Planner, and Stats tabs cleanly',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: AtelierClosetApp(useGoogleFonts: false)),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      // Home tab: Closet
      expect(find.text('My Closet'), findsOneWidget);
      expect(find.text('Boxy Heavyweight Tee'), findsOneWidget);

      // Filter by Footwear
      await tester.tap(find.text('Footwear'));
      await tester.pumpAndSettle();
      expect(find.text('Retro Suede Runners'), findsOneWidget);
      expect(find.text('Boxy Heavyweight Tee'), findsNothing);

      // Switch to Studio and save a look
      await tester.tap(find.text('Studio'));
      await tester.pumpAndSettle();
      expect(find.text('Outfit Studio'), findsOneWidget);

      await tester.tap(find.text('Dress Me (Shuffle)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Look'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Outfit saved to your lookbook!'), findsOneWidget);

      // Switch to Planner -> Calendar & Packing
      await tester.tap(find.text('Planner'));
      await tester.pumpAndSettle();
      expect(find.text('OOTD Planner'), findsOneWidget);

      await tester.tap(find.text('Assign Saved Look'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everyday Look'));
      for (int i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
      }
      expect(find.text('Choose Outfit to Log'), findsNothing);
      expect(
        find.text('Logged as worn — item Cost-Per-Wear updated'),
        findsOneWidget,
      );

      // Switch to Packing sub-tab
      await tester.tap(find.text('Packing'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Trip Packing'), findsOneWidget);
      expect(find.text('2/4 packed'), findsOneWidget);

      // Switch to Stats
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.text('Closet Insights'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Best Cost-Per-Wear Gems'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Best Cost-Per-Wear Gems'), findsOneWidget);
    });
  });
}

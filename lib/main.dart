import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/calendar_packing_screen.dart';
import 'screens/closet_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/studio_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('wardrobe_box');
  await Hive.openBox<String>('outfits_box');
  await Hive.openBox<String>('calendar_box');
  await Hive.openBox<String>('packing_box');

  runApp(const ProviderScope(child: AtelierClosetApp()));
}

class AtelierClosetApp extends StatelessWidget {
  final bool useGoogleFonts;

  const AtelierClosetApp({super.key, this.useGoogleFonts = true});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F5F0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC85A32),
        surface: const Color(0xFFF7F5F0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF7F5F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: useGoogleFonts
            ? GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF18181B),
              )
            : const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
      ),
    );

    return MaterialApp(
      title: 'Atelier Closet',
      debugShowCheckedModeBanner: false,
      theme: useGoogleFonts
          ? baseTheme.copyWith(
              textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
            )
          : baseTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    ClosetScreen(),
    StudioScreen(),
    CalendarPackingScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFEFECE6),
        indicatorColor: const Color(0xFFC85A32).withValues(alpha: 0.18),
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom_rounded),
            label: 'Closet',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

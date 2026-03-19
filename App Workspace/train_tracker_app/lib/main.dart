import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/train_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/train_status_screen.dart';
import 'screens/pnr_screen.dart';
import 'screens/map_screen.dart';
import 'screens/settings_screen.dart';
import 'services/offline_cache_service.dart';
import 'db/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localisation
  await EasyLocalization.ensureInitialized();

  // SQLite tower DB init
  await DatabaseHelper.instance.database;

  // Firebase (optional — gracefully skip if not configured)
  try {
    await Firebase.initializeApp();
  } catch (_) {
    debugPrint('⚠️ Firebase not configured – running without Firebase features');
  }

  // Prefer portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/l10n',
      fallbackLocale: const Locale('en'),
      child: const TrainTrackerApp(),
    ),
  );
}

class TrainTrackerApp extends StatelessWidget {
  const TrainTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (ctx, settings, _) => MaterialApp(
          title: 'Where Is My Train',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: settings.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/train': (_) => const TrainStatusScreen(),
            '/pnr': (_) => const PNRScreen(),
            '/map': (_) => const MapScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        fontFamily: 'Outfit',
        useMaterial3: true,
      );

  ThemeData _buildDarkTheme() => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        fontFamily: 'Outfit',
        useMaterial3: true,
      );
}

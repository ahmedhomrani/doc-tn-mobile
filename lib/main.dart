import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/language_selection_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('selected_locale');
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final isDarkMode = prefs.getBool('dark_mode') ?? false;

  runApp(MyApp(
    savedLocale: savedLocale,
    isLoggedIn: isLoggedIn,
    isDarkMode: isDarkMode,
  ));
}

class MyApp extends StatefulWidget {
  final String? savedLocale;
  final bool isLoggedIn;
  final bool isDarkMode;

  const MyApp({
    super.key,
    this.savedLocale,
    required this.isLoggedIn,
    required this.isDarkMode,
  });

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale? _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale != null ? Locale(widget.savedLocale!) : null;
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  void setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', mode == ThemeMode.dark);
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  Widget _getStartScreen() {
    if (widget.isLoggedIn) return const HomeScreen();
    if (widget.savedLocale == null) return const LanguageSelectionScreen();
    return const WelcomeScreen();
  }

  // Blue palette matching tabibi.tn
  static const _primaryColor = Color(0xFF1A9BE8);

  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: const Color(0xFF0B7FCC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F7FF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A9BE8),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFEEEEEE),
  );

  ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: const Color(0xFF0B7FCC),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1B2E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF112240),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: const Color(0xFF112240),
    dividerColor: const Color(0xFF1E3A5F),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: _getStartScreen(),
    );
  }
}

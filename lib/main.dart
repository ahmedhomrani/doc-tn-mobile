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

  runApp(MyApp(savedLocale: savedLocale, isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final String? savedLocale;
  final bool isLoggedIn;

  const MyApp({super.key, this.savedLocale, required this.isLoggedIn});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale != null ? Locale(widget.savedLocale!) : null;
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  Widget _getStartScreen() {
    if (widget.isLoggedIn) return const HomeScreen();
    if (widget.savedLocale == null) return const LanguageSelectionScreen();
    return const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
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

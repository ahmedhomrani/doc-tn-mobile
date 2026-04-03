import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLocale = 'fr';

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'fr',
      'name': 'Français',
      'subtitle': 'Langue française',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF3F51B5),
      'label': 'FR',
    },
    {
      'code': 'ar',
      'name': 'العربية',
      'subtitle': 'اللغة العربية',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF4CAF50),
      'label': 'ع',
    },
    {
      'code': 'en',
      'name': 'English',
      'subtitle': 'English language',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF00897B),
      'label': 'EN',
    },
  ];

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', _selectedLocale);

    MyApp.of(context)?.setLocale(Locale(_selectedLocale));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Center(
                child: Text(
                  'Sélectionner la langue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Choisissez votre langue préférée',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 40),

              // Language tiles
              ..._languages.map((lang) => _buildLanguageTile(lang)),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FE9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, dynamic> lang) {
    final isSelected = _selectedLocale == lang['code'];
    return GestureDetector(
      onTap: () => setState(() => _selectedLocale = lang['code']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B4FE9) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag circle — uses a colored circle with text label (no emoji, instant render)
            CircleAvatar(
              backgroundColor: lang['flagColor'] as Color,
              radius: 24,
              child: Text(
                lang['label'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Language name & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang['subtitle'] as String,
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Radio indicator
            isSelected
                ? const CircleAvatar(
                    backgroundColor: Color(0xFF5B4FE9),
                    radius: 12,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26, width: 1.5),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

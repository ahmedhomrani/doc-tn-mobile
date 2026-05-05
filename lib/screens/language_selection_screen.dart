import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  /// When [fromProfile] is true, selecting a language will just pop back
  /// to the profile screen instead of pushing WelcomeScreen.
  final bool fromProfile;
  const LanguageSelectionScreen({super.key, this.fromProfile = false});

  @override
  State<LanguageSelectionScreen>
      createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLocale = 'fr';

  // Blue accent matching tabibi.tn
  static const _blue = Color(0xFF1A9BE8);

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'fr',
      'name': 'Français',
      'subtitle': 'Langue française',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF1565C0),
      'label': 'FR',
    },
    {
      'code': 'ar',
      'name': 'العربية',
      'subtitle': 'اللغة العربية',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF0B7FCC),
      'label': 'ع',
    },
    {
      'code': 'en',
      'name': 'English',
      'subtitle': 'English language',
      'icon': Icons.translate,
      'flagColor': const Color(0xFF1A9BE8),
      'label': 'EN',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the current locale if we can read it
    final ctx = context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final code = Localizations.localeOf(ctx).languageCode;
      if (_languages.any((l) => l['code'] == code)) {
        setState(() => _selectedLocale = code);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', _selectedLocale);

    MyApp.of(context)?.setLocale(Locale(_selectedLocale));

    if (mounted) {
      if (widget.fromProfile) {
        // Just go back to profile — don't navigate to WelcomeScreen
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: widget.fromProfile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A9BE8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Language / Langue',
                style: TextStyle(color: Color(0xFF0D1B2E), fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.fromProfile) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A9BE8), Color(0xFF0B7FCC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A9BE8).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.language, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Sélectionner la langue',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B2E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Choisissez votre langue préférée',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 8),
              ],

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
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: _blue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.fromProfile ? 'Appliquer / Apply' : 'Continuer',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _blue : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _blue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag circle
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isSelected ? _blue : Colors.black87,
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _blue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _blue : Colors.black26,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

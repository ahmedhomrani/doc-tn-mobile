import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'language_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final sectionHeaderColor = isDark ? Colors.white38 : Colors.black38;
    final dividerColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.08);

    final appState = MyApp.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: cardColor),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: _teal.withOpacity(0.15),
                          child: const Icon(Icons.person,
                              color: _teal, size: 48),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _teal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: cardColor, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'sarah.jenkins@email.com',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Settings sections
              _buildCard(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  // Dark Mode toggle
                  _buildToggleRow(
                    icon: Icons.brightness_4_outlined,
                    label: l.darkMode,
                    value: isDark,
                    textPrimary: textPrimary,
                    onChanged: (v) {
                      appState?.setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  Divider(color: dividerColor, height: 1),
                  // Language
                  _buildNavRow(
                    icon: Icons.language_outlined,
                    label: l.languageLabel,
                    trailing: Text(
                      _currentLanguage(context),
                      style: const TextStyle(
                          color: _teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    textPrimary: textPrimary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildSectionHeader(l.health, sectionHeaderColor),
              _buildCard(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _buildNavRow(
                    icon: Icons.favorite_outline,
                    label: l.healthGoals,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildNavRow(
                    icon: Icons.show_chart_outlined,
                    label: l.healthIndicators,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildSectionHeader(l.account, sectionHeaderColor),
              _buildCard(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _buildNavRow(
                    icon: Icons.person_outline,
                    label: l.personalInfo,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildNavRow(
                    icon: Icons.phone_outlined,
                    label: l.emergencyContact,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildNavRow(
                    icon: Icons.shield_outlined,
                    label: l.insurance,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l.comingSoon,
                        style: const TextStyle(
                            color: Color(0xFFF57C00),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildSectionHeader(l.preferences, sectionHeaderColor),
              _buildCard(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _buildNavRow(
                    icon: Icons.notifications_outlined,
                    label: l.notifications,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildNavRow(
                    icon: Icons.help_outline,
                    label: l.helpSupport,
                    textPrimary: textPrimary,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout,
                          color: Color(0xFFE53935), size: 18),
                    ),
                    title: Text(
                      l.logout,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_logged_in', false);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l.appVersion,
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _currentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color cardColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required Color textPrimary,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00897B), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textPrimary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00897B),
            activeTrackColor: const Color(0xFF00897B).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required Color textPrimary,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00897B), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textPrimary),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}

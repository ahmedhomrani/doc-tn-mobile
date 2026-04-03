import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'doctors_screen.dart';
import 'agenda_screen.dart';
import 'rappels_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _teal = Color(0xFF00897B);

  final List<Widget> _pages = const [
    _HomeTab(),
    DoctorsScreen(),
    AgendaScreen(),
    RappelsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final navShadow = isDark ? Colors.black54 : Colors.black12;

    final navItems = [
      {'icon': Icons.home_rounded, 'label': l.home},
      {'icon': Icons.search, 'label': l.doctorsNavLabel},      // ← Search icon as requested
      {'icon': Icons.calendar_month_outlined, 'label': l.agenda},
      {'icon': Icons.notifications_outlined, 'label': l.rappels},
      {'icon': Icons.chat_bubble_outline, 'label': l.chat},
      {'icon': Icons.person_outline, 'label': l.profile},
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: navShadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (i) {
                final active = _selectedIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: active
                                ? _teal.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            navItems[i]['icon'] as IconData,
                            color: active ? _teal : (isDark ? Colors.white38 : Colors.black38),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navItems[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? _teal
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Home Tab Content (original home screen content)
// ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static const _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final textHint = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context, l, textPrimary, textSecondary),
              const SizedBox(height: 20),
              _buildSearchBar(context, l, cardColor, textHint),
              const SizedBox(height: 20),
              _buildUpcomingCard(context, l),
              const SizedBox(height: 24),
              _buildQuickActions(context, l, cardColor, textSecondary),
              const SizedBox(height: 24),
              _buildTodaysMeds(context, l, cardColor, textPrimary, textSecondary, isDark),
              const SizedBox(height: 24),
              _buildVitalsSection(context, l, cardColor, textPrimary, textSecondary, isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l,
      Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.welcomeBack,
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              l.userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l,
      Color cardColor, Color textHint) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(width: 16),
          Icon(Icons.search, color: textHint, size: 20),
          const SizedBox(width: 10),
          Text(
            l.searchHint,
            style: TextStyle(color: textHint, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.upcoming,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_outlined,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.doctorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.doctorSpecialty,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  l.today,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 14,
                  color: Colors.white.withOpacity(0.4),
                ),
                const Icon(Icons.access_time_outlined,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  l.appointmentTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l,
      Color cardColor, Color textSecondary) {
    final actions = [
      {
        'icon': Icons.medical_services_outlined,
        'label': l.doctors,
        'color': const Color(0xFF7986CB),
        'bg': const Color(0xFFEEF0FB),
      },
      {
        'icon': Icons.medication_outlined,
        'label': l.meds,
        'color': const Color(0xFFBA68C8),
        'bg': const Color(0xFFF5EEF8),
      },
      {
        'icon': Icons.assignment_outlined,
        'label': l.records,
        'color': const Color(0xFFFF8A65),
        'bg': const Color(0xFFFFF3EE),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': l.chat,
        'color': const Color(0xFF4DB6AC),
        'bg': const Color(0xFFEEF8F7),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: action['bg'] as Color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTodaysMeds(BuildContext context, AppLocalizations l,
      Color cardColor, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.todaysMeds,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            Text(
              l.seeAll,
              style: const TextStyle(
                fontSize: 13,
                color: _teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildMedTile(
          cardColor: cardColor,
          textSecondary: textSecondary,
          isDark: isDark,
          icon: Icons.check_box_outlined,
          iconColor: Colors.black26,
          name: l.vitaminD3,
          subtitle: l.vitaminSubtitle,
          time: '8:00 AM',
          timeColor: Colors.black45,
          accent: null,
          taken: true,
        ),
        const SizedBox(height: 10),
        _buildMedTile(
          cardColor: cardColor,
          textSecondary: textSecondary,
          isDark: isDark,
          icon: Icons.medication_outlined,
          iconColor: _teal,
          name: l.amoxicillin,
          subtitle: l.amoxicillinSubtitle,
          time: '2:00 PM',
          timeColor: _teal,
          accent: _teal,
          taken: false,
        ),
      ],
    );
  }

  Widget _buildMedTile({
    required Color cardColor,
    required Color textSecondary,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String name,
    required String subtitle,
    required String time,
    required Color timeColor,
    Color? accent,
    required bool taken,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: accent != null
            ? Border(left: BorderSide(color: accent, width: 3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: taken
                  ? (isDark ? Colors.white10 : Colors.grey[100])
                  : const Color(0xFFEEF8F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: taken ? Colors.black45 : Colors.black87,
                    decoration: taken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection(BuildContext context, AppLocalizations l,
      Color cardColor, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.myVitals,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
                icon: Icons.favorite,
                iconColor: Colors.red,
                bgColor: const Color(0xFFFFF0F0),
                label: l.heartRate,
                value: '72',
                unit: l.bpm,
                sub: l.now,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVitalCard(
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF7986CB),
                bgColor: const Color(0xFFEEF0FB),
                label: l.sleep,
                value: '7.5',
                unit: l.hrs,
                sub: l.avg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required String unit,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                sub,
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

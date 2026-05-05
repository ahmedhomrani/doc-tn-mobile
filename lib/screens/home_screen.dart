import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/socket_service.dart';
import '../services/base_service.dart';
import 'doctors_screen.dart';
import 'agenda_screen.dart';
import 'rappels_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _unreadMessages = 0;
  int _unreadNotifications = 0;
  StreamSubscription<SocketChatMessage>? _msgSub;
  StreamSubscription<SocketNotification>? _notifSub;

  static const _teal = Color(0xFF1A9BE8);

  void _goToDoctors() => setState(() => _selectedIndex = 1);

  late final List<Widget> _pages = [
    const _HomeTab(),
    const DoctorsScreen(),
    AgendaScreen(onNewAppointment: _goToDoctors),
    const RappelsScreen(),
    const ChatScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    final userId = await SessionStore.getUserId();
    final token = await SessionStore.getToken();
    if (userId != null && token != null) {
      await SocketService.instance.connect(userId, token);
    }
    _msgSub = SocketService.instance.onMessage.listen((msg) {
      if (!mounted) return;
      if (_selectedIndex != 4) {
        setState(() => _unreadMessages++);
      }
    });
    _notifSub = SocketService.instance.onNotification.listen((notif) {
      if (!mounted) return;
      if (_selectedIndex != 5) {
        setState(() => _unreadNotifications++);
      }
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF112240) : Colors.white;
    final navShadow = isDark ? Colors.black54 : Colors.black12;

    // index 4 = Chat, index 5 = Notifications
    final navItems = [
      {'icon': Icons.home_rounded,           'label': l.home,           'badge': 0},
      {'icon': Icons.search,                 'label': l.doctorsNavLabel,'badge': 0},
      {'icon': Icons.calendar_month_outlined,'label': l.agenda,         'badge': 0},
      {'icon': Icons.alarm_outlined,         'label': l.rappels,        'badge': 0},
      {'icon': Icons.chat_bubble_outline,    'label': l.chat,           'badge': _unreadMessages},
      {'icon': Icons.notifications_outlined, 'label': 'Alertes',        'badge': _unreadNotifications},
      {'icon': Icons.person_outline,         'label': l.profile,        'badge': 0},
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [BoxShadow(color: navShadow, blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (i) {
                final active = _selectedIndex == i;
                final badge = navItems[i]['badge'] as int;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = i;
                      if (i == 4) _unreadMessages = 0;
                      if (i == 5) _unreadNotifications = 0;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: active ? _teal.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                navItems[i]['icon'] as IconData,
                                color: active ? _teal : (isDark ? Colors.white38 : Colors.black38),
                                size: 22,
                              ),
                            ),
                            if (badge > 0)
                              Positioned(
                                right: -2, top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    badge > 9 ? '9+' : '$badge',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navItems[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            color: active ? _teal : (isDark ? Colors.white38 : Colors.black38),
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
// Home Tab Content
// ─────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const _teal = Color(0xFF1A9BE8);

  // Meds: true = taken (checked/disabled), false = pending
  final List<bool> _medTaken = [true, false];

  // Real user data from session
  String _displayName = '';
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final name = await SessionStore.getFullName();
    final img  = await SessionStore.getImageUrl();
    if (mounted) {
      setState(() {
        _displayName = name ?? '';
        _imageUrl    = img;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
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
    // Resolve display name: session name → localization fallback
    final name = _displayName.isNotEmpty ? _displayName : l.userName;
    // Initials for avatar fallback
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(1, 2)).toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.welcomeBack, style: TextStyle(fontSize: 14, color: textSecondary)),
            const SizedBox(height: 2),
            Text(
              name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
            ),
          ],
        ),
        // Avatar: real photo → initials
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1A9BE8).withOpacity(0.15),
          child: _imageUrl != null && _imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    _imageUrl!,
                    width: 48, height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      initials,
                      style: const TextStyle(color: Color(0xFF1A9BE8), fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                )
              : Text(
                  initials,
                  style: const TextStyle(color: Color(0xFF1A9BE8), fontWeight: FontWeight.w700, fontSize: 16),
                ),
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
        'color': const Color(0xFF1A9BE8),
        'bg': const Color(0xFFE3F2FD),
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
        'bg': const Color(0xFFE3F2FD),
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
    final meds = [
      {
        'name': l.vitaminD3,
        'subtitle': l.vitaminSubtitle,
        'time': '8:00 AM',
        'color': const Color(0xFF1A9BE8),
      },
      {
        'name': l.amoxicillin,
        'subtitle': l.amoxicillinSubtitle,
        'time': '2:00 PM',
        'color': const Color(0xFFBA68C8),
      },
    ];

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
        ...List.generate(meds.length, (i) {
          final med = meds[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < meds.length - 1 ? 10 : 0),
            child: _buildMedTile(
              cardColor: cardColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
              name: med['name'] as String,
              subtitle: med['subtitle'] as String,
              time: med['time'] as String,
              accentColor: med['color'] as Color,
              taken: _medTaken[i],
              onToggle: (val) => setState(() => _medTaken[i] = val),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMedTile({
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required String name,
    required String subtitle,
    required String time,
    required Color accentColor,
    required bool taken,
    required ValueChanged<bool> onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: taken
            ? null
            : Border(left: BorderSide(color: accentColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onToggle(!taken),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: taken,
                    onChanged: (v) => onToggle(v ?? false),
                    activeColor: Colors.grey.shade400,
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: taken ? Colors.grey.shade400 : accentColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Med icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: taken
                        ? (isDark ? Colors.white10 : const Color(0xFFF2F2F2))
                        : accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    color: taken ? Colors.grey.shade400 : accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: taken
                              ? (isDark ? Colors.white30 : Colors.black38)
                              : textPrimary,
                          decoration: taken ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey.shade400,
                        ),
                        child: Text(name),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: taken
                              ? (isDark ? Colors.white24 : Colors.black26)
                              : textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Time badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: taken
                        ? (isDark ? Colors.white10 : const Color(0xFFF2F2F2))
                        : accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: taken
                          ? (isDark ? Colors.white30 : Colors.black38)
                          : accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

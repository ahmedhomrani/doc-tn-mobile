import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class RappelsScreen extends StatefulWidget {
  const RappelsScreen({super.key});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  int _tabIndex = 0;

  final List<Map<String, dynamic>> _medReminders = [
    {
      'name': 'Lisinopril 10mg',
      'category': 'Blood Pressure · Once daily',
      'time': '8:00 AM',
      'enabled': true,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Metformin 500mg',
      'category': 'Blood Sugar · Twice daily',
      'time': '1:00 PM',
      'enabled': true,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Atorvastatin 20mg',
      'category': 'Cholesterol · Once daily',
      'time': '9:00 PM',
      'enabled': false,
      'color': const Color(0xFFFF8A65),
    },
  ];

  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final statBg = isDark ? const Color(0xFF374151) : const Color(0xFF004D40);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.reminders,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: Text(
                            l.add,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white24,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.stayOnTrack,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      children: [
                        _buildStat('2', l.activeMeds, statBg),
                        const SizedBox(width: 10),
                        _buildStat('2', l.activeAppts, statBg),
                        const SizedBox(width: 10),
                        _buildStat('4', l.totalActive, statBg),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter tabs
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: Row(
              children: [
                _buildTab(l.all, 0, textSecondary),
                _buildTab(l.meds, 1, textSecondary),
                _buildTab(l.visits, 2, textSecondary),
              ],
            ),
          ),

          // Reminder list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _medReminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final rem = _medReminders[i];
                return _buildReminderCard(
                  context: context,
                  cardColor: cardColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  name: rem['name'] as String,
                  category: rem['category'] as String,
                  time: rem['time'] as String,
                  enabled: rem['enabled'] as bool,
                  pillColor: rem['color'] as Color,
                  index: i,
                  l: l,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, Color textSecondary) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00897B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required BuildContext context,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required String name,
    required String category,
    required String time,
    required bool enabled,
    required Color pillColor,
    required int index,
    required AppLocalizations l,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: pillColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      category,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => setState(() => _medReminders[index]['enabled'] = v),
                activeColor: _teal,
                activeTrackColor: _teal.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 13, color: textSecondary),
              const SizedBox(width: 6),
              Text(time, style: TextStyle(color: textSecondary, fontSize: 12)),
              const SizedBox(width: 12),
              ..._days.map((d) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _teal,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline, size: 15,
                  color: Color(0xFFE53935)),
              label: Text(
                l.delete,
                style: const TextStyle(
                    color: Color(0xFFE53935), fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

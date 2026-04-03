import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int _tabIndex = 0;
  static const _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

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
                    Text(
                      l.appointments,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.manageVisits,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toggle tabs
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab(l.upcoming, 0, cardColor, textSecondary),
                _buildTab(l.past, 1, cardColor, textSecondary),
              ],
            ),
          ),

          // Appointment cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _buildAppointmentCard(
                  context: context,
                  cardColor: cardColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  initials: 'EC',
                  avatarColor: const Color(0xFF7986CB),
                  name: 'Dr. Emily Chen',
                  specialty: 'Cardiologist',
                  statusLabel: l.confirmed,
                  statusColor: const Color(0xFF00897B),
                  statusBg: const Color(0xFFE8F5E9),
                  date: 'Feb 22, 2026',
                  time: '10:30 AM',
                  clinic: 'City Medical Center',
                  mode: l.videoCall,
                  modeIcon: Icons.videocam_outlined,
                  primaryAction: l.join,
                  primaryColor: _teal,
                  secondaryAction: l.reminder,
                  onPrimary: () {},
                ),
                const SizedBox(height: 12),
                _buildAppointmentCard(
                  context: context,
                  cardColor: cardColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                  initials: 'MR',
                  avatarColor: const Color(0xFF4DB6AC),
                  name: 'Dr. Mark Rivera',
                  specialty: 'General Physician',
                  statusLabel: l.pending,
                  statusColor: const Color(0xFFF57C00),
                  statusBg: const Color(0xFFFFF3E0),
                  date: 'Mar 5, 2026',
                  time: '9:00 AM',
                  clinic: 'HealthFirst Clinic',
                  mode: l.inPerson,
                  modeIcon: Icons.person_outline,
                  primaryAction: l.cancel,
                  primaryColor: const Color(0xFFE53935),
                  secondaryAction: l.reminder,
                  onPrimary: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            shadowColor: _teal.withOpacity(0.4),
          ),
          child: Text(
            l.newAppointment,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, Color cardColor, Color textSecondary) {
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
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required BuildContext context,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required String initials,
    required Color avatarColor,
    required String name,
    required String specialty,
    required String statusLabel,
    required Color statusColor,
    required Color statusBg,
    required String date,
    required String time,
    required String clinic,
    required String mode,
    required IconData modeIcon,
    required String primaryAction,
    required Color primaryColor,
    required String secondaryAction,
    required VoidCallback onPrimary,
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
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
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
                      specialty,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 14),
          _infoRow(Icons.calendar_today_outlined, date, textSecondary),
          const SizedBox(height: 6),
          _infoRow(Icons.access_time_outlined, time, textSecondary),
          const SizedBox(height: 6),
          _infoRow(Icons.location_on_outlined, clinic, textSecondary),
          const SizedBox(height: 6),
          _infoRow(modeIcon, mode, textSecondary),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined, size: 16),
                  label: Text(secondaryAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF00897B),
                    side: const BorderSide(color: Color(0xFF00897B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    primaryAction,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

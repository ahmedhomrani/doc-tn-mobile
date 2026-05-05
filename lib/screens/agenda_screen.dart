import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/appointment_service.dart';
import '../services/base_service.dart';

class AgendaScreen extends StatefulWidget {
  final VoidCallback? onNewAppointment;
  const AgendaScreen({super.key, this.onNewAppointment});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0 = upcoming, 1 = past
  static const _blue = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);

  late final TabController _tabController;
  final AppointmentService _service = AppointmentService();

  List<AppointmentResponse> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await _service.getAll(size: 50);
      if (mounted) {
        setState(() {
          _appointments = page.content;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<AppointmentResponse> get _filtered {
    final now = DateTime.now();
    return _appointments.where((a) {
      if (_tabIndex == 0) {
        return a.appointmentDateTime.isAfter(now) &&
            a.status != AppointmentStatus.CANCELLED &&
            a.status != AppointmentStatus.COMPLETED;
      } else {
        return a.appointmentDateTime.isBefore(now) ||
            a.status == AppointmentStatus.COMPLETED ||
            a.status == AppointmentStatus.CANCELLED;
      }
    }).toList()
      ..sort((a, b) => _tabIndex == 0
          ? a.appointmentDateTime.compareTo(b.appointmentDateTime)
          : b.appointmentDateTime.compareTo(a.appointmentDateTime));
  }

  Future<void> _updateStatus(int id, AppointmentStatus status) async {
    try {
      final updated = await _service.updateStatus(id, status);
      setState(() {
        final idx = _appointments.indexWhere((a) => a.id == updated.id);
        if (idx >= 0) _appointments[idx] = updated;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: false,
            backgroundColor: _blue,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.appointments,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.manageVisits,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: _blue,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: l.upcoming),
                    Tab(text: l.past),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _buildContent(context, l, cardColor, textPrimary, textSecondary, isDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onNewAppointment,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.search),
        label: Text(
          l.newAppointment,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _blue),
            const SizedBox(height: 16),
            Text(
              'Loading appointments...',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load appointments',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final list = _filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.calendar_today_rounded, size: 44, color: _blue),
            ),
            const SizedBox(height: 20),
            Text(
              _tabIndex == 0 ? 'No upcoming appointments' : 'No past appointments',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tabIndex == 0
                  ? 'Book a new appointment with a doctor'
                  : 'Your completed visits will appear here',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AppointmentCard(
          appointment: list[i],
          cardColor: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          onStatusChange: _updateStatus,
          l: l,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Appointment Card
// ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentResponse appointment;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final AppLocalizations l;
  final Future<void> Function(int, AppointmentStatus) onStatusChange;

  const _AppointmentCard({
    required this.appointment,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.l,
    required this.onStatusChange,
  });

  static const _blue = Color(0xFF1A9BE8);

  static const List<Color> _avatarColors = [
    Color(0xFF1A9BE8),
    Color(0xFF7986CB),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
  ];

  Color get _avatarColor => _avatarColors[appointment.id % _avatarColors.length];

  String get _initials {
    final name = appointment.doctorName ?? 'DR';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  (Color bg, Color fg, String label, IconData icon) get _statusInfo {
    switch (appointment.status) {
      case AppointmentStatus.CONFIRMED:
        return (const Color(0xFFE3F2FD), const Color(0xFF1A9BE8), l.confirmed, Icons.check_circle_outline);
      case AppointmentStatus.PENDING:
        return (const Color(0xFFFFF3E0), const Color(0xFFF57C00), l.pending, Icons.schedule);
      case AppointmentStatus.SCHEDULED:
        return (const Color(0xFFE8EAF6), const Color(0xFF3949AB), 'Scheduled', Icons.event);
      case AppointmentStatus.COMPLETED:
        return (const Color(0xFFE8F5E9), const Color(0xFF43A047), 'Completed', Icons.task_alt);
      case AppointmentStatus.CANCELLED:
        return (const Color(0xFFFFEBEE), const Color(0xFFE53935), 'Cancelled', Icons.cancel_outlined);
      case AppointmentStatus.NO_SHOW:
        return (const Color(0xFFFFF8E1), const Color(0xFFF57C00), 'No Show', Icons.person_off_outlined);
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusColor, statusLabel, statusIcon) = _statusInfo;
    final isCancellable = appointment.status == AppointmentStatus.SCHEDULED ||
        appointment.status == AppointmentStatus.PENDING ||
        appointment.status == AppointmentStatus.CONFIRMED;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Colored top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor row
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _avatarColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: TextStyle(
                            color: _avatarColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName ?? 'Doctor',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: textPrimary,
                            ),
                          ),
                          if (appointment.type != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              appointment.type!.name.replaceAll('_', ' '),
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date & time chips
                Row(
                  children: [
                    _infoChip(
                      Icons.calendar_today_outlined,
                      _formatDate(appointment.appointmentDateTime),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      Icons.access_time_outlined,
                      _formatTime(appointment.appointmentDateTime),
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Patient row
                Row(
                  children: [
                    _infoChip(
                      Icons.person_outline,
                      appointment.patientName ?? 'Patient',
                      isDark,
                    ),
                    if (appointment.reason != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoChipExpanded(
                          Icons.notes_outlined,
                          appointment.reason!,
                          isDark,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined, size: 16),
                        label: Text(l.reminder),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _blue,
                          side: BorderSide(color: _blue.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isCancellable)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onStatusChange(appointment.id, AppointmentStatus.CANCELLED),
                          icon: const Icon(Icons.close, size: 16),
                          label: Text(l.cancel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBEE),
                            foregroundColor: const Color(0xFFE53935),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.videocam_outlined, size: 16),
                          label: Text(l.join),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _blue),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF0D1B2E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChipExpanded(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _blue),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF0D1B2E),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

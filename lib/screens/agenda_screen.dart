import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/appointment_service.dart';
import '../services/base_service.dart';

// ─────────────────────────────────────────────────────────
// Syncfusion data source adapter
// ─────────────────────────────────────────────────────────

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<AppointmentResponse> appointments) {
    this.appointments = appointments
        .map((a) => _toSf(a))
        .toList();
  }

  static Appointment _toSf(AppointmentResponse a) {
    final start = a.appointmentDateTime;
    final end = start.add(Duration(minutes: a.durationMinutes ?? 30));
    return Appointment(
      id: a.id,
      startTime: start,
      endTime: end,
      subject: a.doctorName != null ? 'Dr. ${a.doctorName}' : 'Appointment',
      notes: a.reason ?? a.notes,
      color: _statusColor(a.status),
      isAllDay: false,
    );
  }

  static Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.CONFIRMED:  return const Color(0xFF1A9BE8);
      case AppointmentStatus.PENDING:    return const Color(0xFFF57C00);
      case AppointmentStatus.SCHEDULED:  return const Color(0xFF3949AB);
      case AppointmentStatus.COMPLETED:  return const Color(0xFF43A047);
      case AppointmentStatus.CANCELLED:  return const Color(0xFFE53935);
      case AppointmentStatus.NO_SHOW:    return const Color(0xFF9E9E9E);
    }
  }
}

// ─────────────────────────────────────────────────────────
// AgendaScreen
// ─────────────────────────────────────────────────────────

class AgendaScreen extends StatefulWidget {
  final VoidCallback? onNewAppointment;
  const AgendaScreen({super.key, this.onNewAppointment});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const _blue     = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);

  final AppointmentService _service = AppointmentService();
  final CalendarController _calCtrl = CalendarController();

  List<AppointmentResponse> _appointments = [];
  bool _isLoading = true;
  String? _error;

  // View toggle
  CalendarView _view = CalendarView.month;
  static const _views = [
    CalendarView.month,
    CalendarView.week,
    CalendarView.day,
  ];
  static const _viewLabels = ['Month', 'Week', 'Day'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final page = await _service.getAll(size: 200);
      if (mounted) setState(() { _appointments = page.content; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _cancelAppointment(int id) async {
    try {
      final updated = await _service.updateStatus(id, AppointmentStatus.CANCELLED);
      setState(() {
        final i = _appointments.indexWhere((a) => a.id == id);
        if (i >= 0) _appointments[i] = updated;
      });
    } catch (_) {}
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg   = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final card = isDark ? const Color(0xFF112240) : Colors.white;
    final textP = isDark ? Colors.white : const Color(0xFF0D1B2E);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(isDark, textP),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: _blue)))
          else if (_error != null)
            _buildError(isDark, textP)
          else
            Expanded(child: _buildCalendar(isDark, card, textP)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onNewAppointment,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.search),
        label: const Text('New Appointment', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark, Color textP) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agenda',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        SizedBox(height: 2),
                        Text('Your appointments',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Refresh
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // View switcher
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: List.generate(_views.length, (i) {
                    final active = _view == _views[i];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _view = _views[i];
                          _calCtrl.view = _views[i];
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              _viewLabels[i],
                              style: TextStyle(
                                color: active ? _blue : Colors.white,
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _buildCalendar(bool isDark, Color card, Color textP) {
    final src = _AppointmentDataSource(_appointments);

    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: SfCalendar(
        controller: _calCtrl,
        view: _view,
        dataSource: src,
        initialDisplayDate: DateTime.now(),
        todayHighlightColor: _blue,
        selectionDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _blue, width: 2),
          shape: BoxShape.circle,
        ),
        backgroundColor: isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA),
        headerHeight: 56,
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            color: textP,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor:
              isDark ? const Color(0xFF112240) : Colors.white,
        ),
        viewHeaderStyle: ViewHeaderStyle(
          backgroundColor: isDark ? const Color(0xFF112240) : Colors.white,
          dayTextStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.w600),
          dateTextStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        monthViewSettings: MonthViewSettings(
          showAgenda: true,
          agendaViewHeight: 200,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          agendaStyle: AgendaStyle(
            backgroundColor:
                isDark ? const Color(0xFF112240) : Colors.white,
            appointmentTextStyle: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            dayTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 13),
            dateTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          monthCellStyle: MonthCellStyle(
            backgroundColor:
                isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA),
            todayBackgroundColor: _blue.withOpacity(0.12),
            textStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
            todayTextStyle: const TextStyle(
                color: _blue, fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 7,
          endHour: 22,
          timeTextStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45, fontSize: 11),
        ),
        appointmentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null &&
              details.appointments!.isNotEmpty) {
            final sfAppt = details.appointments!.first as Appointment;
            final appt = _appointments
                .where((a) => a.id == sfAppt.id)
                .firstOrNull;
            if (appt != null) _showDetail(appt);
          }
        },
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError(bool isDark, Color textP) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 36, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 16),
              Text('Failed to load appointments',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textP)),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail bottom sheet ───────────────────────────────────────────────────

  void _showDetail(AppointmentResponse a) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card  = isDark ? const Color(0xFF112240) : Colors.white;
    final textP = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textS = isDark ? Colors.white60 : Colors.black54;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentDetailSheet(
        appointment: a,
        card: card,
        textP: textP,
        textS: textS,
        isDark: isDark,
        onCancel: () {
          Navigator.pop(context);
          _cancelAppointment(a.id);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Detail bottom sheet
// ─────────────────────────────────────────────────────────

class _AppointmentDetailSheet extends StatelessWidget {
  final AppointmentResponse appointment;
  final Color card, textP, textS;
  final bool isDark;
  final VoidCallback onCancel;

  const _AppointmentDetailSheet({
    required this.appointment,
    required this.card,
    required this.textP,
    required this.textS,
    required this.isDark,
    required this.onCancel,
  });

  static const _blue = Color(0xFF1A9BE8);

  (Color bg, Color fg, String label, IconData icon) get _statusInfo {
    switch (appointment.status) {
      case AppointmentStatus.CONFIRMED:
        return (const Color(0xFFE3F2FD), _blue, 'Confirmed', Icons.check_circle_outline);
      case AppointmentStatus.PENDING:
        return (const Color(0xFFFFF3E0), const Color(0xFFF57C00), 'Pending', Icons.schedule);
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

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final mi = d.minute.toString().padLeft(2, '0');
    return '$h:$mi ${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final (sBg, sFg, sLabel, sIcon) = _statusInfo;
    final dt = appointment.appointmentDateTime;
    final canCancel = appointment.status == AppointmentStatus.SCHEDULED ||
        appointment.status == AppointmentStatus.PENDING ||
        appointment.status == AppointmentStatus.CONFIRMED;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.medical_services_outlined, color: _blue, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName != null
                          ? 'Dr. ${appointment.doctorName}'
                          : 'Appointment',
                      style: TextStyle(
                          color: textP,
                          fontSize: 17,
                          fontWeight: FontWeight.w800),
                    ),
                    if (appointment.type != null)
                      Text(
                        appointment.type!.name.replaceAll('_', ' '),
                        style: TextStyle(color: textS, fontSize: 13),
                      ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sIcon, size: 12, color: sFg),
                    const SizedBox(width: 4),
                    Text(sLabel,
                        style: TextStyle(
                            color: sFg,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info grid
          _row(Icons.calendar_today_outlined, 'Date', _fmtDate(dt), textP, textS),
          const SizedBox(height: 12),
          _row(Icons.access_time_outlined, 'Time', _fmtTime(dt), textP, textS),
          const SizedBox(height: 12),
          _row(Icons.timer_outlined, 'Duration',
              '${appointment.durationMinutes ?? 30} minutes', textP, textS),
          if (appointment.patientName != null) ...[
            const SizedBox(height: 12),
            _row(Icons.person_outline, 'Patient',
                appointment.patientName!, textP, textS),
          ],
          if (appointment.reason != null) ...[
            const SizedBox(height: 12),
            _row(Icons.notes_outlined, 'Reason',
                appointment.reason!, textP, textS),
          ],
          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            _row(Icons.sticky_note_2_outlined, 'Notes',
                appointment.notes!, textP, textS),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textS,
                    side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      Color textP, Color textS) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _blue, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: textS, fontSize: 11)),
            Text(value,
                style: TextStyle(
                    color: textP,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

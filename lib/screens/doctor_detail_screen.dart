import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/doctor_service.dart';
import '../services/appointment_service.dart';
import '../services/base_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorSearchResponse doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _teal = Color(0xFF1A9BE8);
  final DoctorService _service = DoctorService();

  late TabController _tabCtrl;

  // Reviews
  List<DoctorReview> _reviews = [];
  bool _reviewsLoading = true;
  String? _reviewsError;

  // Availability
  List<TimeSlotResponse> _slots = [];
  bool _slotsLoading = false;
  DateTime _selectedDay = DateTime.now();
  TimeSlotResponse? _selectedSlot;

 @override
void initState() {
  super.initState();
  _tabCtrl = TabController(length: 3, vsync: this);
  _tabCtrl.addListener(() {
    if (_tabCtrl.index == 1 && _slots.isEmpty && !_slotsLoading) {
      _loadSlots();
    }
  });
}

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() { _slotsLoading = true; _selectedSlot = null; });
    try {
      final date =
          '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
      final slots = await _service.getAvailability(widget.doctor.id, date);
      if (mounted) setState(() { _slots = slots; _slotsLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _slots = []; _slotsLoading = false; });
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String get _specLabel {
    final s = widget.doctor.specialization;
    if (s == null) return 'General Practice';
    return s.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Color get _avatarColor {
    const cols = [
      Color(0xFF7986CB), Color(0xFF4DB6AC), Color(0xFFBA68C8),
      Color(0xFFFF8A65), Color(0xFF4FC3F7), Color(0xFFA5D6A7),
    ];
    return cols[widget.doctor.id % cols.length];
  }

  String get _initials {
    final f = widget.doctor.firstName.isNotEmpty ? widget.doctor.firstName[0] : '';
    final l = widget.doctor.lastName.isNotEmpty ? widget.doctor.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA);
    final card = isDark ? const Color(0xFF112240) : Colors.white;
    final textP = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textS = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildHeader(isDark, card, textP, textS)],
        body: Column(
          children: [
            // Tab bar
            Container(
              color: card,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: _teal,
                unselectedLabelColor: textS,
                indicatorColor: _teal,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Availability'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildAbout(card, textP, textS, isDark),
                  _buildAvailability(card, textP, textS, isDark),
                  _buildReviews(card, textP, textS, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookBar(isDark),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  SliverAppBar _buildHeader(bool isDark, Color card, Color textP, Color textS) {
    final doc = widget.doctor;
    final accepting = doc.acceptingNewPatients ?? true;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _teal,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A9BE8), Color(0xFF0B7FCC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Avatar
                      _buildAvatar(doc),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dr. ${doc.fullName}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(_specLabel,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14)),
                            if (doc.city != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 3),
                                Text(
                                  [doc.address, doc.city]
                                      .whereType<String>()
                                      .join(', '),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Stats row
                  Row(
                    children: [
                      _statPill(Icons.star, '${doc.averageRating?.toStringAsFixed(1) ?? '—'}', 'Rating'),
                      const SizedBox(width: 10),
                      _statPill(Icons.rate_review_outlined, '${doc.totalReviews ?? 0}', 'Reviews'),
                      const SizedBox(width: 10),
                      _statPill(Icons.work_outline, '${doc.yearsOfExperience ?? '—'}y', 'Exp.'),
                      const SizedBox(width: 10),
                      _statPill(
                        accepting ? Icons.check_circle_outline : Icons.cancel_outlined,
                        accepting ? 'Open' : 'Closed',
                        'Patients',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(DoctorSearchResponse doc) {
    if (doc.profileImageUrl != null && doc.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Image.network(doc.profileImageUrl!,
            width: 72, height: 72, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsAvatar()),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() => CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white.withOpacity(0.25),
        child: Text(_initials,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
      );

  Widget _statPill(IconData icon, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10)),
            ],
          ),
        ),
      );

  // ── ABOUT TAB ─────────────────────────────────────────────────────────────

 Widget _buildAbout(Color card, Color textP, Color textS, bool isDark) {
  final doc = widget.doctor;
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Fee & duration card
      _infoCard(card, isDark, [
        _infoRow(Icons.attach_money, 'Consultation Fee',
            doc.consultationFee != null
                ? '${doc.consultationFee!.toStringAsFixed(0)} TND'
                : 'Not specified',
            textP, textS),
        if (doc.consultationDuration != null) ...[
          _divider(isDark),
          _infoRow(Icons.timer_outlined, 'Duration',
              '${doc.consultationDuration} minutes', textP, textS),
        ],
        if (doc.consultationType != null) ...[
          _divider(isDark),
          _infoRow(Icons.video_call_outlined, 'Consultation Type',
              _consultLabel(doc.consultationType!), textP, textS),
        ],
      ]),
      const SizedBox(height: 14),

      // Languages
      if (doc.spokenLanguages != null) ...[
        _infoCard(card, isDark, [
          _infoRow(Icons.translate_outlined, 'Languages Spoken',
              doc.spokenLanguages!, textP, textS),
        ]),
        const SizedBox(height: 14),
      ],

      // Education
      if (doc.education.isNotEmpty) ...[
        _sectionTitle('Education', textP),
        const SizedBox(height: 8),
        _infoCard(card, isDark, [
          for (int i = 0; i < doc.education.length; i++) ...[
            if (i > 0) _divider(isDark),
            _infoRow(
              Icons.school_outlined,
              doc.education[i].degree ?? 'Degree',
              [
                doc.education[i].institution,
                doc.education[i].graduationYear?.toString(),
              ].whereType<String>().join(' · '),
              textP,
              textS,
            ),
          ],
        ]),
        const SizedBox(height: 14),
      ],

      // Bio
      if (doc.bio != null && doc.bio!.isNotEmpty) ...[
        _sectionTitle('About the Doctor', textP),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Text(doc.bio!,
              style: TextStyle(color: textS, fontSize: 14, height: 1.6)),
        ),
        const SizedBox(height: 14),
      ],

      // Map
      if (doc.latitude != null && doc.longitude != null) ...[
        _sectionTitle('Location', textP),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(doc.latitude!, doc.longitude!),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.doc.doctn',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(doc.latitude!, doc.longitude!),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color(0xFF1A9BE8),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (doc.address != null || doc.city != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF1A9BE8), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [doc.address, doc.city, doc.country]
                        .whereType<String>()
                        .join(', '),
                    style: TextStyle(color: textS, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
      ],
    ],
  );
}

  String _consultLabel(ConsultationType t) {
    switch (t) {
      case ConsultationType.IN_PERSON: return 'In-Person';
      case ConsultationType.ONLINE:    return 'Online';
      case ConsultationType.BOTH:      return 'In-Person & Online';
    }
  }

  Widget _infoCard(Color card, bool isDark, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value,
      Color textP, Color textS) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: _teal, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(color: textS, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: textP,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 66,
        color: isDark ? Colors.white12 : Colors.black12,
      );

  Widget _sectionTitle(String text, Color textP) => Text(text,
      style: TextStyle(
          color: textP, fontSize: 16, fontWeight: FontWeight.w700));

  // ── AVAILABILITY TAB ──────────────────────────────────────────────────────

  Widget _buildAvailability(Color card, Color textP, Color textS, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Day picker
        _sectionTitle('Select Date', textP),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final day = DateTime.now().add(Duration(days: i));
              final selected = _isSameDay(day, _selectedDay);
              return GestureDetector(
                onTap: () {
                  setState(() { _selectedDay = day; _slots = []; });
                  _loadSlots();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  decoration: BoxDecoration(
                    color: selected ? _teal : card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected
                            ? _teal
                            : (isDark ? Colors.white12 : Colors.black12)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekday(day),
                          style: TextStyle(
                              color: selected ? Colors.white70 : textS,
                              fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('${day.day}',
                          style: TextStyle(
                              color: selected ? Colors.white : textP,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Available Slots', textP),
        const SizedBox(height: 12),
        if (_slotsLoading)
          const Center(child: CircularProgressIndicator(color: _teal))
        else if (_slots.isEmpty)
          Center(
            child: Column(children: [
              Icon(Icons.event_busy_outlined, size: 48, color: textS),
              const SizedBox(height: 8),
              Text('No slots available for this day',
                  style: TextStyle(color: textS)),
            ]),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _slots.map((slot) {
              final avail = slot.available;
              final sel = _selectedSlot == slot;
              return GestureDetector(
                onTap: avail ? () => setState(() => _selectedSlot = slot) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: !avail
                        ? (isDark ? Colors.white10 : Colors.grey.shade100)
                        : sel
                            ? _teal
                            : card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? _teal
                            : (isDark ? Colors.white12 : Colors.black12)),
                  ),
                  child: Text(
                    _formatTime(slot.startTime),
                    style: TextStyle(
                      color: !avail
                          ? textS.withOpacity(0.4)
                          : sel
                              ? Colors.white
                              : textP,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: !avail
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekday(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  String _formatTime(String t) {
    // t is "HH:mm:ss" or "HH:mm"
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }

  // ── REVIEWS TAB ───────────────────────────────────────────────────────────

  Widget _buildReviews(Color card, Color textP, Color textS, bool isDark) {
  final reviews = widget.doctor.reviews;

  if (reviews.isEmpty) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined, size: 56, color: textS),
          const SizedBox(height: 12),
          Text('No reviews yet',
              style: TextStyle(
                  color: textP, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Be the first to review this doctor',
              style: TextStyle(color: textS)),
        ],
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: reviews.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, i) {
      final r = reviews[i];
      final initials = r.patientName != null && r.patientName!.isNotEmpty
          ? r.patientName![0].toUpperCase()
          : 'P';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _teal.withOpacity(0.15),
                  child: Text(initials,
                      style: const TextStyle(
                          color: _teal, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.patientName ?? 'Patient',
                    style: TextStyle(
                        color: textP,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (r.rating != null)
                  Row(
                    children: List.generate(5, (j) => Icon(
                      j < r.rating! ? Icons.star : Icons.star_outline,
                      size: 14,
                      color: const Color(0xFFFFC107),
                    )),
                  ),
              ],
            ),
            if (r.comment != null && r.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(r.comment!,
                  style: TextStyle(color: textS, fontSize: 13, height: 1.5)),
            ],
          ],
        ),
      );
    },
  );
}

  // ── BOTTOM BOOK BAR ───────────────────────────────────────────────────────

  Widget _buildBookBar(bool isDark) {
    final bg = isDark ? const Color(0xFF112240) : Colors.white;
    final textP = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Fee pill
          if (widget.doctor.consultationFee != null) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consultation Fee',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 11)),
                Text(
                  '${widget.doctor.consultationFee!.toStringAsFixed(0)} TND',
                  style: TextStyle(
                      color: textP,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _onBook,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_selectedSlot != null
                  ? 'Book ${_formatTime(_selectedSlot!.startTime)}'
                  : 'Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBook() {
    if (_selectedSlot == null) {
      _tabCtrl.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot first'),
          backgroundColor: _teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _showBookingSheet();
  }

  void _showBookingSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(
        doctor: widget.doctor,
        slot: _selectedSlot!,
        selectedDay: _selectedDay,
        isDark: isDark,
        onConfirmed: (appt) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Appointment booked for ${_formatTime('${appt.appointmentDateTime.hour.toString().padLeft(2, '0')}:${appt.appointmentDateTime.minute.toString().padLeft(2, '0')}')}'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // close detail screen after booking
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Booking Confirmation Sheet
// ─────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final DoctorSearchResponse doctor;
  final TimeSlotResponse slot;
  final DateTime selectedDay;
  final bool isDark;
  final void Function(AppointmentResponse) onConfirmed;

  const _BookingSheet({
    required this.doctor,
    required this.slot,
    required this.selectedDay,
    required this.isDark,
    required this.onConfirmed,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const _teal = Color(0xFF1A9BE8);
  final _appointmentService = AppointmentService();
  final _reasonCtrl = TextEditingController();
  AppointmentType _type = AppointmentType.CONSULTATION;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _fmtTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final mi = parts[1];
    return '${h == 0 ? 12 : h > 12 ? h - 12 : h}:$mi ${h >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> _confirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Build the DateTime from selected day + slot start time
      final parts = widget.slot.startTime.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final mi = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final dt = DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        h, mi,
      );

      final patientId = await SessionStore.getUserId() ?? 0;

      final request = AppointmentRequest(
        patientId: patientId,
        doctorId: widget.doctor.id,
        appointmentDateTime: dt,
        durationMinutes: widget.doctor.consultationDuration ?? 30,
        type: _type,
        reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
        status: AppointmentStatus.PENDING,
      );

      final appt = await _appointmentService.create(request);
      if (mounted) {
        Navigator.pop(context);
        widget.onConfirmed(appt);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg   = isDark ? const Color(0xFF112240) : Colors.white;
    final textP = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textS = isDark ? Colors.white60 : Colors.black54;
    final inputBg = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
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

            // Title
            Text('Confirm Booking',
                style: TextStyle(
                    color: textP, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Dr. ${widget.doctor.fullName}',
                style: const TextStyle(
                    color: _teal, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            // Date & time row
            Row(
              children: [
                _chip(Icons.calendar_today_outlined,
                    _fmtDate(widget.selectedDay), isDark, textP),
                const SizedBox(width: 10),
                _chip(Icons.access_time_outlined,
                    _fmtTime(widget.slot.startTime), isDark, textP),
              ],
            ),
            const SizedBox(height: 20),

            // Type selector
            Text('Appointment Type',
                style: TextStyle(
                    color: textS, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppointmentType.values.map((t) {
                final sel = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? _teal : inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? _teal : (isDark ? Colors.white12 : Colors.black12)),
                    ),
                    child: Text(
                      t.name.replaceAll('_', ' '),
                      style: TextStyle(
                          color: sel ? Colors.white : textS,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Reason field
            Text('Reason (optional)',
                style: TextStyle(
                    color: textS, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: TextField(
                controller: _reasonCtrl,
                style: TextStyle(color: textP, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Annual checkup, tooth pain…',
                  hintStyle: TextStyle(color: textS, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),

            if (_error != null) ...
              [
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: Color(0xFFE53935), fontSize: 12)),
              ],

            const SizedBox(height: 20),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _confirm,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(_loading ? 'Booking…' : 'Confirm Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, bool isDark, Color textP) {
    final bg = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _teal),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: textP, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

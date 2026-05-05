import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/doctor_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  static const _teal = Color(0xFF1A9BE8);

  final DoctorService _service = DoctorService();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // Search / filter state
  String _query = '';
  Specialization? _selectedSpec;
  Timer? _debounce;

  // Pagination state
  List<DoctorSearchResponse> _doctors = [];
  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  // Specialization filter labels
  static const List<Specialization?> _filterSpecs = [
    null, // All
    Specialization.DENTISTRY,
    Specialization.GENERAL_PRACTICE,
    Specialization.CARDIOLOGY,
    Specialization.DERMATOLOGY,
    Specialization.PEDIATRICS,
    Specialization.ORTHOPEDICS,
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadDoctors({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      setState(() {
        _page = 0;
        _doctors = [];
        _hasMore = true;
        _error = null;
        _isLoading = true;
      });
    }
    try {
      final request = DoctorSearchRequest(
        name: _query.isEmpty ? null : _query,
        specialization: _selectedSpec,
        page: 0,
        size: 20,
      );
      final result = await _service.search(request);
      if (mounted) {
        setState(() {
          _doctors = result.content;
          _page = 0;
          _hasMore = !result.last;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final request = DoctorSearchRequest(
        name: _query.isEmpty ? null : _query,
        specialization: _selectedSpec,
        page: _page + 1,
        size: 20,
      );
      final result = await _service.search(request);
      if (mounted) {
        setState(() {
          _page++;
          _doctors.addAll(result.content);
          _hasMore = !result.last;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_query != val) {
        _query = val;
        _loadDoctors(reset: true);
      }
    });
  }

  void _onSpecSelected(Specialization? spec) {
    if (_selectedSpec == spec) return;
    setState(() => _selectedSpec = spec);
    _loadDoctors(reset: true);
  }

  String _specLabel(Specialization? spec, AppLocalizations l) {
    if (spec == null) return l.all;
    switch (spec) {
      case Specialization.DENTISTRY:        return l.dentist;
      case Specialization.GENERAL_PRACTICE: return l.generalPhysician;
      case Specialization.CARDIOLOGY:       return l.cardiologist;
      case Specialization.DERMATOLOGY:      return l.dermatologist;
      case Specialization.PEDIATRICS:       return 'Pediatrics';
      case Specialization.ORTHOPEDICS:      return 'Orthopedics';
      default:
        return spec.name
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Gradient header with functional search ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A9BE8), Color(0xFF0B7FCC)],
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
                      l.findDoctors,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.bookBestSpecialists,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Functional search bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search, color: Colors.black38, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: l.searchDoctor,
                                hintStyle: const TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black38, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearchChanged('');
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A9BE8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Specialization filter chips ────────────────────────────────────
          Container(
            height: 52,
            color: bgColor,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filterSpecs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final spec = _filterSpecs[i];
                final active = _selectedSpec == spec;
                return GestureDetector(
                  onTap: () => _onSpecSelected(spec),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? _teal : cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? _teal : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      _specLabel(spec, l),
                      style: TextStyle(
                        color: active ? Colors.white : textSecondary,
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _buildContent(context, l, cardColor, textPrimary, textSecondary, isDark, bgColor),
          ),
        ],
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
    Color bgColor,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: textSecondary),
            const SizedBox(height: 16),
            Text(
              'Connection error',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: textSecondary, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadDoctors(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: textSecondary),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or filter',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _teal,
      onRefresh: () => _loadDoctors(reset: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: _doctors.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == _doctors.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _teal),
              ),
            );
          }
          return _DoctorCard(
            doctor: _doctors[i],
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Doctor Card Widget
// ─────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final DoctorSearchResponse doctor;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _DoctorCard({
    required this.doctor,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  static const List<Color> _avatarColors = [
    Color(0xFF7986CB),
    Color(0xFF4DB6AC),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFF4FC3F7),
    Color(0xFFA5D6A7),
  ];

  Color get _avatarColor => _avatarColors[doctor.id % _avatarColors.length];

  String get _initials {
    final f = doctor.firstName.isNotEmpty ? doctor.firstName[0] : '';
    final l = doctor.lastName.isNotEmpty ? doctor.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String get _specializationLabel {
    if (doctor.specialization == null) return 'General';
    return doctor.specialization!.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final accepting = doctor.acceptingNewPatients ?? true;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (image or initials)
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dr. ${doctor.fullName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (doctor.averageRating != null && doctor.averageRating! > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            doctor.averageRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          if (doctor.totalReviews != null)
                            Text(
                              ' (${doctor.totalReviews})',
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _specializationLabel,
                  style: TextStyle(
                    color: const Color(0xFF1A9BE8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (doctor.city != null || doctor.address != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          [doctor.address, doctor.city].whereType<String>().join(', '),
                          style: TextStyle(color: textSecondary, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Accepting badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accepting
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        accepting ? 'Accepting Patients' : 'Not Accepting',
                        style: TextStyle(
                          color: accepting
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF57C00),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Consultation fee
                    if (doctor.consultationFee != null)
                      Text(
                        '${doctor.consultationFee!.toStringAsFixed(0)} TND',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                  ],
                ),
                // Experience + spoken languages row
                if (doctor.yearsOfExperience != null || doctor.spokenLanguages != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (doctor.yearsOfExperience != null) ...[
                        Icon(Icons.work_outline, size: 12, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.yearsOfExperience}y exp',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (doctor.spokenLanguages != null) ...[
                        Icon(Icons.translate_outlined, size: 12, color: textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.spokenLanguages!,
                            style: TextStyle(fontSize: 11, color: textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          doctor.profileImageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: _avatarColor.withOpacity(0.15),
      child: Text(
        _initials,
        style: TextStyle(
          color: _avatarColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

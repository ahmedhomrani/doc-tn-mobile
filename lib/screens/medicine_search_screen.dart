import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';
import '../services/base_service.dart';
//import '../models/medicine.dart';

// ─── MODEL ───────────────────────────────────────────────────────────────────

class Medicine {
  final String nomCommercial;
  final String dci;
  final String forme;
  final String dosage;
  final String presentation;
  final double? prix;
  final String classe;
  final String sousClasse;
  final String laboratoire;

  Medicine({
    required this.nomCommercial,
    required this.dci,
    required this.forme,
    required this.dosage,
    required this.presentation,
    this.prix,
    required this.classe,
    required this.sousClasse,
    required this.laboratoire,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        nomCommercial: (json['nomCommercial'] as String? ?? '').trim(),
        dci:           (json['dci']           as String? ?? '').trim(),
        forme:         (json['forme']         as String? ?? '').trim(),
        dosage:        (json['dosage']        as String? ?? '').trim(),
        presentation:  (json['presentation']  as String? ?? '').trim(),
        prix:          (json['prix'] as num?)?.toDouble(),
        classe:        (json['classe']        as String? ?? '').trim(),
        sousClasse:    (json['sousClasse']    as String? ?? '').trim(),
        laboratoire:   (json['laboratoire']   as String? ?? '').trim(),
      );
}

// ─── SERVICE ─────────────────────────────────────────────────────────────────

class MedicineService extends BaseService {

  Future<List<Medicine>> search(String query) async {
    if (query.trim().length < 2) return [];

    final res = await get(
      '/medicaments',
      query: {
        'query': query.trim(),
      },
    );

    final List<dynamic> data = decode(res);

    return data
        .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
// ─── SECTION WIDGET ──────────────────────────────────────────────────────────

class MedicineSearchSection extends StatefulWidget {
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const MedicineSearchSection({
    super.key,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  State<MedicineSearchSection> createState() => _MedicineSearchSectionState();
}

class _MedicineSearchSectionState extends State<MedicineSearchSection> {
  static const _blue = Color(0xFF1A9BE8);

  final _service = MedicineService();
  final _ctrl = TextEditingController();
  Timer? _debounce;

  List<Medicine> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final q = _ctrl.text.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    _debounce?.cancel();
    if (q.length < 2) {
      setState(() {
        _results = [];
        _searched = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _doSearch(q));
  }

  Future<void> _doSearch(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.search(q);
      if (mounted) {
        setState(() {
          _results = res;
          _loading = false;
          _searched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _searched = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
          child: Row(children: [
            const Icon(Icons.medication_outlined, size: 14, color: _blue),
            const SizedBox(width: 5),
            Text(
              l10n.medicineSearchTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: widget.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.local_pharmacy_outlined, size: 14, color: _blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.medicineSearchSubtitle,
                      style: const TextStyle(
                          fontSize: 12, color: _blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildSearchField(l10n),
                const SizedBox(height: 12),
                _buildResults(l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withOpacity(0.07)
            : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _loading
              ? _blue.withOpacity(0.5)
              : widget.isDark
                  ? Colors.white12
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(children: [
        const SizedBox(width: 12),
        _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: _blue, strokeWidth: 2),
              )
            : const Icon(Icons.search, color: _blue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: TextStyle(color: widget.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.medicineSearchHint,
              hintStyle: TextStyle(color: widget.textSecondary, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (_ctrl.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: widget.textSecondary, size: 18),
            onPressed: () {
              _ctrl.clear();
              setState(() {
                _results = [];
                _searched = false;
                _error = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
      ]),
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    if (!_searched && _ctrl.text.trim().length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(Icons.info_outline, size: 16, color: widget.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.medicineTypeToSearch,
              style: TextStyle(color: widget.textSecondary, fontSize: 12),
            ),
          ),
        ]),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 36, color: widget.textSecondary),
          const SizedBox(height: 8),
          Text(l10n.medicineError,
              style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _doSearch(_ctrl.text.trim()),
            icon: const Icon(Icons.refresh, color: _blue, size: 16),
            label: Text(l10n.medicineRetry,
                style: const TextStyle(color: _blue, fontSize: 13)),
          ),
        ]),
      );
    }

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: _blue, strokeWidth: 2),
          const SizedBox(height: 10),
          Text(
            l10n.medicineLoading,
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.textSecondary, fontSize: 12),
          ),
        ]),
      );
    }

    if (_results.isEmpty && _searched) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded, size: 40, color: widget.textSecondary),
          const SizedBox(height: 8),
          Text(
            '${l10n.medicineNoResults} "${_ctrl.text.trim()}"',
            style: TextStyle(
                color: widget.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    return Column(
      children: _results
          .take(30)
          .map((m) => _MedicineTile(
                medicine: m,
                l10n: l10n,
                isDark: widget.isDark,
                cardColor: widget.cardColor,
                textPrimary: widget.textPrimary,
                textSecondary: widget.textSecondary,
              ))
          .toList(),
    );
  }
}

// ─── MEDICINE TILE ───────────────────────────────────────────────────────────

class _MedicineTile extends StatelessWidget {
  final Medicine medicine;
  final AppLocalizations l10n;
  final bool isDark;
  final Color cardColor, textPrimary, textSecondary;

  static const _blue = Color(0xFF1A9BE8);
  static const _green = Color(0xFF22C55E);

  const _MedicineTile({
    required this.medicine,
    required this.l10n,
    required this.isDark,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : _blue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : _blue.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    medicine.nomCommercial,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (medicine.prix != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${medicine.prix!.toStringAsFixed(3)} DT',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // DCI
            if (medicine.dci.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.science_outlined, size: 12, color: textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    medicine.dci,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]),
            ],

            const SizedBox(height: 8),

            // Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (medicine.forme.isNotEmpty)
                  _chip(medicine.forme, Icons.medication_outlined),
                if (medicine.dosage.isNotEmpty)
                  _chip(medicine.dosage, Icons.compress_outlined),
                if (medicine.presentation.isNotEmpty)
                  _chip(medicine.presentation, Icons.inventory_2_outlined),
              ],
            ),

            // Lab + class
            if (medicine.laboratoire.isNotEmpty || medicine.classe.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                height: 1,
              ),
              const SizedBox(height: 8),
              Row(children: [
                if (medicine.laboratoire.isNotEmpty) ...[
                  Icon(Icons.business_outlined, size: 11, color: textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      medicine.laboratoire,
                      style: TextStyle(color: textSecondary, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (medicine.classe.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.category_outlined, size: 11, color: textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      medicine.classe,
                      style: TextStyle(color: textSecondary, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: textSecondary),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

// ─── STANDALONE SCREEN ───────────────────────────────────────────────────────

class MedicineSearchScreen extends StatelessWidget {
  const MedicineSearchScreen({super.key});

  static const _blue = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final bgColor   = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
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
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.medicineSearchTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.medicineSearchSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_outlined, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('CNAM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MedicineSearchSection(
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
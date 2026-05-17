// rappels_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/base_service.dart';
import '../services/clinical_services.dart';

// ─── tiny unified view-model ────────────────────────────
class _ReminderItem {
  final int id;
  final bool isTreatment; // true = Treatment, false = Prescription
  final String name;
  final String subtitle;
  final String? date;
  bool enabled;
  final Color accentColor;

  _ReminderItem({
    required this.id,
    required this.isTreatment,
    required this.name,
    required this.subtitle,
    this.date,
    this.enabled = true,
    required this.accentColor,
  });

  static _ReminderItem fromTreatment(TreatmentResponse t) => _ReminderItem(
        id: t.id,
        isTreatment: true,
        name: t.treatmentName,
        subtitle: [
          if (t.status != null) t.status!.name,
          if (t.toothNumber != null) 'Tooth ${t.toothNumber}',
        ].join(' · '),
        date: t.treatmentDate,
        accentColor: const Color(0xFF1A9BE8),
      );

  static _ReminderItem fromPrescription(PrescriptionResponse p) => _ReminderItem(
        id: p.id,
        isTreatment: false,
        name: p.medications,
        subtitle: [
          if (p.dosage != null) p.dosage!,
          if (p.durationDays != null) '${p.durationDays}d',
        ].join(' · '),
        date: p.prescriptionDate,
        accentColor: const Color(0xFFBA68C8),
      );
}

// ────────────────────────────────────────────────────────
class RappelsScreen extends StatefulWidget {
  const RappelsScreen({super.key});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  static const _blue     = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  final _treatmentSvc    = TreatmentService();
  final _prescriptionSvc = PrescriptionService();

  int _tabIndex = 0;
  bool _loading = true;
  String? _error;

  List<_ReminderItem> _treatments   = [];
  List<_ReminderItem> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── data ──────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final patientId = await SessionStore.getUserId();
      if (patientId == null) throw const ApiException(401, 'Not logged in');

      final results = await Future.wait([
        _treatmentSvc.getByPatient(patientId),
        _prescriptionSvc.getByPatient(patientId),
      ]);

      if (!mounted) return;
      setState(() {
        _treatments    = (results[0] as List<TreatmentResponse>)
            .map(_ReminderItem.fromTreatment).toList();
        _prescriptions = (results[1] as List<PrescriptionResponse>)
            .map(_ReminderItem.fromPrescription).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    }
  }

  Future<void> _delete(_ReminderItem item) async {
    try {
      if (item.isTreatment) {
        await _treatmentSvc.deleteTreatment(item.id);
        setState(() => _treatments.removeWhere((t) => t.id == item.id));
      } else {
        await _prescriptionSvc.deletePrescription(item.id);
        setState(() => _prescriptions.removeWhere((p) => p.id == item.id));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddSheet() async {
    final patientId = await SessionStore.getUserId();
    if (!mounted || patientId == null) return;

    final result = await showModalBottomSheet<_ReminderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(
        patientId: patientId,
        treatmentSvc: _treatmentSvc,
        prescriptionSvc: _prescriptionSvc,
      ),
    );

    if (result != null) {
      setState(() {
        if (result.isTreatment) {
          _treatments.insert(0, result);
        } else {
          _prescriptions.insert(0, result);
        }
      });
    }
  }

  // ── derived lists ──────────────────────────────────────

  List<_ReminderItem> get _visible {
    if (_tabIndex == 1) return _treatments;
    if (_tabIndex == 2) return _prescriptions;
    return [..._treatments, ..._prescriptions];
  }

  int get _activeTreatments    => _treatments.where((t) => t.enabled).length;
  int get _activePrescriptions => _prescriptions.where((p) => p.enabled).length;
  int get _totalActive         => _activeTreatments + _activePrescriptions;

  // ── build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l          = AppLocalizations.of(context)!;
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor  = isDark ? const Color(0xFF112240) : Colors.white;
    final textSec    = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(l),
          _buildTabs(l, cardColor, textSec),
          Expanded(child: _buildBody(l, cardColor, isDark, textSec)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── header ─────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l) {
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.reminders,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  TextButton.icon(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text(l.add,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.stayOnTrack,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStat('$_activeTreatments', l.activeMeds),
                  const SizedBox(width: 10),
                  _buildStat('$_activePrescriptions', l.activeAppts),
                  const SizedBox(width: 10),
                  _buildStat('$_totalActive', l.totalActive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 10)),
            ],
          ),
        ),
      );

  // ── tabs ───────────────────────────────────────────────

  Widget _buildTabs(AppLocalizations l, Color cardColor, Color textSec) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          _buildTab(l.all, 0, textSec),
          _buildTab(l.treatments, 1, textSec),
          _buildTab(l.prescriptions, 2, textSec),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, Color textSec) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? Colors.white : textSec,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              )),
        ),
      ),
    );
  }

  // ── list body ──────────────────────────────────────────

  Widget _buildBody(
      AppLocalizations l, Color cardColor, bool isDark, Color textSec) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: Text(l.retry)),
          ],
        ),
      );
    }
    final items = _visible;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 60,
                color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 12),
            Text(l.noReminders,
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(items[i], cardColor, isDark, textSec, l),
      ),
    );
  }

  // ── card ───────────────────────────────────────────────

  Widget _buildCard(_ReminderItem item, Color cardColor, bool isDark,
      Color textSec, AppLocalizations l) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0D1B2E);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: item.enabled
            ? Border(left: BorderSide(color: item.accentColor, width: 3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.enabled
                        ? item.accentColor.withOpacity(0.12)
                        : (isDark ? Colors.white10 : const Color(0xFFF2F2F2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.isTreatment ? Icons.medical_services_outlined : Icons.medication,
                    color: item.enabled ? item.accentColor : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: item.enabled
                                      ? textPrimary
                                      : (isDark ? Colors.white38 : Colors.black38),
                                  decoration: item.enabled
                                      ? null
                                      : TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                )),
                          ),
                          // type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.isTreatment
                                  ? const Color(0xFF1A9BE8).withOpacity(0.12)
                                  : const Color(0xFFBA68C8).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.isTreatment ? l.treatment : l.prescription,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.subtitle.isNotEmpty)
                        Text(item.subtitle,
                            style: TextStyle(
                                color: item.enabled ? textSec : Colors.black26,
                                fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: item.enabled,
                  onChanged: (v) => setState(() => item.enabled = v),
                  activeColor: _blue,
                  activeTrackColor: _blue.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                ),
              ],
            ),

            if (item.date != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 13,
                        color: item.enabled ? _blue : Colors.grey.shade400),
                    const SizedBox(width: 5),
                    Text(item.date!,
                        style: TextStyle(
                          color: item.enabled ? _blue : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.07),
              height: 1,
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _delete(item),
                icon: const Icon(Icons.delete_outline,
                    size: 15, color: Color(0xFFE53935)),
                label: Text(l.delete,
                    style: const TextStyle(
                        color: Color(0xFFE53935), fontSize: 13)),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add-reminder bottom sheet
// ─────────────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  final int patientId;
  final TreatmentService treatmentSvc;
  final PrescriptionService prescriptionSvc;

  const _AddReminderSheet({
    required this.patientId,
    required this.treatmentSvc,
    required this.prescriptionSvc,
  });

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  static const _blue = Color(0xFF1A9BE8);

  int _sheetTab = 0; // 0 = Treatment (doctor), 1 = Prescription (self)
  bool _saving = false;

  // Treatment fields
  final _treatNameCtrl = TextEditingController();
  final _treatDescCtrl = TextEditingController();
  final _treatNotesCtrl = TextEditingController();
  TreatmentStatus _treatStatus = TreatmentStatus.PLANNED;
  DateTime? _treatDate;

  // Prescription fields
  final _medCtrl          = TextEditingController();
  final _dosageCtrl       = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  int _durationDays = 7;
  DateTime? _prescDate;

  @override
  void dispose() {
    _treatNameCtrl.dispose();
    _treatDescCtrl.dispose();
    _treatNotesCtrl.dispose();
    _medCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  // ── save ────────────────────────────────────────────────

  Future<void> _save() async {
    if (_sheetTab == 0 && _treatNameCtrl.text.trim().isEmpty) return;
    if (_sheetTab == 1 && _medCtrl.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      if (_sheetTab == 0) {
        final res = await widget.treatmentSvc.create(TreatmentRequest(
          patientId: widget.patientId,
          treatmentName: _treatNameCtrl.text.trim(),
          description: _treatDescCtrl.text.trim().isEmpty
              ? null
              : _treatDescCtrl.text.trim(),
          notes: _treatNotesCtrl.text.trim().isEmpty
              ? null
              : _treatNotesCtrl.text.trim(),
          status: _treatStatus,
          treatmentDate: _treatDate != null
              ? '${_treatDate!.year}-${_treatDate!.month.toString().padLeft(2,'0')}-${_treatDate!.day.toString().padLeft(2,'0')}'
              : null,
        ));
        if (mounted) {
          Navigator.pop(context, _ReminderItem.fromTreatment(res));
        }
      } else {
        final res = await widget.prescriptionSvc.create(PrescriptionRequest(
          patientId: widget.patientId,
          medications: _medCtrl.text.trim(),
          dosage: _dosageCtrl.text.trim().isEmpty
              ? null
              : _dosageCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          durationDays: _durationDays,
          prescriptionDate: _prescDate != null
              ? '${_prescDate!.year}-${_prescDate!.month.toString().padLeft(2,'0')}-${_prescDate!.day.toString().padLeft(2,'0')}'
              : null,
        ));
        if (mounted) {
          Navigator.pop(context, _ReminderItem.fromPrescription(res));
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── date picker ────────────────────────────────────────

  Future<DateTime?> _pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _blue),
          ),
          child: child!,
        ),
      );

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l          = AppLocalizations.of(context)!;
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final cardBg     = isDark ? const Color(0xFF112240) : Colors.white;
    final bgField    = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF7FAFF);
    final textPri    = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textHint   = isDark ? Colors.white38 : Colors.black38;
    final borderCol  = isDark ? Colors.white12 : const Color(0xFFDDE8F5);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        child: Column(
          children: [
            // drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text(l.newReminder,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textPri)),
                  const SizedBox(height: 16),

                  // tab switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _tabBtn(0, '🩺  ${l.treatment}', isDark),
                        _tabBtn(1, '💊  ${l.prescription}', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_sheetTab == 0)
                    ..._treatmentForm(bgField, textPri, textHint, borderCol, l)
                  else
                    ..._prescriptionForm(bgField, textPri, textHint, borderCol, l),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white54 : Colors.black54,
                            side: BorderSide(color: borderCol),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(l.cancel,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : Text(l.save,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── treatment form ─────────────────────────────────────

  List<Widget> _treatmentForm(Color bg, Color textPri, Color hint,
      Color border, AppLocalizations l) {
    return [
      _label(l.treatmentName, hint),
      const SizedBox(height: 6),
      _field(_treatNameCtrl, l.treatmentNameHint, bg, textPri, hint, border),
      const SizedBox(height: 16),

      _label(l.description, hint),
      const SizedBox(height: 6),
      _field(_treatDescCtrl, l.descriptionHint, bg, textPri, hint, border, maxLines: 2),
      const SizedBox(height: 16),

      _label(l.notes, hint),
      const SizedBox(height: 6),
      _field(_treatNotesCtrl, l.notesHint, bg, textPri, hint, border, maxLines: 2),
      const SizedBox(height: 16),

      _label(l.status, hint),
      const SizedBox(height: 6),
      _statusDropdown(bg, textPri, border, l),
      const SizedBox(height: 16),

      _label(l.date, hint),
      const SizedBox(height: 6),
      _datePicker(
        value: _treatDate,
        hint: l.selectDate,
        bg: bg,
        textPri: textPri,
        border: border,
        onTap: () async {
          final d = await _pickDate();
          if (d != null) setState(() => _treatDate = d);
        },
      ),
    ];
  }

  // ── prescription form ──────────────────────────────────

  List<Widget> _prescriptionForm(Color bg, Color textPri, Color hint,
      Color border, AppLocalizations l) {
    return [
      _label(l.medicationName, hint),
      const SizedBox(height: 6),
      _field(_medCtrl, l.medicationHint, bg, textPri, hint, border),
      const SizedBox(height: 16),

      _label(l.dosage, hint),
      const SizedBox(height: 6),
      _field(_dosageCtrl, l.dosageHint, bg, textPri, hint, border),
      const SizedBox(height: 16),

      _label(l.instructions, hint),
      const SizedBox(height: 6),
      _field(_instructionsCtrl, l.instructionsHint, bg, textPri, hint, border,
          maxLines: 2),
      const SizedBox(height: 16),

      _label(l.durationDays, hint),
      const SizedBox(height: 6),
      _durationSelector(bg, textPri, border),
      const SizedBox(height: 16),

      _label(l.date, hint),
      const SizedBox(height: 6),
      _datePicker(
        value: _prescDate,
        hint: l.selectDate,
        bg: bg,
        textPri: textPri,
        border: border,
        onTap: () async {
          final d = await _pickDate();
          if (d != null) setState(() => _prescDate = d);
        },
      ),
    ];
  }

  // ── small helpers ──────────────────────────────────────

  Widget _tabBtn(int idx, String label, bool isDark) {
    final active = _sheetTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sheetTab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.black54),
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              )),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8));

  Widget _field(
    TextEditingController ctrl,
    String hint,
    Color bg,
    Color textPri,
    Color textHint,
    Color border, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: textPri, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textHint, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _datePicker({
    required DateTime? value,
    required String hint,
    required Color bg,
    required Color textPri,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Text(
              value != null ? _fmt(value) : hint,
              style: TextStyle(
                color: value != null ? textPri : textPri.withOpacity(0.4),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today_outlined,
                color: textPri.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusDropdown(
      Color bg, Color textPri, Color border, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TreatmentStatus>(
          value: _treatStatus,
          isExpanded: true,
          dropdownColor: bg,
          style: TextStyle(color: textPri, fontSize: 15),
          items: TreatmentStatus.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _treatStatus = v);
          },
        ),
      ),
    );
  }

  Widget _durationSelector(Color bg, Color textPri, Color border) {
    final options = [3, 5, 7, 10, 14, 30];
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((d) {
        final sel = _durationDays == d;
        return GestureDetector(
          onTap: () => setState(() => _durationDays = d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _blue : bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? _blue : border),
            ),
            child: Text('${d}d',
                style: TextStyle(
                  color: sel ? Colors.white : textPri,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ),
        );
      }).toList(),
    );
  }
}
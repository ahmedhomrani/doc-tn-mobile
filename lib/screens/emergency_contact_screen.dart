import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/base_service.dart';
import '../services/patient_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  static const _blue     = Color(0xFF1A9BE8);
  static const _red      = Color(0xFFE53935);

  final _formKey = GlobalKey<FormState>();
  final _svc = PatientService();

  bool _loading = true;
  bool _saving  = false;
  String? _error;
  int? _patientId;

  final _emNameCtrl  = TextEditingController();
  final _emPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _emNameCtrl.dispose();
    _emPhoneCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _svc.getMyProfile();
      _patientId      = p.id;
      _emNameCtrl.text  = p.emergencyContactName ?? '';
      _emPhoneCtrl.text = p.emergencyContactPhone ?? '';
      if (mounted) setState(() => _loading = false);
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────────

  Future<void> _save(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final request = PatientRequest(
      emergencyContactName:  _emNameCtrl.text.trim().isNotEmpty  ? _emNameCtrl.text.trim()  : null,
      emergencyContactPhone: _emPhoneCtrl.text.trim().isNotEmpty ? _emPhoneCtrl.text.trim() : null,
    );

    try {
      if (_patientId != null) {
        await _svc.patchPatient(_patientId!, request);
      } else {
        await _svc.create(request);
      }
      if (mounted) {
        _showSnack(l.ecSaved, isError: false);
        setState(() => _saving = false);
      }
    } on ApiException catch (e) {
      if (mounted) { _showSnack(e.message, isError: true); setState(() => _saving = false); }
    } catch (_) {
      if (mounted) { _showSnack(l.ecErrorSave, isError: true); setState(() => _saving = false); }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? _red : _blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l           = AppLocalizations.of(context)!;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor   = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(l, isDark),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : _error != null
                    ? _buildError(l, textPrimary, textSecondary)
                    : _buildForm(l, isDark, cardColor, textPrimary, textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_red, Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.ecTitle,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text(l.ecSubtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────────

  Widget _buildError(AppLocalizations l, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 64, color: textSecondary),
        const SizedBox(height: 16),
        Text(_error!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _loadProfile,
          icon: const Icon(Icons.refresh, color: _blue),
          label: const Text('Retry', style: TextStyle(color: _blue)),
        ),
      ]),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────────

  Widget _buildForm(AppLocalizations l, bool isDark, Color cardColor,
      Color textPrimary, Color textSecondary) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // — Info banner —
          _buildInfoBanner(l, isDark),
          const SizedBox(height: 20),

          // — Contact card —
          _sectionHeader(l.ecSectionContact, textSecondary),
          _card(cardColor, isDark, [
            _field(
              label: l.ecName,
              ctrl: _emNameCtrl,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
              icon: Icons.contact_emergency_outlined,
              iconColor: _red,
              hint: l.ecNameHint,
            ),
            _divider(isDark),
            _field(
              label: l.ecPhone,
              ctrl: _emPhoneCtrl,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
              icon: Icons.phone_in_talk_outlined,
              iconColor: _red,
              type: TextInputType.phone,
              hint: l.ecPhoneHint,
            ),
          ]),

          const SizedBox(height: 28),
          _buildSaveButton(l),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Info banner ───────────────────────────────────────────────────────────────

  Widget _buildInfoBanner(AppLocalizations l, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emergency_outlined, color: _red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.ecBannerText,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF5D0000),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 0.8)),
    );
  }

  Widget _card(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _divider(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1,
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
  );

  Widget _field(
      {required String label,
      required TextEditingController ctrl,
      required Color textPrimary,
      required Color textSecondary,
      required bool isDark,
      required IconData icon,
      Color? iconColor,
      String? hint,
      TextInputType type = TextInputType.text}) {
    final color = iconColor ?? _blue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: color, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDeco(textSecondary, isDark, hint),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(Color hint, bool isDark, [String? hintText]) => InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F7FF),
    hintText: hintText,
    hintStyle: TextStyle(color: hint, fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _red, width: 1.5),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
  );

  Widget _buildSaveButton(AppLocalizations l) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _saving ? null : () => _save(l),
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _red.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _saving
              ? Row(key: const ValueKey('saving'), mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text(l.ecSaving, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ])
              : Row(key: const ValueKey('save'), mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(l.ecSave, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
        ),
      ),
    );
  }
}

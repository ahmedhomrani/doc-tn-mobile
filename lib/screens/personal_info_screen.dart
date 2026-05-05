import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/base_service.dart';
import '../services/patient_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  static const _blue = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);

  final _formKey = GlobalKey<FormState>();
  final _svc = PatientService();

  // Loading states
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int? _patientId;

  // Controllers — Basic
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _postalCtrl    = TextEditingController();

  // Controllers — Health
  final _ageCtrl    = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  // Controllers — Medical
  final _historyCtrl   = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  // Controllers — Emergency
  final _emNameCtrl  = TextEditingController();
  final _emPhoneCtrl = TextEditingController();

  // Dropdowns
  Gender?  _gender;
  String?  _bloodType;
  DateTime? _dob;

  static const _bloodTypes = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl,
      _addressCtrl, _cityCtrl, _postalCtrl, _ageCtrl,
      _weightCtrl, _heightCtrl, _historyCtrl, _allergiesCtrl,
      _emNameCtrl, _emPhoneCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _svc.getMyProfile();
      _patientId = p.id;
      _firstNameCtrl.text = p.firstName;
      _lastNameCtrl.text  = p.lastName;
      _emailCtrl.text     = p.email ?? '';
      _phoneCtrl.text     = p.phoneNumber ?? '';
      _addressCtrl.text   = p.address ?? '';
      _cityCtrl.text      = p.city ?? '';
      _postalCtrl.text    = p.postalCode ?? '';
      _historyCtrl.text   = p.medicalHistory ?? '';
      _allergiesCtrl.text = p.allergies ?? '';
      _emNameCtrl.text    = p.emergencyContactName ?? '';
      _emPhoneCtrl.text   = p.emergencyContactPhone ?? '';
      _ageCtrl.text       = p.age ?? '';
      _weightCtrl.text    = p.weight ?? '';
      _heightCtrl.text    = p.height ?? '';
      _bloodType          = p.bloodType;
      _gender             = p.gender;
      if (p.dateOfBirth != null) {
        _dob = DateTime.tryParse(p.dateOfBirth!);
      }
      if (mounted) setState(() => _loading = false);
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final request = PatientRequest(
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      email:     _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phoneNumber: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      dateOfBirth: _dob != null
          ? '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}'
          : null,
      gender:    _gender,
      address:   _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      city:      _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
      postalCode:_postalCtrl.text.trim().isNotEmpty ? _postalCtrl.text.trim() : null,
      age:       _ageCtrl.text.trim().isNotEmpty ? _ageCtrl.text.trim() : null,
      weight:    _weightCtrl.text.trim().isNotEmpty ? _weightCtrl.text.trim() : null,
      height:    _heightCtrl.text.trim().isNotEmpty ? _heightCtrl.text.trim() : null,
      bloodType: _bloodType,
      medicalHistory: _historyCtrl.text.trim().isNotEmpty ? _historyCtrl.text.trim() : null,
      allergies: _allergiesCtrl.text.trim().isNotEmpty ? _allergiesCtrl.text.trim() : null,
      emergencyContactName:  _emNameCtrl.text.trim().isNotEmpty ? _emNameCtrl.text.trim() : null,
      emergencyContactPhone: _emPhoneCtrl.text.trim().isNotEmpty ? _emPhoneCtrl.text.trim() : null,
    );

    try {
      if (_patientId != null) {
        await _svc.patchPatient(_patientId!, request);
      } else {
        await _svc.create(request);
      }
      if (mounted) {
        _showSnack(l.piSaved, isError: false);
        setState(() => _saving = false);
      }
    } on ApiException catch (e) {
      if (mounted) { _showSnack(e.message, isError: true); setState(() => _saving = false); }
    } catch (_) {
      if (mounted) { _showSnack(l.piErrorSave, isError: true); setState(() => _saving = false); }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? const Color(0xFFE53935) : _blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _blue,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
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
                    : _buildForm(l, isDark, bgColor, cardColor, textPrimary, textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l, bool isDark) {
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
                    Text(l.piTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text(l.piSubtitle,
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

  // ── Error ──────────────────────────────────────────────────────────────────

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

  // ── Form ───────────────────────────────────────────────────────────────────

  Widget _buildForm(AppLocalizations l, bool isDark, Color bgColor,
      Color cardColor, Color textPrimary, Color textSecondary) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BASIC INFO
          _sectionHeader(l.piSectionBasic, textSecondary),
          _card(cardColor, isDark, [
            _row([
              _field(l.piFirstName, _firstNameCtrl, textPrimary, textSecondary, isDark, icon: Icons.person_outline),
              const SizedBox(width: 12),
              _field(l.piLastName, _lastNameCtrl, textPrimary, textSecondary, isDark, icon: Icons.person_outline),
            ]),
            _divider(isDark),
            _field(l.piEmail, _emailCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.email_outlined, type: TextInputType.emailAddress),
            _divider(isDark),
            _field(l.piPhone, _phoneCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.phone_outlined, type: TextInputType.phone),
            _divider(isDark),
            // Date of Birth
            _dobRow(l, textPrimary, textSecondary, isDark),
            _divider(isDark),
            // Gender
            _genderRow(l, textPrimary, textSecondary, isDark),
            _divider(isDark),
            _field(l.piAddress, _addressCtrl, textPrimary, textSecondary, isDark, icon: Icons.home_outlined),
            _divider(isDark),
            _row([
              _field(l.piCity, _cityCtrl, textPrimary, textSecondary, isDark, icon: Icons.location_city_outlined),
              const SizedBox(width: 12),
              _field(l.piPostalCode, _postalCtrl, textPrimary, textSecondary, isDark,
                  icon: Icons.markunread_mailbox_outlined, type: TextInputType.number),
            ]),
          ]),

          const SizedBox(height: 16),

          // HEALTH METRICS
          _sectionHeader(l.piSectionHealth, textSecondary),
          _card(cardColor, isDark, [
            _row([
              _metricField(l.piAge, _ageCtrl, l.piYears, textPrimary, textSecondary, isDark, Icons.cake_outlined),
              const SizedBox(width: 12),
              _metricField(l.piWeight, _weightCtrl, l.piKg, textPrimary, textSecondary, isDark, Icons.monitor_weight_outlined),
              const SizedBox(width: 12),
              _metricField(l.piHeight, _heightCtrl, l.piCm, textPrimary, textSecondary, isDark, Icons.height),
            ]),
            _divider(isDark),
            _bloodTypeRow(l, textPrimary, textSecondary, isDark),
          ]),

          const SizedBox(height: 16),

          // MEDICAL HISTORY
          _sectionHeader(l.piSectionMedical, textSecondary),
          _card(cardColor, isDark, [
            _multilineField(l.piMedicalHistory, _historyCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.history_edu_outlined),
            _divider(isDark),
            _multilineField(l.piAllergies, _allergiesCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.warning_amber_outlined, iconColor: const Color(0xFFFF9800)),
          ]),

          const SizedBox(height: 16),

          // EMERGENCY CONTACT
          _sectionHeader(l.piSectionEmergency, textSecondary),
          _card(cardColor, isDark, [
            _field(l.piEmergencyName, _emNameCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.contact_emergency_outlined),
            _divider(isDark),
            _field(l.piEmergencyPhone, _emPhoneCtrl, textPrimary, textSecondary, isDark,
                icon: Icons.phone_in_talk_outlined, type: TextInputType.phone),
          ]),

          const SizedBox(height: 28),

          // Save Button
          _buildSaveButton(l),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────

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

  Widget _row(List<Widget> children) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((c) =>
        c is SizedBox ? c : Expanded(child: c)).toList());

  Widget _field(String label, TextEditingController ctrl,
      Color textPrimary, Color textSecondary, bool isDark, {
        required IconData icon,
        Color? iconColor,
        TextInputType type = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: iconColor ?? _blue),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: iconColor ?? _blue, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDeco(textSecondary, isDark),
        ),
      ],
    );
  }

  Widget _multilineField(String label, TextEditingController ctrl,
      Color textPrimary, Color textSecondary, bool isDark, {
        required IconData icon, Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: iconColor ?? _blue),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: iconColor ?? _blue, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: 3,
          style: TextStyle(color: textPrimary, fontSize: 14),
          decoration: _inputDeco(textSecondary, isDark),
        ),
      ],
    );
  }

  Widget _metricField(String label, TextEditingController ctrl, String unit,
      Color textPrimary, Color textSecondary, bool isDark, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 13, color: _blue),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: _blue, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: _inputDeco(textSecondary, isDark).copyWith(suffixText: unit,
              suffixStyle: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _dobRow(AppLocalizations l, Color textPrimary, Color textSecondary, bool isDark) {
    final dobText = _dob != null
        ? '${_dob!.day.toString().padLeft(2,'0')}/${_dob!.month.toString().padLeft(2,'0')}/${_dob!.year}'
        : '';
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.cake_outlined, size: 14, color: _blue),
          const SizedBox(width: 5),
          Text(l.piDob, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: _blue, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Expanded(child: Text(
              dobText.isNotEmpty ? dobText : '—',
              style: TextStyle(
                color: dobText.isNotEmpty ? textPrimary : textSecondary,
                fontSize: 14, fontWeight: FontWeight.w500,
              ),
            )),
            Icon(Icons.calendar_today_outlined, size: 16, color: textSecondary),
          ]),
        ),
      ]),
    );
  }

  Widget _genderRow(AppLocalizations l, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.wc_outlined, size: 14, color: _blue),
        const SizedBox(width: 5),
        Text(l.piGender, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: _blue, letterSpacing: 0.3)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _genderChip(l.piGenderMale, Gender.MALE, textPrimary, isDark),
        const SizedBox(width: 10),
        _genderChip(l.piGenderFemale, Gender.FEMALE, textPrimary, isDark),
      ]),
    ]);
  }

  Widget _genderChip(String label, Gender value, Color textPrimary, bool isDark) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _blue : (isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFF0F7FF)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _blue : (isDark ? Colors.white24 : Colors.black.withOpacity(0.1)),
            width: 1.5,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            value == Gender.MALE ? Icons.male : Icons.female,
            color: selected ? Colors.white : textPrimary, size: 18,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            color: selected ? Colors.white : textPrimary,
            fontWeight: FontWeight.w600, fontSize: 13,
          )),
        ]),
      ),
    );
  }

  Widget _bloodTypeRow(AppLocalizations l, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.bloodtype_outlined, size: 14, color: Color(0xFFE53935)),
        const SizedBox(width: 5),
        Text(l.piBloodType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: Color(0xFFE53935), letterSpacing: 0.3)),
      ]),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _bloodTypes.map((bt) {
          final selected = _bloodType == bt;
          return GestureDetector(
            onTap: () => setState(() => _bloodType = bt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, height: 40,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE53935) : (isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFFFF0F0)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? const Color(0xFFE53935) : (isDark ? Colors.white24 : const Color(0xFFE53935).withOpacity(0.3)),
                  width: 1.5,
                ),
              ),
              child: Center(child: Text(bt, style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFE53935),
                fontWeight: FontWeight.w700, fontSize: 13,
              ))),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  InputDecoration _inputDeco(Color hint, bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F7FF),
    hintStyle: TextStyle(color: hint, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _blue, width: 1.5),
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
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _blue.withOpacity(0.6),
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
                  Text(l.piSaving, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ])
              : Row(key: const ValueKey('save'), mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(l.piSave, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
        ),
      ),
    );
  }
}

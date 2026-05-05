import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class RappelsScreen extends StatefulWidget {
  const RappelsScreen({super.key});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  int _tabIndex = 0;

  static const _blue = Color(0xFF1A9BE8);
  static const _blueDark = Color(0xFF0B7FCC);

  final List<Map<String, dynamic>> _medReminders = [
    {
      'name': 'Lisinopril 10mg',
      'category': 'Blood Pressure · Once daily',
      'time': '8:00 AM',
      'enabled': true,
      'pillColor': Color(0xFF1A9BE8),
      'days': [false, true, true, true, true, true, false],
    },
    {
      'name': 'Metformin 500mg',
      'category': 'Blood Sugar · Twice daily',
      'time': '1:00 PM',
      'enabled': true,
      'pillColor': Color(0xFFBA68C8),
      'days': [false, true, true, true, true, true, false],
    },
    {
      'name': 'Atorvastatin 20mg',
      'category': 'Cholesterol · Once daily',
      'time': '9:00 PM',
      'enabled': false,
      'pillColor': Color(0xFFFF8A65),
      'days': [true, true, true, true, true, true, true],
    },
  ];

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddReminderSheet(),
    );
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
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────
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
                          onPressed: _showAddReminderSheet,
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: Text(
                            l.add,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white24,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      children: [
                        _buildStat('2', l.activeMeds),
                        const SizedBox(width: 10),
                        _buildStat('2', l.activeAppts),
                        const SizedBox(width: 10),
                        _buildStat('4', l.totalActive),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter tabs ───────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
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

          // ── List ──────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  pillColor: rem['pillColor'] as Color,
                  days: rem['days'] as List<bool>,
                  index: i,
                  l: l,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderSheet,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
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
            color: active ? _blue : Colors.transparent,
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
    required List<bool> days,
    required int index,
    required AppLocalizations l,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: enabled
            ? Border(left: BorderSide(color: pillColor, width: 3))
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
            // Top row: icon + name + switch
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: enabled
                        ? pillColor.withOpacity(0.12)
                        : (isDark ? Colors.white10 : const Color(0xFFF2F2F2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: enabled ? pillColor : Colors.grey.shade400,
                    size: 26,
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
                          color: enabled
                              ? textPrimary
                              : (isDark ? Colors.white38 : Colors.black38),
                          decoration: enabled ? null : TextDecoration.lineThrough,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      Text(
                        category,
                        style: TextStyle(
                          color: enabled ? textSecondary : Colors.black26,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (v) => setState(() => _medReminders[index]['enabled'] = v),
                  activeColor: _blue,
                  activeTrackColor: _blue.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time + day circles
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_outlined, size: 13,
                          color: enabled ? _blue : Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: TextStyle(
                          color: enabled ? _blue : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_dayLabels.length, (d) {
                      final active = days[d];
                      return Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: active && enabled
                              ? _blue
                              : (isDark ? Colors.white10 : const Color(0xFFEEEEEE)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _dayLabels[d],
                            style: TextStyle(
                              color: active && enabled
                                  ? Colors.white
                                  : (isDark ? Colors.white38 : Colors.black38),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Divider(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.07),
              height: 1,
            ),
            const SizedBox(height: 8),

            // Delete button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _medReminders.removeAt(index));
                },
                icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFE53935)),
                label: Text(
                  l.delete,
                  style: const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
// "Nouveau Rappel" bottom sheet
// ─────────────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  static const _blue = Color(0xFF1A9BE8);

  int _sheetTab = 0; // 0 = Médicament, 1 = Rendez-vous
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  // Day selection: Su Mo Tu We Th Fr Sa
  final List<bool> _days = [false, true, true, true, true, true, false];
  static const _dayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _blue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF112240) : Colors.white;
    final bgField = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF7FAFF);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textHint = isDark ? Colors.white38 : Colors.black38;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFDDE8F5);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
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
                  // Title
                  Text(
                    'Nouveau Rappel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab switcher: Médicament | Rendez-vous
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _sheetTabBtn(0, '💊  Médicament', isDark),
                        _sheetTabBtn(1, '📅  Rendez-vous', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_sheetTab == 0) ..._buildMedForm(bgField, textPrimary, textHint, borderColor, isDark)
                  else ..._buildApptForm(bgField, textPrimary, textHint, borderColor, isDark),

                  const SizedBox(height: 28),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white54 : Colors.black54,
                            side: BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700)),
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

  List<Widget> _buildMedForm(
    Color bgField, Color textPrimary, Color textHint, Color borderColor, bool isDark) {
    return [
      _fieldLabel('NOM DU MÉDICAMENT', textHint),
      const SizedBox(height: 6),
      _inputField(
        controller: _nameCtrl,
        hint: 'e.g. Lisinopril 10mg',
        bgField: bgField,
        textPrimary: textPrimary,
        textHint: textHint,
        borderColor: borderColor,
      ),
      const SizedBox(height: 16),

      _fieldLabel('DOSAGE & FRÉQUENCE', textHint),
      const SizedBox(height: 6),
      _inputField(
        controller: _doseCtrl,
        hint: 'e.g. Once daily, Morning',
        bgField: bgField,
        textPrimary: textPrimary,
        textHint: textHint,
        borderColor: borderColor,
      ),
      const SizedBox(height: 16),

      _fieldLabel('HEURE DU RAPPEL', textHint),
      const SizedBox(height: 6),
      _timePicker(bgField, textPrimary, borderColor, isDark),
      const SizedBox(height: 16),

      _fieldLabel('RÉPÉTER LES JOURS', textHint),
      const SizedBox(height: 10),
      _daySelector(),
    ];
  }

  List<Widget> _buildApptForm(
    Color bgField, Color textPrimary, Color textHint, Color borderColor, bool isDark) {
    return [
      _fieldLabel('NOM DU MÉDECIN', textHint),
      const SizedBox(height: 6),
      _inputField(
        controller: _nameCtrl,
        hint: 'e.g. Dr. Ahmed Ben Ali',
        bgField: bgField,
        textPrimary: textPrimary,
        textHint: textHint,
        borderColor: borderColor,
      ),
      const SizedBox(height: 16),

      _fieldLabel('SPÉCIALITÉ', textHint),
      const SizedBox(height: 6),
      _inputField(
        controller: _doseCtrl,
        hint: 'e.g. Cardiologue',
        bgField: bgField,
        textPrimary: textPrimary,
        textHint: textHint,
        borderColor: borderColor,
      ),
      const SizedBox(height: 16),

      _fieldLabel('DATE & HEURE', textHint),
      const SizedBox(height: 6),
      _timePicker(bgField, textPrimary, borderColor, isDark),
      const SizedBox(height: 16),

      _fieldLabel('RAPPEL AVANT', textHint),
      const SizedBox(height: 10),
      _reminderBeforeSelector(bgField, textPrimary, textHint, borderColor),
    ];
  }

  Widget _sheetTabBtn(int idx, String label, bool isDark) {
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required Color bgField,
    required Color textPrimary,
    required Color textHint,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textHint, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _timePicker(Color bgField, Color textPrimary, Color borderColor, bool isDark) {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgField,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Text(
              _formatTime(_time),
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.access_time, color: isDark ? Colors.white38 : Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _daySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_dayLabels.length, (i) {
        final active = _days[i];
        return GestureDetector(
          onTap: () => setState(() => _days[i] = !_days[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? _blue : const Color(0xFFF0F7FF),
              shape: BoxShape.circle,
              boxShadow: active
                  ? [BoxShadow(color: _blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Center(
              child: Text(
                _dayLabels[i],
                style: TextStyle(
                  color: active ? Colors.white : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _reminderBeforeSelector(
      Color bgField, Color textPrimary, Color textHint, Color borderColor) {
    final options = ['15 min', '30 min', '1 heure', '1 jour'];
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((opt) {
        final sel = opt == '30 min';
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _blue : bgField,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? _blue : borderColor),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: sel ? Colors.white : textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

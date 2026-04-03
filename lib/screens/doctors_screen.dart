import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int _selectedFilter = 0;

  static const _teal = Color(0xFF00897B);

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Emily Chen',
      'specialty': 'Cardiologist',
      'clinic': 'City Medical Center · Downtown',
      'rating': 4.9,
      'available': true,
      'availabilityLabel': 'availableToday',
      'time': '10:30 AM',
      'initials': 'EC',
      'color': Color(0xFF7986CB),
    },
    {
      'name': 'Dr. Mark Rivera',
      'specialty': 'General Physician',
      'clinic': 'HealthFirst Clinic · Midtown',
      'rating': 4.7,
      'available': false,
      'availabilityLabel': 'tomorrow',
      'time': '9:00 AM',
      'initials': 'MR',
      'color': Color(0xFF4DB6AC),
    },
    {
      'name': 'Dr. Lisa Park',
      'specialty': 'Dermatologist',
      'clinic': 'SkinCare Clinic · Uptown',
      'rating': 4.8,
      'available': true,
      'availabilityLabel': 'availableToday',
      'time': '2:00 PM',
      'initials': 'LP',
      'color': Color(0xFFBA68C8),
    },
    {
      'name': 'Dr. James Wilson',
      'specialty': 'Cardiologist',
      'clinic': 'Heart Care Center · Westside',
      'rating': 4.6,
      'available': true,
      'availabilityLabel': 'availableToday',
      'time': '3:30 PM',
      'initials': 'JW',
      'color': Color(0xFFFF8A65),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final filterLabels = [
      l.all,
      l.cardiologist,
      l.generalPhysician,
      l.dermatologist,
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Green header
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
                    // Search bar
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
                            child: Text(
                              l.searchDoctor,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B),
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

          // Filter chips
          Container(
            height: 56,
            color: bgColor,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: filterLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final active = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? _teal : cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? _teal : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      filterLabels[i],
                      style: TextStyle(
                        color: active ? Colors.white : textSecondary,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Doctor list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: _doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final doc = _doctors[i];
                final available = doc['available'] as bool;
                final labelKey = doc['availabilityLabel'] as String;
                final availLabel = labelKey == 'availableToday'
                    ? l.availableToday
                    : l.tomorrow;

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
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: (doc['color'] as Color).withOpacity(0.15),
                        child: Text(
                          doc['initials'] as String,
                          style: TextStyle(
                            color: doc['color'] as Color,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    doc['name'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${doc['rating']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doc['specialty'] as String,
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 12, color: textSecondary),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    doc['clinic'] as String,
                                    style: TextStyle(color: textSecondary, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.black26, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: available
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF8E1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    availLabel,
                                    style: TextStyle(
                                      color: available
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFF57C00),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined,
                                        size: 12, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${l.nextSlot} : ${doc['time']}',
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/support_services.dart';
import '../services/socket_service.dart';
import '../services/base_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  static const _teal = Color(0xFF1A9BE8);
  final NotificationService _service = NotificationService();
  StreamSubscription<SocketNotification>? _socketSub;

  List<NotificationResponse> _notifications = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _load();
    _subscribeSocket();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _subscribeSocket() {
    _socketSub = SocketService.instance.onNotification.listen((notif) {
      if (!mounted) return;
      setState(() {
        // Prepend real-time notification (avoid duplicates)
        if (!_notifications.any((n) => n.id == notif.id)) {
          _notifications.insert(0, notif.toNotificationResponse());
        }
      });
    });
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.getAll(forceRefresh: true);
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _markRead(NotificationResponse n) async {
    if (n.read) return;
    try {
      await _service.markAsRead(n.id);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAsRead();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(isDark, textSecondary),
          Expanded(
            child: _buildBody(cardColor, textPrimary, textSecondary, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textSecondary) {
    return Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _unreadCount > 0
                            ? '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}'
                            : 'All caught up!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Live indicator
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_unreadCount > 0)
                        GestureDetector(
                          onTap: _markAllRead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Mark all read',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      Color cardColor, Color textPrimary, Color textSecondary, bool isDark) {
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
            Text('Could not load notifications',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: _teal),
              label: const Text('Retry', style: TextStyle(color: _teal)),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined,
                  size: 40, color: _teal),
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you of important updates',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _teal,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _NotificationTile(
          notif: _notifications[i],
          cardColor: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          onTap: () => _markRead(_notifications[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Notification Tile
// ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationResponse notif;
  final Color cardColor, textPrimary, textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notif,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  Color get _typeColor {
    switch (notif.type) {
      case NotificationType.SUCCESS:
        return const Color(0xFF4CAF50);
      case NotificationType.WARNING:
        return const Color(0xFFFF9800);
      case NotificationType.ERROR:
        return const Color(0xFFF44336);
      case NotificationType.MESSAGE:
        return const Color(0xFF1A9BE8);
      case NotificationType.APPOINTMENT:
        return const Color(0xFF7986CB);
      case NotificationType.TEST:
        return const Color(0xFF4DB6AC);
      default:
        return const Color(0xFF1A9BE8);
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case NotificationType.SUCCESS:
        return Icons.check_circle_outline;
      case NotificationType.WARNING:
        return Icons.warning_amber_outlined;
      case NotificationType.ERROR:
        return Icons.error_outline;
      case NotificationType.MESSAGE:
        return Icons.chat_bubble_outline;
      case NotificationType.APPOINTMENT:
        return Icons.calendar_today_outlined;
      case NotificationType.TEST:
        return Icons.science_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.read
              ? cardColor
              : (isDark
                  ? const Color(0xFF1A9BE8).withOpacity(0.08)
                  : const Color(0xFFE3F2FD)),
          borderRadius: BorderRadius.circular(16),
          border: notif.read
              ? null
              : Border.all(
                  color: const Color(0xFF1A9BE8).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          notif.read ? FontWeight.w400 : FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notif.type.name,
                          style: TextStyle(
                            color: _typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notif.createdAt),
                        style:
                            TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!notif.read)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A9BE8),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

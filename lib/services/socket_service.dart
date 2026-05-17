import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────
// SOCKET EVENT MODELS
// ─────────────────────────────────────────────────────────────

class SocketChatMessage {
  final int id;
  final String content;
  final int senderId;
  final String? senderName;
  final int receiverId;
  final String? receiverName;
  final MessageStatus status;
  final DateTime sentAt;

  SocketChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    this.senderName,
    required this.receiverId,
    this.receiverName,
    required this.status,
    required this.sentAt,
  });

  factory SocketChatMessage.fromJson(Map<String, dynamic> j) =>
      SocketChatMessage(
        id: j['id'] ?? 0,
        content: j['content'] ?? '',
        senderId: j['senderId'] ?? 0,
        senderName: j['senderName'],
        receiverId: j['receiverId'] ?? 0,
        receiverName: j['receiverName'],
        status: j['status'] != null
            ? MessageStatus.values.byName(j['status'])
            : MessageStatus.SENT,
        sentAt: j['sentAt'] != null
            ? DateTime.parse(j['sentAt'])
            : DateTime.now(),
      );

  ChatMessageResponse toChatMessageResponse() => ChatMessageResponse(
        id: id,
        content: content,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        status: status,
        sentAt: sentAt,
      );
}

class SocketNotification {
  final int id;
  final String message;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;

  SocketNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory SocketNotification.fromJson(Map<String, dynamic> j) =>
      SocketNotification(
        id: j['id'] ?? 0,
        message: j['message'] ?? '',
        type: j['type'] != null
            ? NotificationType.values.byName(j['type'])
            : NotificationType.INFO,
        read: j['read'] ?? false,
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'])
            : DateTime.now(),
      );

  NotificationResponse toNotificationResponse() => NotificationResponse(
        id: id,
        message: message,
        type: type,
        read: read,
        createdAt: createdAt,
      );
}

// ─────────────────────────────────────────────────────────────
// SOCKET SERVICE
// Pure Dart WebSocket implementation using the STOMP-over-WS
// protocol that Spring Boot's SockJS/STOMP endpoint exposes.
// ─────────────────────────────────────────────────────────────

class SocketService {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._();
  SocketService._();

  // Raw WebSocket backed by dart:io or a polling fallback
  // We use a simple polling approach here for broad compatibility
  // with Flutter Web / iOS / Android without native deps.

  bool _connected = false;
  int? _currentUserId;
  Timer? _pollTimer;
  final Set<int> _emittedMessageIds = {};
  final Set<int> _emittedNotificationIds = {};

  // Streams
  final _messageController =
      StreamController<SocketChatMessage>.broadcast();
  final _notificationController =
      StreamController<SocketNotification>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<SocketChatMessage> get onMessage => _messageController.stream;
  Stream<SocketNotification> get onNotification =>
      _notificationController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  bool get isConnected => _connected;

  // ── Connect / Disconnect ─────────────────────────────────────

  Future<void> connect(int userId, String token) async {
    if (_connected && _currentUserId == userId) return;
    _currentUserId = userId;
    _connected = true;
    _connectionController.add(true);

    // Start polling every 5 seconds for new messages & notifications
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollUnread(userId, token);
    });
  }

  // ── Polling fallback ─────────────────────────────────────────

  Future<void> _pollUnread(int userId, String token) async {
    await Future.wait([
      _pollMessages(token),
      _pollNotifications(token),
    ]);
  }

  Future<void> _pollMessages(String token) async {
    try {
      final uri = Uri.parse('${BaseService.baseUrl}/api/messages/unread');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        for (final item in list) {
          final msg = SocketChatMessage.fromJson(item as Map<String, dynamic>);
          
          // Only emit if we haven't seen this message before
          if (!_emittedMessageIds.contains(msg.id)) {
            _emittedMessageIds.add(msg.id);
            _messageController.add(msg);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _pollNotifications(String token) async {
    try {
      final uri = Uri.parse('${BaseService.baseUrl}/api/notifications/unread');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        for (final item in list) {
          final notif = SocketNotification.fromJson(item as Map<String, dynamic>);

          if (!_emittedNotificationIds.contains(notif.id)) {
            _emittedNotificationIds.add(notif.id);
            _notificationController.add(notif);
          }
        }
      }
    } catch (_) {}
  }

  // Clear tracked IDs on disconnect so a fresh connect starts clean
  void disconnect() {
    _pollTimer?.cancel();
    _connected = false;
    _currentUserId = null;
    _emittedMessageIds.clear();
    _emittedNotificationIds.clear();
    _connectionController.add(false);
  }

  // ── Send message via REST (STOMP fallback) ───────────────────

  Future<ChatMessageResponse?> sendMessage({
    required int receiverId,
    required String content,
    required String token,
  }) async {
    try {
      final uri =
          Uri.parse('${BaseService.baseUrl}/api/messages/send');
      final res = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'receiverId': receiverId,
              'content': content,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ChatMessageResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Dispose ──────────────────────────────────────────────────

  void dispose() {
    disconnect();
    _messageController.close();
    _notificationController.close();
    _connectionController.close();
  }
}

import '../models/models.dart';
import 'base_service.dart';

// ─────────────────────────────────────────────
// NOTIFICATION SERVICE
// ─────────────────────────────────────────────

class NotificationService extends BaseService {
  // In-memory cache: updated optimistically on read/mark-read
  List<NotificationResponse>? _cached;

  Future<List<NotificationResponse>> getAll({bool forceRefresh = false}) async {
    if (_cached != null && !forceRefresh) return _cached!;
    final res = await get('/api/notifications');
    _cached = (decode(res) as List).map((e) => NotificationResponse.fromJson(e)).toList();
    return _cached!;
  }

  Future<List<NotificationResponse>> getUnread() async {
    final res = await get('/api/notifications/unread');
    return (decode(res) as List).map((e) => NotificationResponse.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await get('/api/notifications/unread/count');
    final map = decode(res) as Map<String, dynamic>;
    return (map.values.first as num).toInt();
  }

  Future<void> markAsRead(int id) async {
    final res = await put('/api/notifications/$id/read');
    guard(res);
    // Optimistic update in cache
    final idx = _cached?.indexWhere((n) => n.id == id) ?? -1;
    if (idx >= 0) {
      final old = _cached![idx];
      _cached![idx] = NotificationResponse(
        id: old.id,
        message: old.message,
        type: old.type,
        read: true,
        createdAt: old.createdAt,
        readAt: DateTime.now(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    final res = await put('/api/notifications/read-all');
    guard(res);
    _cached = _cached
        ?.map((n) => NotificationResponse(
              id: n.id,
              message: n.message,
              type: n.type,
              read: true,
              createdAt: n.createdAt,
              readAt: DateTime.now(),
            ))
        .toList();
  }

  Future<NotificationResponse> send(NotificationRequest request) async {
    final res = await post('/api/notifications/send', body: request.toJson());
    return NotificationResponse.fromJson(decode(res));
  }
}

// ─────────────────────────────────────────────
// MESSAGING SERVICE
// ─────────────────────────────────────────────

class MessagingService extends BaseService {
  List<ConversationSummaryResponse>? _cachedConversations;

  Future<List<ConversationSummaryResponse>> getConversations({bool forceRefresh = false}) async {
    if (_cachedConversations != null && !forceRefresh) return _cachedConversations!;
    final res = await get('/api/messages/conversations');
    _cachedConversations =
        (decode(res) as List).map((e) => ConversationSummaryResponse.fromJson(e)).toList();
    return _cachedConversations!;
  }

  Future<List<ChatMessageResponse>> getConversationWith(int userId) async {
    final res = await get('/api/messages/conversation/$userId');
    return (decode(res) as List).map((e) => ChatMessageResponse.fromJson(e)).toList();
  }

  Future<List<ChatMessageResponse>> getUnread() async {
    final res = await get('/api/messages/unread');
    return (decode(res) as List).map((e) => ChatMessageResponse.fromJson(e)).toList();
  }

  Future<void> markAsRead(int messageId) async {
    final res = await put('/api/messages/$messageId/read');
    guard(res);
  }
}

// ─────────────────────────────────────────────
// DASHBOARD SERVICE
// ─────────────────────────────────────────────

class DashboardService extends BaseService {
  // Short-lived cache: stats go stale quickly, so cache for 60 seconds only.
  DashboardStats?     _cachedDoctorStats;
  AdminDashboardStats? _cachedAdminStats;
  DateTime?           _doctorStatsFetchedAt;
  DateTime?           _adminStatsFetchedAt;
  static const _cacheTtl = Duration(seconds: 60);

  Future<DashboardStats> getDoctorStats({bool forceRefresh = false}) async {
    final stale = _doctorStatsFetchedAt == null ||
        DateTime.now().difference(_doctorStatsFetchedAt!) > _cacheTtl;
    if (_cachedDoctorStats != null && !stale && !forceRefresh) return _cachedDoctorStats!;

    final res = await get('/api/dashboard/stats');
    _cachedDoctorStats = DashboardStats.fromJson(decode(res));
    _doctorStatsFetchedAt = DateTime.now();
    return _cachedDoctorStats!;
  }

  Future<AdminDashboardStats> getAdminStats({bool forceRefresh = false}) async {
    final stale = _adminStatsFetchedAt == null ||
        DateTime.now().difference(_adminStatsFetchedAt!) > _cacheTtl;
    if (_cachedAdminStats != null && !stale && !forceRefresh) return _cachedAdminStats!;

    final res = await get('/api/dashboard/admin-stats');
    _cachedAdminStats = AdminDashboardStats.fromJson(decode(res));
    _adminStatsFetchedAt = DateTime.now();
    return _cachedAdminStats!;
  }

  /// [from] and [to] format: 'YYYY-MM'  e.g. '2025-01'
  Future<List<FinancialSummaryResponse>> getFinancialSummary({
    required int    doctorId,
    required String from,
    required String to,
  }) async {
    final res = await get('/api/dashboard/financial', query: {
      'doctorId': doctorId.toString(),
      'from': from,
      'to': to,
    });
    return (decode(res) as List).map((e) => FinancialSummaryResponse.fromJson(e)).toList();
  }
}

// ─────────────────────────────────────────────
// ADMIN SERVICE
// ─────────────────────────────────────────────

class AdminService extends BaseService {
  List<UserResponse>? _cachedUsers;

  Future<List<UserResponse>> getAllUsers({bool forceRefresh = false}) async {
    if (_cachedUsers != null && !forceRefresh) return _cachedUsers!;
    final res = await get('/api/admin/users');
    _cachedUsers = (decode(res) as List).map((e) => UserResponse.fromJson(e)).toList();
    return _cachedUsers!;
  }

  Future<UserResponse> getUserById(int id) async {
    final cached = _cachedUsers?.where((u) => u.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/admin/users/$id');
    return UserResponse.fromJson(decode(res));
  }

  Future<UserResponse> updateUser(UpdateUserRequest request) async {
    final res = await put('/api/admin/users/update', body: request.toJson());
    final updated = UserResponse.fromJson(decode(res));
    final idx = _cachedUsers?.indexWhere((u) => u.id == updated.id) ?? -1;
    if (idx >= 0) _cachedUsers![idx] = updated;
    return updated;
  }

  Future<MessageResponse> resetUserPassword(int id, String newPassword) async {
    final res = await put('/api/admin/users/$id/reset-password', body: {'password': newPassword});
    return MessageResponse.fromJson(decode(res));
  }

  Future<void> deleteUser(int id) async {
    final res = await delete('/api/admin/users/$id');
    guard(res);
    _cachedUsers?.removeWhere((u) => u.id == id);
  }
}

// ─────────────────────────────────────────────
// FILE SERVICE
// ─────────────────────────────────────────────

class FileService extends BaseService {
  List<UserFile>? _cachedMyFiles;

  Future<UserFile> upload(List<int> fileBytes, String filename) async {
    final res = await uploadFile('/api/files/upload', fileBytes, filename);
    final file = UserFile.fromJson(decode(res));
    _cachedMyFiles?.add(file); // optimistic insert
    return file;
  }

  Future<List<UserFile>> getMyFiles({bool forceRefresh = false}) async {
    if (_cachedMyFiles != null && !forceRefresh) return _cachedMyFiles!;
    final res = await get('/api/files/my-files');
    _cachedMyFiles = (decode(res) as List).map((e) => UserFile.fromJson(e)).toList();
    return _cachedMyFiles!;
  }

  Future<List<UserFile>> getPatientFiles(int patientId) async {
    final res = await get('/api/files/patient/$patientId');
    return (decode(res) as List).map((e) => UserFile.fromJson(e)).toList();
  }

  /// Returns the URL to stream or download a file by filename.
  String fileUrl(String filename) => '${BaseService.baseUrl}/api/files/$filename';

  Future<void> deleteFile(String filename) async {
    final res = await delete('/api/files/$filename');
    guard(res);
    _cachedMyFiles?.removeWhere((f) => f.filename == filename);
  }

  Future<UserResponse> uploadProfileImage(List<int> fileBytes, String filename) async {
    final res = await uploadFile('/api/users/me/image', fileBytes, filename);
    return UserResponse.fromJson(decode(res));
  }

  Future<UserResponse> deleteProfileImage() async {
    final res = await delete('/api/users/me/image');
    return UserResponse.fromJson(decode(res));
  }
}
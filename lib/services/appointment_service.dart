import '../models/models.dart';
import 'base_service.dart';

class AppointmentService extends BaseService {
  List<AppointmentResponse>? _cachedList;

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<Page<AppointmentResponse>> getAll({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final res = await get('/api/appointments', query: {
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
    });
    final data = Page.fromJson(decode(res), AppointmentResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<AppointmentResponse> getById(int id) async {
    final cached = _cachedList?.where((a) => a.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/appointments/$id');
    return AppointmentResponse.fromJson(decode(res));
  }

  Future<List<AppointmentResponse>> getByPatient(int patientId) async {
    final res = await get('/api/appointments/patient/$patientId');
    return (decode(res) as List).map((e) => AppointmentResponse.fromJson(e)).toList();
  }

  Future<List<AppointmentResponse>> getByDoctor(int doctorId) async {
    final res = await get('/api/appointments/doctor/$doctorId');
    return (decode(res) as List).map((e) => AppointmentResponse.fromJson(e)).toList();
  }

  Future<List<AppointmentResponse>> getDoctorSchedule(int doctorId, String date) async {
    final res = await get('/api/appointments/doctor/$doctorId/schedule', query: {'date': date});
    return (decode(res) as List).map((e) => AppointmentResponse.fromJson(e)).toList();
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<AppointmentResponse> create(AppointmentRequest request) async {
    final res = await post('/api/appointments', body: request.toJson());
    final created = AppointmentResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<AppointmentResponse> update(int id, AppointmentRequest request) async {
    final res = await put('/api/appointments/$id', body: request.toJson());
    final updated = AppointmentResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<AppointmentResponse> updateStatus(int id, AppointmentStatus status) async {
    final res = await patch('/api/appointments/$id/status', body: {'status': status.name});
    final updated = AppointmentResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteAppointment(int id) async {
    final res = await delete('/api/appointments/$id');
    guard(res);
    _cachedList?.removeWhere((a) => a.id == id);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _invalidateCached(AppointmentResponse updated) {
    final idx = _cachedList?.indexWhere((a) => a.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}
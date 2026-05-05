import '../models/models.dart';
import 'base_service.dart';

class DoctorService extends BaseService {
  List<Doctor>? _cachedList;

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<Page<Doctor>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/doctors', query: {
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
    });
    final data = Page.fromJson(decode(res), Doctor.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<Doctor> getById(int id) async {
    final cached = _cachedList?.where((d) => d.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/doctors/$id');
    return Doctor.fromJson(decode(res));
  }

  Future<List<Doctor>> getBySpecialization(Specialization specialization) async {
    final res = await get('/api/doctors/specialization/${specialization.name}');
    return (decode(res) as List).map((e) => Doctor.fromJson(e)).toList();
  }

  Future<List<DoctorLocation>> getNearby(double lat, double lng, {double radiusKm = 10}) async {
    final res = await get('/api/doctors/nearby', query: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radiusKm': radiusKm.toString(),
    });
    return (decode(res) as List).map((e) => DoctorLocation.fromJson(e)).toList();
  }

  Future<List<TimeSlotResponse>> getAvailability(int id, String date) async {
    final res = await get('/api/doctors/$id/availability', query: {'date': date});
    return (decode(res) as List).map((e) => TimeSlotResponse.fromJson(e)).toList();
  }

  // Public endpoints — no auth required
  Future<DoctorSearchResponse> getPublicProfile(int id) async {
    final res = await get('/api/public/doctors/$id/profile');
    return DoctorSearchResponse.fromJson(decode(res));
  }

  Future<Page<DoctorSearchResponse>> search(DoctorSearchRequest request) async {
    final res = await get('/api/public/doctors/search', query: request.toQueryParams());
    return Page.fromJson(decode(res), DoctorSearchResponse.fromJson);
  }

  Future<Page<DoctorReview>> getReviews(int id, {int page = 0, int size = 10}) async {
    final res = await get('/api/public/doctors/$id/reviews', query: {
      'page': page.toString(),
      'size': size.toString(),
    });
    return Page.fromJson(decode(res), DoctorReview.fromJson);
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<Doctor> create(DoctorRequest request) async {
    final res = await post('/api/doctors', body: request.toJson());
    final created = Doctor.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<Doctor> update(int id, UpdateDoctorRequest request) async {
    final res = await put('/api/doctors/$id', body: request.toJson());
    final updated = Doctor.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<Doctor> setEnabled(int id, bool enabled) async {
    final res = await patch('/api/doctors/$id/enabled', body: {'enabled': enabled});
    final updated = Doctor.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<DoctorLocation> updateLocation(int id, DoctorLocation location) async {
    final res = await put('/api/doctors/$id/location', body: location.toJson());
    return DoctorLocation.fromJson(decode(res));
  }

  Future<DoctorReview> addReview(int id, DoctorReview review) async {
    final res = await post('/api/public/doctors/$id/reviews', body: review.toJson());
    return DoctorReview.fromJson(decode(res));
  }

  Future<void> deleteDoctor(int id) async {
    final res = await delete('/api/doctors/$id');
    guard(res);
    _cachedList?.removeWhere((d) => d.id == id);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _invalidateCached(Doctor updated) {
    final idx = _cachedList?.indexWhere((d) => d.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}
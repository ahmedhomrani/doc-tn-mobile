import '../models/models.dart';
import 'base_service.dart';

class PatientService extends BaseService {
  // Simple in-memory cache for first page — invalidated on any write.
  List<PatientResponse>? _cachedList;

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<Page<PatientResponse>> getAll({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final res = await get('/api/patients', query: {
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
    });
    final data = Page.fromJson(decode(res), PatientResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<PatientResponse> getById(int id) async {
    final cached = _cachedList?.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/patients/$id');
    return PatientResponse.fromJson(decode(res));
  }

  Future<PatientResponse> getMyProfile() async {
    final res = await get('/api/patients/me');
    return PatientResponse.fromJson(decode(res));
  }

  Future<Page<PatientResponse>> search(String query, {int page = 0, int size = 20}) async {
    final res = await get('/api/patients/search', query: {
      'query': query,
      'page': page.toString(),
      'size': size.toString(),
    });
    return Page.fromJson(decode(res), PatientResponse.fromJson);
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<PatientResponse> create(PatientRequest request) async {
    final res = await post('/api/patients', body: request.toJson());
    final created = PatientResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<PatientResponse> update(int id, PatientRequest request) async {
    final res = await put('/api/patients/$id', body: request.toJson());
    final updated = PatientResponse.fromJson(decode(res));
    _cachedList = null;
    return updated;
  }

  Future<PatientResponse> patchPatient(int id, PatientRequest request) async {
    final res = await super.patch('/api/patients/$id', body: request.toJson());
    final updated = PatientResponse.fromJson(decode(res));
    _cachedList = null;
    return updated;
  }

  Future<void> deletePatient(int id) async {
    final res = await delete('/api/patients/$id');
    guard(res);
    _cachedList?.removeWhere((p) => p.id == id);
  }
}
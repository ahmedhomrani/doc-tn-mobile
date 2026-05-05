import '../models/models.dart';
import 'base_service.dart';

// ─────────────────────────────────────────────
// TREATMENT SERVICE
// ─────────────────────────────────────────────

class TreatmentService extends BaseService {
  List<TreatmentResponse>? _cachedList;

  Future<Page<TreatmentResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/treatments', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), TreatmentResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<TreatmentResponse> getById(int id) async {
    final cached = _cachedList?.where((t) => t.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/treatments/$id');
    return TreatmentResponse.fromJson(decode(res));
  }

  Future<List<TreatmentResponse>> getByPatient(int patientId) async {
    final res = await get('/api/treatments/patient/$patientId');
    return (decode(res) as List).map((e) => TreatmentResponse.fromJson(e)).toList();
  }

  Future<TreatmentResponse> create(TreatmentRequest request) async {
    final res = await post('/api/treatments', body: request.toJson());
    final created = TreatmentResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<TreatmentResponse> update(int id, TreatmentRequest request) async {
    final res = await put('/api/treatments/$id', body: request.toJson());
    final updated = TreatmentResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<TreatmentResponse> updateStatus(int id, TreatmentStatus status) async {
    final res = await patch('/api/treatments/$id/status', body: {'status': status.name});
    final updated = TreatmentResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteTreatment(int id) async {
    final res = await delete('/api/treatments/$id');
    guard(res);
    _cachedList?.removeWhere((t) => t.id == id);
  }

  void _invalidateCached(TreatmentResponse updated) {
    final idx = _cachedList?.indexWhere((t) => t.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}

// ─────────────────────────────────────────────
// PRESCRIPTION SERVICE
// ─────────────────────────────────────────────

class PrescriptionService extends BaseService {
  List<PrescriptionResponse>? _cachedList;

  Future<Page<PrescriptionResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/prescriptions', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), PrescriptionResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<PrescriptionResponse> getById(int id) async {
    final cached = _cachedList?.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/prescriptions/$id');
    return PrescriptionResponse.fromJson(decode(res));
  }

  Future<List<PrescriptionResponse>> getByPatient(int patientId) async {
    final res = await get('/api/prescriptions/patient/$patientId');
    return (decode(res) as List).map((e) => PrescriptionResponse.fromJson(e)).toList();
  }

  Future<List<PrescriptionResponse>> getByDoctor(int doctorId) async {
    final res = await get('/api/prescriptions/doctor/$doctorId');
    return (decode(res) as List).map((e) => PrescriptionResponse.fromJson(e)).toList();
  }

  Future<PrescriptionResponse> create(PrescriptionRequest request) async {
    final res = await post('/api/prescriptions', body: request.toJson());
    final created = PrescriptionResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<PrescriptionResponse> update(int id, PrescriptionRequest request) async {
    final res = await put('/api/prescriptions/$id', body: request.toJson());
    final updated = PrescriptionResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deletePrescription(int id) async {
    final res = await delete('/api/prescriptions/$id');
    guard(res);
    _cachedList?.removeWhere((p) => p.id == id);
  }

  void _invalidateCached(PrescriptionResponse updated) {
    final idx = _cachedList?.indexWhere((p) => p.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}

// ─────────────────────────────────────────────
// INVOICE SERVICE
// ─────────────────────────────────────────────

class InvoiceService extends BaseService {
  List<InvoiceResponse>? _cachedList;

  Future<Page<InvoiceResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/invoices', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), InvoiceResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<InvoiceResponse> getById(int id) async {
    final cached = _cachedList?.where((i) => i.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/invoices/$id');
    return InvoiceResponse.fromJson(decode(res));
  }

  Future<List<InvoiceResponse>> getByPatient(int patientId) async {
    final res = await get('/api/invoices/patient/$patientId');
    return (decode(res) as List).map((e) => InvoiceResponse.fromJson(e)).toList();
  }

  Future<InvoiceResponse> create(InvoiceRequest request) async {
    final res = await post('/api/invoices', body: request.toJson());
    final created = InvoiceResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<InvoiceResponse> update(int id, InvoiceRequest request) async {
    final res = await put('/api/invoices/$id', body: request.toJson());
    final updated = InvoiceResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  /// Partial update: only paidAmount & paymentMethod.
  /// remainingAmount is recalculated server-side.
  Future<InvoiceResponse> updatePayment(
    int id, {
    required num paidAmount,
    PaymentMethod? paymentMethod,
  }) async {
    final body = <String, dynamic>{'paidAmount': paidAmount};
    if (paymentMethod != null) body['paymentMethod'] = paymentMethod.name;
    final res = await patch('/api/invoices/$id/payment', body: body);
    final updated = InvoiceResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteInvoice(int id) async {
    final res = await delete('/api/invoices/$id');
    guard(res);
    _cachedList?.removeWhere((i) => i.id == id);
  }

  void _invalidateCached(InvoiceResponse updated) {
    final idx = _cachedList?.indexWhere((i) => i.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}

// ─────────────────────────────────────────────
// INCOME SERVICE
// ─────────────────────────────────────────────

class IncomeService extends BaseService {
  List<IncomeResponse>? _cachedList;

  Future<Page<IncomeResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/incomes', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), IncomeResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<IncomeResponse> getById(int id) async {
    final cached = _cachedList?.where((i) => i.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/incomes/$id');
    return IncomeResponse.fromJson(decode(res));
  }

  Future<List<IncomeResponse>> getByPatient(int patientId) async {
    final res = await get('/api/incomes/patient/$patientId');
    return (decode(res) as List).map((e) => IncomeResponse.fromJson(e)).toList();
  }

  Future<List<IncomeResponse>> getByDoctor(int doctorId) async {
    final res = await get('/api/incomes/doctor/$doctorId');
    return (decode(res) as List).map((e) => IncomeResponse.fromJson(e)).toList();
  }

  /// [start] and [end] format: 'YYYY-MM-DD'
  Future<List<IncomeResponse>> getByDoctorAndDateRange(
    int doctorId,
    String start,
    String end,
  ) async {
    final res = await get('/api/incomes/doctor/$doctorId/range',
        query: {'start': start, 'end': end});
    return (decode(res) as List).map((e) => IncomeResponse.fromJson(e)).toList();
  }

  Future<IncomeResponse> create(IncomeRequest request) async {
    final res = await post('/api/incomes', body: request.toJson());
    final created = IncomeResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<IncomeResponse> update(int id, IncomeRequest request) async {
    final res = await put('/api/incomes/$id', body: request.toJson());
    final updated = IncomeResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteIncome(int id) async {
    final res = await delete('/api/incomes/$id');
    guard(res);
    _cachedList?.removeWhere((i) => i.id == id);
  }

  void _invalidateCached(IncomeResponse updated) {
    final idx = _cachedList?.indexWhere((i) => i.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}

// ─────────────────────────────────────────────
// EXPENSE SERVICE
// ─────────────────────────────────────────────

class ExpenseService extends BaseService {
  List<ExpenseResponse>? _cachedList;

  Future<Page<ExpenseResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/expenses', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), ExpenseResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<ExpenseResponse> getById(int id) async {
    final cached = _cachedList?.where((e) => e.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/expenses/$id');
    return ExpenseResponse.fromJson(decode(res));
  }

  Future<List<ExpenseResponse>> getByDoctor(int doctorId) async {
    final res = await get('/api/expenses/doctor/$doctorId');
    return (decode(res) as List).map((e) => ExpenseResponse.fromJson(e)).toList();
  }

  /// [start] and [end] format: 'YYYY-MM-DD'
  Future<List<ExpenseResponse>> getByDoctorAndDateRange(
    int doctorId,
    String start,
    String end,
  ) async {
    final res = await get('/api/expenses/doctor/$doctorId/range',
        query: {'start': start, 'end': end});
    return (decode(res) as List).map((e) => ExpenseResponse.fromJson(e)).toList();
  }

  Future<ExpenseResponse> create(ExpenseRequest request) async {
    final res = await post('/api/expenses', body: request.toJson());
    final created = ExpenseResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<ExpenseResponse> update(int id, ExpenseRequest request) async {
    final res = await put('/api/expenses/$id', body: request.toJson());
    final updated = ExpenseResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteExpense(int id) async {
    final res = await delete('/api/expenses/$id');
    guard(res);
    _cachedList?.removeWhere((e) => e.id == id);
  }

  void _invalidateCached(ExpenseResponse updated) {
    final idx = _cachedList?.indexWhere((e) => e.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}

// ─────────────────────────────────────────────
// STAFF SERVICE
// ─────────────────────────────────────────────

class StaffService extends BaseService {
  List<StaffResponse>? _cachedList;

  Future<Page<StaffResponse>> getAll({int page = 0, int size = 20, String sort = 'createdAt,desc'}) async {
    final res = await get('/api/staff', query: {
      'page': page.toString(), 'size': size.toString(), 'sort': sort,
    });
    final data = Page.fromJson(decode(res), StaffResponse.fromJson);
    if (page == 0) _cachedList = data.content;
    return data;
  }

  Future<StaffResponse> getById(int id) async {
    final cached = _cachedList?.where((s) => s.id == id).firstOrNull;
    if (cached != null) return cached;
    final res = await get('/api/staff/$id');
    return StaffResponse.fromJson(decode(res));
  }

  Future<List<StaffResponse>> getByDoctor(int doctorId) async {
    final res = await get('/api/staff/doctor/$doctorId');
    return (decode(res) as List).map((e) => StaffResponse.fromJson(e)).toList();
  }

  Future<StaffResponse> create(StaffRequest request) async {
    final res = await post('/api/staff', body: request.toJson());
    final created = StaffResponse.fromJson(decode(res));
    _cachedList = null;
    return created;
  }

  Future<StaffResponse> update(int id, StaffRequest request) async {
    final res = await put('/api/staff/$id', body: request.toJson());
    final updated = StaffResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<StaffResponse> updatePermissions(int id, List<StaffPermission> permissions) async {
    final res = await put('/api/staff/$id/permissions',
        body: permissions.map((p) => p.name).toList());
    final updated = StaffResponse.fromJson(decode(res));
    _invalidateCached(updated);
    return updated;
  }

  Future<void> deleteStaff(int id) async {
    final res = await delete('/api/staff/$id');
    guard(res);
    _cachedList?.removeWhere((s) => s.id == id);
  }

  void _invalidateCached(StaffResponse updated) {
    final idx = _cachedList?.indexWhere((s) => s.id == updated.id) ?? -1;
    if (idx >= 0) _cachedList![idx] = updated;
  }
}
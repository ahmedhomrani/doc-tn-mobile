// ─────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────

enum UserRole { ADMIN, DOCTOR, PATIENT, STAFF }

enum Gender { MALE, FEMALE }

enum Specialization {
  GENERAL_PRACTICE, CARDIOLOGY, DERMATOLOGY, ENDOCRINOLOGY,
  GASTROENTEROLOGY, NEUROLOGY, OBSTETRICS_GYNECOLOGY, ONCOLOGY,
  OPHTHALMOLOGY, ORTHOPEDICS, PEDIATRICS, PSYCHIATRY, PULMONOLOGY,
  RADIOLOGY, SURGERY, UROLOGY, NEPHROLOGY, RHEUMATOLOGY,
  INFECTIOUS_DISEASE, EMERGENCY_MEDICINE, ANESTHESIOLOGY,
  DENTISTRY, ENT, PHYSIOTHERAPY, NUTRITION
}

enum ConsultationType { IN_PERSON, ONLINE, BOTH }

enum TreatmentStatus { PLANNED, IN_PROGRESS, COMPLETED, CANCELLED }

enum AppointmentStatus { SCHEDULED, CONFIRMED, COMPLETED, CANCELLED, NO_SHOW, PENDING }

enum AppointmentType { CONSULTATION, CLEANING, TREATMENT, EMERGENCY, FOLLOW_UP, CHECK_UP }

enum PaymentStatus { PENDING, PARTIALLY_PAID, PAID, OVERDUE }

enum PaymentMethod { CASH, CREDIT_CARD, BANK_TRANSFER, INSURANCE, CHECK }

enum MessageStatus { SENT, DELIVERED, READ }

enum NotificationType { INFO, SUCCESS, WARNING, ERROR, MESSAGE, APPOINTMENT, TEST }

enum StaffPermission {
  MANAGE_APPOINTMENTS, MANAGE_TREATMENTS, MANAGE_PRESCRIPTIONS,
  MANAGE_INVOICES, MANAGE_PATIENTS, MANAGE_EXPENSES,
  MANAGE_INCOME, VIEW_DASHBOARD
}

// ─────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────

class LoginRequest {
  final String usernameOrEmail;
  final String password;

  LoginRequest({required this.usernameOrEmail, required this.password});

  Map<String, dynamic> toJson() => {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      };
}

class SignupRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'role': role.name,
      };
}

class GoogleAuthRequest {
  final String idToken;
  final UserRole role;

  GoogleAuthRequest({required this.idToken, required this.role});

  Map<String, dynamic> toJson() => {'idToken': idToken, 'role': role.name};
}

class AuthResponse {
  final String token;
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? imageUrl;

  AuthResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.imageUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        token: j['token'],
        id: j['id'],
        username: j['username'],
        email: j['email'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        role: UserRole.values.byName(j['role']),
        imageUrl: j['imageUrl'],
      );
}

class ResetPasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}

class MessageResponse {
  final String message;
  MessageResponse({required this.message});
  factory MessageResponse.fromJson(Map<String, dynamic> j) =>
      MessageResponse(message: j['message']);
}

// ─────────────────────────────────────────────
// USER
// ─────────────────────────────────────────────

class UserFile {
  final int id;
  final String originalName;
  final String filename;
  final String url;
  final String contentType;
  final int size;
  final DateTime uploadedAt;

  UserFile({
    required this.id,
    required this.originalName,
    required this.filename,
    required this.url,
    required this.contentType,
    required this.size,
    required this.uploadedAt,
  });

  factory UserFile.fromJson(Map<String, dynamic> j) => UserFile(
        id: j['id'],
        originalName: j['originalName'],
        filename: j['filename'],
        url: j['url'],
        contentType: j['contentType'],
        size: j['size'],
        uploadedAt: DateTime.parse(j['uploadedAt']),
      );
}

class UserResponse {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final bool enabled;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserFile> files;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    required this.enabled,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.files,
  });

  factory UserResponse.fromJson(Map<String, dynamic> j) => UserResponse(
        id: j['id'],
        username: j['username'],
        email: j['email'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        phoneNumber: j['phoneNumber'],
        role: UserRole.values.byName(j['role']),
        enabled: j['enabled'],
        imageUrl: j['imageUrl'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
        files: (j['files'] as List? ?? [])
            .map((e) => UserFile.fromJson(e))
            .toList(),
      );
}

class UpdateUserRequest {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final UserRole? role;
  final bool? enabled;

  UpdateUserRequest({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (role != null) 'role': role!.name,
        if (enabled != null) 'enabled': enabled,
      };
}

// ─────────────────────────────────────────────
// PATIENT
// ─────────────────────────────────────────────

class PatientRequest {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? medicalHistory;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? age;
  final String? weight;
  final String? height;
  final String? bloodType;

  PatientRequest({
    this.firstName = '',
    this.lastName = '',
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.postalCode,
    this.medicalHistory,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.age,
    this.weight,
    this.height,
    this.bloodType,
  });

  Map<String, dynamic> toJson() => {
        if (firstName.isNotEmpty) 'firstName': firstName,
        if (lastName.isNotEmpty) 'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (gender != null) 'gender': gender!.name,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (postalCode != null) 'postalCode': postalCode,
        if (medicalHistory != null) 'medicalHistory': medicalHistory,
        if (allergies != null) 'allergies': allergies,
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (bloodType != null) 'bloodType': bloodType,
      };
}

class PatientResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? medicalHistory;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? age;
  final String? weight;
  final String? height;
  final String? bloodType;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.postalCode,
    this.medicalHistory,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.age,
    this.weight,
    this.height,
    this.bloodType,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> j) => PatientResponse(
        id: j['id'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        dateOfBirth: j['dateOfBirth'],
        gender: j['gender'] != null ? Gender.values.byName(j['gender']) : null,
        address: j['address'],
        city: j['city'],
        postalCode: j['postalCode'],
        medicalHistory: j['medicalHistory'],
        allergies: j['allergies'],
        emergencyContactName: j['emergencyContactName'],
        emergencyContactPhone: j['emergencyContactPhone'],
        age: j['age'],
        weight: j['weight'],
        height: j['height'],
        bloodType: j['bloodType'],
        enabled: j['enabled'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );

  String get fullName => '$firstName $lastName';
}

// ─────────────────────────────────────────────
// DOCTOR
// ─────────────────────────────────────────────

class DoctorLocation {
  final int? id;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final DateTime? updatedAt;

  DoctorLocation({
    this.id,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.updatedAt,
  });

  factory DoctorLocation.fromJson(Map<String, dynamic> j) => DoctorLocation(
        id: j['id'],
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        address: j['address'],
        city: j['city'],
        country: j['country'],
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      };
}

class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? licenseNumber;
  final bool enabled;
  final String? bio;
  final String? profileImageUrl;
  final int? yearsOfExperience;
  final String? spokenLanguages;
  final double? consultationFee;
  final int? consultationDuration;
  final ConsultationType? consultationType;
  final bool? acceptingNewPatients;
  final double? averageRating;
  final int? totalReviews;
  final Gender? gender;
  final Specialization? specialization;
  final DoctorLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.licenseNumber,
    required this.enabled,
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    this.spokenLanguages,
    this.consultationFee,
    this.consultationDuration,
    this.consultationType,
    this.acceptingNewPatients,
    this.averageRating,
    this.totalReviews,
    this.gender,
    this.specialization,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['id'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        licenseNumber: j['licenseNumber'],
        enabled: j['enabled'] ?? false,
        bio: j['bio'],
        profileImageUrl: j['profileImageUrl'],
        yearsOfExperience: j['yearsOfExperience'],
        spokenLanguages: j['spokenLanguages'],
        consultationFee: (j['consultationFee'] as num?)?.toDouble(),
        consultationDuration: j['consultationDuration'],
        consultationType: j['consultationType'] != null
            ? ConsultationType.values.byName(j['consultationType'])
            : null,
        acceptingNewPatients: j['acceptingNewPatients'],
        averageRating: (j['averageRating'] as num?)?.toDouble(),
        totalReviews: j['totalReviews'],
        gender: j['gender'] != null ? Gender.values.byName(j['gender']) : null,
        specialization: j['specialization'] != null
            ? Specialization.values.byName(j['specialization'])
            : null,
        location: j['location'] != null ? DoctorLocation.fromJson(j['location']) : null,
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );

  String get fullName => '$firstName $lastName';
}

class DoctorRequest {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? licenseNumber;
  final Specialization? specialization;
  final String? bio;
  final String? profileImageUrl;
  final int? yearsOfExperience;
  final String? spokenLanguages;
  final double? consultationFee;
  final int? consultationDuration;
  final ConsultationType? consultationType;
  final Gender? gender;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;

  DoctorRequest({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.licenseNumber,
    this.specialization,
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    this.spokenLanguages,
    this.consultationFee,
    this.consultationDuration,
    this.consultationType,
    this.gender,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (specialization != null) 'specialization': specialization!.name,
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        if (spokenLanguages != null) 'spokenLanguages': spokenLanguages,
        if (consultationFee != null) 'consultationFee': consultationFee,
        if (consultationDuration != null) 'consultationDuration': consultationDuration,
        if (consultationType != null) 'consultationType': consultationType!.name,
        if (gender != null) 'gender': gender!.name,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      };
}

class UpdateDoctorRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? licenseNumber;
  final Specialization? specialization;

  UpdateDoctorRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.licenseNumber,
    this.specialization,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (specialization != null) 'specialization': specialization!.name,
      };
}

class DoctorSearchRequest {
  final String? name;
  final Specialization? specialization;
  final String? city;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final double? maxFee;
  final String? language;
  final bool? acceptingNewPatients;
  final String? sortBy;
  final int? page;
  final int? size;

  DoctorSearchRequest({
    this.name,
    this.specialization,
    this.city,
    this.lat,
    this.lng,
    this.radiusKm,
    this.maxFee,
    this.language,
    this.acceptingNewPatients,
    this.sortBy,
    this.page,
    this.size,
  });

  Map<String, String> toQueryParams() {
    final map = <String, String>{};
    if (name != null)                 map['name']                = name!;
    if (specialization != null)       map['specialization']      = specialization!.name;
    if (city != null)                 map['city']                = city!;
    if (lat != null)                  map['lat']                 = lat!.toString();
    if (lng != null)                  map['lng']                 = lng!.toString();
    if (radiusKm != null)             map['radiusKm']            = radiusKm!.toString();
    if (maxFee != null)               map['maxFee']              = maxFee!.toString();
    if (language != null)             map['language']            = language!;
    if (acceptingNewPatients != null) map['acceptingNewPatients']= acceptingNewPatients!.toString();
    if (sortBy != null)               map['sortBy']              = sortBy!;
    if (page != null)                 map['page']                = page!.toString();
    if (size != null)                 map['size']                = size!.toString();
    return map;
  }
}

class DoctorSearchResponse {
  final int id;
  final String firstName;
  final String lastName;
  final Specialization? specialization;
  final String? profileImageUrl;
  final String? bio;
  final int? yearsOfExperience;
  final double? consultationFee;
  final int? consultationDuration;
  final ConsultationType? consultationType;
  final String? spokenLanguages;
  final bool? acceptingNewPatients;
  final double? averageRating;
  final int? totalReviews;
  final Gender? gender;
  final bool enabled;
  // Location (flat)
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? country;
  // Nested
  final List<DoctorReviewDto> reviews;
  final List<DoctorEducationDto> education;
  final List<DoctorAvailabilityDto> availability;

  DoctorSearchResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.specialization,
    this.profileImageUrl,
    this.bio,
    this.yearsOfExperience,
    this.consultationFee,
    this.consultationDuration,
    this.consultationType,
    this.spokenLanguages,
    this.acceptingNewPatients,
    this.averageRating,
    this.totalReviews,
    this.gender,
    this.enabled = true,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.country,
    this.reviews = const [],
    this.education = const [],
    this.availability = const [],
  });

  factory DoctorSearchResponse.fromJson(Map<String, dynamic> j) {
    // location can be nested object or flat fields
    final loc = j['location'] as Map<String, dynamic>?;
    return DoctorSearchResponse(
      id: j['id'],
      firstName: j['firstName'],
      lastName: j['lastName'],
      specialization: j['specialization'] != null
          ? Specialization.values.byName(j['specialization'])
          : null,
      profileImageUrl: j['profileImageUrl'],
      bio: j['bio'],
      yearsOfExperience: j['yearsOfExperience'],
      consultationFee: (j['consultationFee'] as num?)?.toDouble(),
      consultationDuration: j['consultationDuration'],
      consultationType: j['consultationType'] != null
          ? ConsultationType.values.byName(j['consultationType'])
          : null,
      spokenLanguages: j['spokenLanguages'],
      acceptingNewPatients: j['acceptingNewPatients'],
      averageRating: (j['averageRating'] as num?)?.toDouble(),
      totalReviews: j['totalReviews'],
      gender: j['gender'] != null ? Gender.values.byName(j['gender']) : null,
      enabled: j['enabled'] ?? true,
      city: loc?['city'] ?? j['city'],
      address: loc?['address'] ?? j['address'],
      latitude: (loc?['latitude'] ?? j['latitude'] as num?)?.toDouble(),
      longitude: (loc?['longitude'] ?? j['longitude'] as num?)?.toDouble(),
      country: loc?['country'] ?? j['country'],
      reviews: (j['reviews'] as List? ?? [])
          .map((e) => DoctorReviewDto.fromJson(e))
          .toList(),
      education: (j['education'] as List? ?? [])
          .map((e) => DoctorEducationDto.fromJson(e))
          .toList(),
      availability: (j['availability'] as List? ?? [])
          .map((e) => DoctorAvailabilityDto.fromJson(e))
          .toList(),
    );
  }

  String get fullName => '$firstName $lastName';
}

// ── Nested DTOs ──────────────────────────────────────────

class DoctorReviewDto {
  final int? id;
  final int? rating;
  final String? comment;
  final String? patientName;

  DoctorReviewDto({this.id, this.rating, this.comment, this.patientName});

  factory DoctorReviewDto.fromJson(Map<String, dynamic> j) => DoctorReviewDto(
        id: j['id'],
        rating: j['rating'],
        comment: j['comment'],
        patientName: j['patientName'],
      );
}

class DoctorEducationDto {
  final int? id;
  final String? degree;
  final String? institution;
  final int? graduationYear;

  DoctorEducationDto({this.id, this.degree, this.institution, this.graduationYear});

  factory DoctorEducationDto.fromJson(Map<String, dynamic> j) => DoctorEducationDto(
        id: j['id'],
        degree: j['degree'],
        institution: j['institution'],
        graduationYear: j['graduationYear'],
      );
}

class DoctorAvailabilityDto {
  final int? id;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool available;

  DoctorAvailabilityDto({
    this.id,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.available = true,
  });

  factory DoctorAvailabilityDto.fromJson(Map<String, dynamic> j) => DoctorAvailabilityDto(
        id: j['id'],
        dayOfWeek: j['dayOfWeek'],
        startTime: j['startTime'],
        endTime: j['endTime'],
        available: j['available'] ?? true,
      );
}

class DoctorReview {
  final int? id;
  final Doctor? doctor;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  DoctorReview({this.id, this.doctor, this.rating, this.comment, this.createdAt});

  factory DoctorReview.fromJson(Map<String, dynamic> j) => DoctorReview(
        id: j['id'],
        doctor: j['doctor'] != null ? Doctor.fromJson(j['doctor']) : null,
        rating: j['rating'],
        comment: j['comment'],
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      };
}

class TimeSlotResponse {
  final String startTime;
  final String endTime;
  final bool available;

  TimeSlotResponse({required this.startTime, required this.endTime, required this.available});

  factory TimeSlotResponse.fromJson(Map<String, dynamic> j) => TimeSlotResponse(
        startTime: j['startTime'],
        endTime: j['endTime'],
        available: j['available'],
      );
}

// ─────────────────────────────────────────────
// APPOINTMENT
// ─────────────────────────────────────────────

class AppointmentRequest {
  final int patientId;
  final int? doctorId;
  final DateTime appointmentDateTime;
  final int? durationMinutes;
  final AppointmentStatus? status;
  final AppointmentType? type;
  final String? notes;
  final String? reason;

  AppointmentRequest({
    required this.patientId,
    this.doctorId,
    required this.appointmentDateTime,
    this.durationMinutes,
    this.status,
    this.type,
    this.notes,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        'appointmentDateTime': appointmentDateTime.toIso8601String(),
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (status != null) 'status': status!.name,
        if (type != null) 'type': type!.name,
        if (notes != null) 'notes': notes,
        if (reason != null) 'reason': reason,
      };
}

class AppointmentResponse {
  final int id;
  final int patientId;
  final String? patientName;
  final int? doctorId;
  final String? doctorName;
  final DateTime appointmentDateTime;
  final int? durationMinutes;
  final AppointmentStatus status;
  final AppointmentType? type;
  final String? notes;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentResponse({
    required this.id,
    required this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    required this.appointmentDateTime,
    this.durationMinutes,
    required this.status,
    this.type,
    this.notes,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> j) => AppointmentResponse(
        id: j['id'],
        patientId: j['patientId'],
        patientName: j['patientName'],
        doctorId: j['doctorId'],
        doctorName: j['doctorName'],
        appointmentDateTime: DateTime.parse(j['appointmentDateTime']),
        durationMinutes: j['durationMinutes'],
        status: AppointmentStatus.values.byName(j['status']),
        type: j['type'] != null ? AppointmentType.values.byName(j['type']) : null,
        notes: j['notes'],
        reason: j['reason'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

// ─────────────────────────────────────────────
// TREATMENT
// ─────────────────────────────────────────────

class TreatmentRequest {
  final int patientId;
  final int? doctorId;
  final int? appointmentId;
  final String treatmentName;
  final String? description;
  final String? treatmentDate;
  final TreatmentStatus? status;
  final num? cost;
  final String? notes;
  final String? toothNumber;

  TreatmentRequest({
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    required this.treatmentName,
    this.description,
    this.treatmentDate,
    this.status,
    this.cost,
    this.notes,
    this.toothNumber,
  });

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        'treatmentName': treatmentName,
        if (description != null) 'description': description,
        if (treatmentDate != null) 'treatmentDate': treatmentDate,
        if (status != null) 'status': status!.name,
        if (cost != null) 'cost': cost,
        if (notes != null) 'notes': notes,
        if (toothNumber != null) 'toothNumber': toothNumber,
      };
}

class TreatmentResponse {
  final int id;
  final int patientId;
  final int? doctorId;
  final int? appointmentId;
  final String treatmentName;
  final String? description;
  final String? treatmentDate;
  final TreatmentStatus? status;
  final num? cost;
  final String? notes;
  final String? toothNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentResponse({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    required this.treatmentName,
    this.description,
    this.treatmentDate,
    this.status,
    this.cost,
    this.notes,
    this.toothNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> j) => TreatmentResponse(
        id: j['id'],
        patientId: j['patientId'],
        doctorId: j['doctorId'],
        appointmentId: j['appointmentId'],
        treatmentName: j['treatmentName'],
        description: j['description'],
        treatmentDate: j['treatmentDate'],
        status: j['status'] != null ? TreatmentStatus.values.byName(j['status']) : null,
        cost: j['cost'],
        notes: j['notes'],
        toothNumber: j['toothNumber'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

// ─────────────────────────────────────────────
// PRESCRIPTION
// ─────────────────────────────────────────────

class PrescriptionRequest {
  final int patientId;
  final int? doctorId;
  final int? appointmentId;
  final String? prescriptionDate;
  final String medications;
  final String? dosage;
  final String? instructions;
  final int? durationDays;

  PrescriptionRequest({
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    this.prescriptionDate,
    required this.medications,
    this.dosage,
    this.instructions,
    this.durationDays,
  });

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (prescriptionDate != null) 'prescriptionDate': prescriptionDate,
        'medications': medications,
        if (dosage != null) 'dosage': dosage,
        if (instructions != null) 'instructions': instructions,
        if (durationDays != null) 'durationDays': durationDays,
      };
}

class PrescriptionResponse {
  final int id;
  final int patientId;
  final int? doctorId;
  final int? appointmentId;
  final String? prescriptionDate;
  final String medications;
  final String? dosage;
  final String? instructions;
  final int? durationDays;
  final DateTime createdAt;

  PrescriptionResponse({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    this.prescriptionDate,
    required this.medications,
    this.dosage,
    this.instructions,
    this.durationDays,
    required this.createdAt,
  });

  factory PrescriptionResponse.fromJson(Map<String, dynamic> j) => PrescriptionResponse(
        id: j['id'],
        patientId: j['patientId'],
        doctorId: j['doctorId'],
        appointmentId: j['appointmentId'],
        prescriptionDate: j['prescriptionDate'],
        medications: j['medications'],
        dosage: j['dosage'],
        instructions: j['instructions'],
        durationDays: j['durationDays'],
        createdAt: DateTime.parse(j['createdAt']),
      );
}

// ─────────────────────────────────────────────
// INVOICE
// ─────────────────────────────────────────────

class InvoiceRequest {
  final int patientId;
  final int? treatmentId;
  final String? issueDate;
  final String? dueDate;
  final num totalAmount;
  final num paidAmount;
  final PaymentMethod? paymentMethod;
  final String? notes;

  InvoiceRequest({
    required this.patientId,
    this.treatmentId,
    this.issueDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        if (treatmentId != null) 'treatmentId': treatmentId,
        if (issueDate != null) 'issueDate': issueDate,
        if (dueDate != null) 'dueDate': dueDate,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
        if (notes != null) 'notes': notes,
      };
}

class InvoiceResponse {
  final int id;
  final String? invoiceNumber;
  final int patientId;
  final int? treatmentId;
  final String? issueDate;
  final String? dueDate;
  final num totalAmount;
  final num paidAmount;
  final num remainingAmount;
  final PaymentStatus? paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceResponse({
    required this.id,
    this.invoiceNumber,
    required this.patientId,
    this.treatmentId,
    this.issueDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> j) => InvoiceResponse(
        id: j['id'],
        invoiceNumber: j['invoiceNumber'],
        patientId: j['patientId'],
        treatmentId: j['treatmentId'],
        issueDate: j['issueDate'],
        dueDate: j['dueDate'],
        totalAmount: j['totalAmount'],
        paidAmount: j['paidAmount'],
        remainingAmount: j['remainingAmount'],
        paymentStatus: j['paymentStatus'] != null
            ? PaymentStatus.values.byName(j['paymentStatus'])
            : null,
        paymentMethod: j['paymentMethod'] != null
            ? PaymentMethod.values.byName(j['paymentMethod'])
            : null,
        notes: j['notes'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

// ─────────────────────────────────────────────
// INCOME
// ─────────────────────────────────────────────

class IncomeRequest {
  final int doctorId;
  final int? patientId;
  final String source;
  final String? description;
  final num amount;
  final String? incomeDate;
  final String? notes;

  IncomeRequest({
    required this.doctorId,
    this.patientId,
    required this.source,
    this.description,
    required this.amount,
    this.incomeDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        if (patientId != null) 'patientId': patientId,
        'source': source,
        if (description != null) 'description': description,
        'amount': amount,
        if (incomeDate != null) 'incomeDate': incomeDate,
        if (notes != null) 'notes': notes,
      };
}

class IncomeResponse {
  final int id;
  final int doctorId;
  final int? patientId;
  final String? patientName;
  final String source;
  final String? description;
  final num amount;
  final String? incomeDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  IncomeResponse({
    required this.id,
    required this.doctorId,
    this.patientId,
    this.patientName,
    required this.source,
    this.description,
    required this.amount,
    this.incomeDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeResponse.fromJson(Map<String, dynamic> j) => IncomeResponse(
        id: j['id'],
        doctorId: j['doctorId'],
        patientId: j['patientId'],
        patientName: j['patientName'],
        source: j['source'],
        description: j['description'],
        amount: j['amount'],
        incomeDate: j['incomeDate'],
        notes: j['notes'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

// ─────────────────────────────────────────────
// EXPENSE
// ─────────────────────────────────────────────

class ExpenseRequest {
  final int doctorId;
  final String category;
  final String? description;
  final num amount;
  final String? expenseDate;
  final String? notes;

  ExpenseRequest({
    required this.doctorId,
    required this.category,
    this.description,
    required this.amount,
    this.expenseDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'category': category,
        if (description != null) 'description': description,
        'amount': amount,
        if (expenseDate != null) 'expenseDate': expenseDate,
        if (notes != null) 'notes': notes,
      };
}

class ExpenseResponse {
  final int id;
  final int doctorId;
  final String category;
  final String? description;
  final num amount;
  final String? expenseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseResponse({
    required this.id,
    required this.doctorId,
    required this.category,
    this.description,
    required this.amount,
    this.expenseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> j) => ExpenseResponse(
        id: j['id'],
        doctorId: j['doctorId'],
        category: j['category'],
        description: j['description'],
        amount: j['amount'],
        expenseDate: j['expenseDate'],
        notes: j['notes'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );
}

// ─────────────────────────────────────────────
// STAFF
// ─────────────────────────────────────────────

class StaffRequest {
  final int doctorId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;

  StaffRequest({
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

class StaffResponse {
  final int id;
  final int doctorId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final bool enabled;
  final List<StaffPermission> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffResponse({
    required this.id,
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.enabled,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffResponse.fromJson(Map<String, dynamic> j) => StaffResponse(
        id: j['id'],
        doctorId: j['doctorId'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        enabled: j['enabled'],
        permissions: (j['permissions'] as List? ?? [])
            .map((e) => StaffPermission.values.byName(e))
            .toList(),
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );

  String get fullName => '$firstName $lastName';
}

// ─────────────────────────────────────────────
// NOTIFICATION
// ─────────────────────────────────────────────

class NotificationRequest {
  final int userId;
  final String message;
  final NotificationType type;

  NotificationRequest({required this.userId, required this.message, required this.type});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'message': message,
        'type': type.name,
      };
}

class NotificationResponse {
  final int id;
  final String message;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationResponse({
    required this.id,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> j) => NotificationResponse(
        id: j['id'],
        message: j['message'],
        type: NotificationType.values.byName(j['type']),
        read: j['read'],
        createdAt: DateTime.parse(j['createdAt']),
        readAt: j['readAt'] != null ? DateTime.parse(j['readAt']) : null,
      );
}

// ─────────────────────────────────────────────
// MESSAGING
// ─────────────────────────────────────────────

class ChatMessageResponse {
  final int id;
  final String content;
  final int senderId;
  final String? senderName;
  final int receiverId;
  final String? receiverName;
  final MessageStatus status;
  final DateTime sentAt;
  final DateTime? readAt;

  ChatMessageResponse({
    required this.id,
    required this.content,
    required this.senderId,
    this.senderName,
    required this.receiverId,
    this.receiverName,
    required this.status,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> j) => ChatMessageResponse(
        id: j['id'],
        content: j['content'],
        senderId: j['senderId'],
        senderName: j['senderName'],
        receiverId: j['receiverId'],
        receiverName: j['receiverName'],
        status: MessageStatus.values.byName(j['status']),
        sentAt: DateTime.parse(j['sentAt']),
        readAt: j['readAt'] != null ? DateTime.parse(j['readAt']) : null,
      );
}

class ConversationSummaryResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  final UserRole role;

  ConversationSummaryResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    required this.role,
  });

  factory ConversationSummaryResponse.fromJson(Map<String, dynamic> j) =>
      ConversationSummaryResponse(
        id: j['id'],
        firstName: j['firstName'],
        lastName: j['lastName'],
        imageUrl: j['imageUrl'],
        role: UserRole.values.byName(j['role']),
      );

  String get fullName => '$firstName $lastName';
}

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

class DashboardStats {
  final int totalPatients;
  final int totalAppointments;
  final int appointmentsToday;
  final int totalTreatments;
  final int totalPrescriptions;
  final num totalIncome;
  final num totalExpenses;
  final num netProfit;

  DashboardStats({
    required this.totalPatients,
    required this.totalAppointments,
    required this.appointmentsToday,
    required this.totalTreatments,
    required this.totalPrescriptions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalPatients: j['totalPatients'],
        totalAppointments: j['totalAppointments'],
        appointmentsToday: j['appointmentsToday'],
        totalTreatments: j['totalTreatments'],
        totalPrescriptions: j['totalPrescriptions'],
        totalIncome: j['totalIncome'],
        totalExpenses: j['totalExpenses'],
        netProfit: j['netProfit'],
      );
}

class AdminDashboardStats {
  final int totalDoctors;
  final int totalPatients;
  final int totalStaff;
  final int totalUsers;
  final int totalAppointments;
  final int totalTreatments;

  AdminDashboardStats({
    required this.totalDoctors,
    required this.totalPatients,
    required this.totalStaff,
    required this.totalUsers,
    required this.totalAppointments,
    required this.totalTreatments,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> j) => AdminDashboardStats(
        totalDoctors: j['totalDoctors'],
        totalPatients: j['totalPatients'],
        totalStaff: j['totalStaff'],
        totalUsers: j['totalUsers'],
        totalAppointments: j['totalAppointments'],
        totalTreatments: j['totalTreatments'],
      );
}

class FinancialSummaryResponse {
  final String month;
  final num totalIncome;
  final num totalExpenses;
  final num netProfit;

  FinancialSummaryResponse({
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
  });

  factory FinancialSummaryResponse.fromJson(Map<String, dynamic> j) =>
      FinancialSummaryResponse(
        month: j['month'],
        totalIncome: j['totalIncome'],
        totalExpenses: j['totalExpenses'],
        netProfit: j['netProfit'],
      );
}

// ─────────────────────────────────────────────
// PAGINATION WRAPPER
// ─────────────────────────────────────────────

class Page<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final List<T> content;
  final bool first;
  final bool last;

  Page({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.content,
    required this.first,
    required this.last,
  });

  factory Page.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      Page(
        totalElements: j['totalElements'],
        totalPages: j['totalPages'],
        size: j['size'],
        number: j['number'],
        content: (j['content'] as List).map((e) => fromJson(e)).toList(),
        first: j['first'],
        last: j['last'],
      );
}
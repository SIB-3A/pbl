import 'position_model.dart';
import 'department_model.dart';
import 'user_model.dart';

class EmployeeModel {
  final dynamic id;
  final dynamic userId;
  final String firstName;
  final String lastName;
  final String gender;
  final String address;
  final String employmentStatus;
  final int? positionId;
  final int? departmentId;
  final String? profilePhoto; 
  final String? profilePhotoUrl; 
  final PositionModel? position;
  final DepartmentModel? department;
  final UserModel? user;
  final String? createdAt;
  final String? updatedAt;

  EmployeeModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.address,
    required this.employmentStatus,
    this.positionId,
    this.departmentId,
    this.profilePhoto, 
    this.profilePhotoUrl, 
    this.position,
    this.department,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  // Getter untuk kompatibilitas
  String get idString => id.toString();
  String get userIdString => userId.toString();
  int get positionIdInt => positionId ?? 0;
  int get departmentIdInt => departmentId ?? 0;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    // Handle id
    dynamic idValue;
    if (json['id'] != null) {
      if (json['id'] is int) {
        idValue = json['id'];
      } else if (json['id'] is String) {
        idValue = json['id'];
      } else {
        idValue = json['id'].toString();
      }
    } else {
      idValue = 0;
    }

    // Handle userId
    dynamic userIdValue;
    if (json['user_id'] != null) {
      if (json['user_id'] is int) {
        userIdValue = json['user_id'];
      } else if (json['user_id'] is String) {
        userIdValue = json['user_id'];
      } else {
        userIdValue = json['user_id'].toString();
      }
    } else {
      userIdValue = 0;
    }

    // Handle positionId
    int? positionIdValue;
    if (json['position_id'] != null) {
      if (json['position_id'] is int) {
        positionIdValue = json['position_id'];
      } else {
        positionIdValue = int.tryParse(json['position_id'].toString());
      }
    }

    // Handle departmentId
    int? departmentIdValue;
    final departmentData = json['department_id'] ?? json['departement_id'];
    if (departmentData != null) {
      if (departmentData is int) {
        departmentIdValue = departmentData;
      } else {
        departmentIdValue = int.tryParse(departmentData.toString());
      }
    }

    // Handle employment status
    String employmentStatusValue = 'aktif';
    if (json['employment_status'] != null) {
      employmentStatusValue = json['employment_status'].toString();
    } else if (json['employement_status'] != null) {
      employmentStatusValue = json['employement_status'].toString();
    }

    return EmployeeModel(
      id: idValue,
      userId: userIdValue,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      employmentStatus: employmentStatusValue,
      positionId: positionIdValue,
      departmentId: departmentIdValue,
      profilePhoto: json['profile_photo'], 
      profilePhotoUrl: json['profile_photo_url'], 
      position: json['position'] != null
          ? PositionModel.fromJson(json['position'])
          : null,
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'])
          : null,
      user: json['user'] != null
          ? UserModel<dynamic>.fromJsonSimple(json['user'])
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'gender': gender,
    'address': address,
    'employment_status': employmentStatus,
    'position_id': positionId,
    'department_id': departmentId,
    'user_id': userId is int ? userId : int.tryParse(userId.toString()),
    'profile_photo': profilePhoto, 
  };

  // For profile update (employee only)
  Map<String, dynamic> toProfileJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'gender': gender,
    'address': address,
    // profile_photo akan dihandle terpisah saat upload
  };

  // For management update (admin only)
  Map<String, dynamic> toManagementJson() => {
    'employment_status': employmentStatus,
    'position_id': positionId,
    'department_id': departmentId,
  };

  Map<String, dynamic> toLegacyJson() => {
    'id': id.toString(),
    'user_id': userId.toString(),
    'first_name': firstName,
    'last_name': lastName,
    'gender': gender,
    'address': address,
    'created_at': createdAt ?? '',
    'updated_at': updatedAt ?? '',
    'position_id': positionId ?? 0,
    'departement_id': departmentId ?? 0,
    'employement_status': employmentStatus,
    'profile_photo': profilePhoto, 
    'profile_photo_url': profilePhotoUrl, 
  };

  Map<String, dynamic> toEmployeeScreenJson() {
    return {
      'id': id.toString(),
      'user_id': userId.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'address': address,
      'created_at': createdAt ?? '',
      'updated_at': updatedAt ?? '',
      'position_id': positionId ?? 0,
      'departement_id': departmentId ?? 0,
      'employement_status': employmentStatus,
      'profile_photo': profilePhoto, 
      'profile_photo_url': profilePhotoUrl, 
    };
  }
}

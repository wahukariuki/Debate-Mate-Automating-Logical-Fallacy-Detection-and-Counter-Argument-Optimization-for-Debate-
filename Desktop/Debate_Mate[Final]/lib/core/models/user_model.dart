import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a Debate Mate user
/// Contains user information including authentication preferences and role
class UserModel {
  final String uid;
  final String email;
  final String role; // 'debater' or 'admin'
  final String twoFactorPreference; // 'sms' or 'email'
  final String? phone; // Required if twoFactorPreference is 'sms'
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? emailVerifiedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.twoFactorPreference,
    this.phone,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.emailVerifiedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'debater',
      twoFactorPreference: data['twoFactorPreference'] ?? 'email',
      phone: data['phone'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      emailVerifiedAt: data['emailVerifiedAt'] != null 
          ? (data['emailVerifiedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'twoFactorPreference': twoFactorPreference,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'emailVerifiedAt': emailVerifiedAt != null ? Timestamp.fromDate(emailVerifiedAt!) : null,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    String? twoFactorPreference,
    String? phone,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? emailVerifiedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      twoFactorPreference: twoFactorPreference ?? this.twoFactorPreference,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  /// Check if user is an admin
  bool get isAdmin => role == 'admin';

  /// Check if user is a debater
  bool get isDebater => role == 'debater';

  /// Check if user has SMS 2FA enabled
  bool get hasSms2FA => twoFactorPreference == 'sms';

  /// Check if user has email 2FA enabled
  bool get hasEmail2FA => twoFactorPreference == 'email';

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, role: $role, twoFactorPreference: $twoFactorPreference, phone: $phone, isEmailVerified: $isEmailVerified, emailVerifiedAt: $emailVerifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.role == role &&
        other.twoFactorPreference == twoFactorPreference &&
        other.phone == phone &&
        other.isEmailVerified == isEmailVerified &&
        other.emailVerifiedAt == emailVerifiedAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        role.hashCode ^
        twoFactorPreference.hashCode ^
        phone.hashCode ^
        isEmailVerified.hashCode ^
        emailVerifiedAt.hashCode;
  }
}

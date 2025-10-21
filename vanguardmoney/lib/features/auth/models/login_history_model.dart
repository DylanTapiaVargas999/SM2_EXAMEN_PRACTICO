import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para el historial de inicio de sesión
class LoginHistoryModel {
  final String id;
  final String userId;
  final String email;
  final String displayName;
  final DateTime loginDate;
  final String ipAddress;

  const LoginHistoryModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.loginDate,
    required this.ipAddress,
  });

  /// Factory constructor para crear desde Firestore
  factory LoginHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoginHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Usuario',
      loginDate: (data['loginDate'] as Timestamp).toDate(),
      ipAddress: data['ipAddress'] ?? 'Desconocida',
    );
  }

  /// Factory constructor para crear desde JSON
  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoginHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Usuario',
      loginDate: json['loginDate'] is Timestamp
          ? (json['loginDate'] as Timestamp).toDate()
          : DateTime.parse(json['loginDate'] as String),
      ipAddress: json['ipAddress'] ?? 'Desconocida',
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'loginDate': Timestamp.fromDate(loginDate),
      'ipAddress': ipAddress,
    };
  }

  /// Método para copiar con nuevos valores
  LoginHistoryModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? displayName,
    DateTime? loginDate,
    String? ipAddress,
  }) {
    return LoginHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      loginDate: loginDate ?? this.loginDate,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  @override
  String toString() {
    return 'LoginHistoryModel(id: $id, userId: $userId, email: $email, displayName: $displayName, loginDate: $loginDate, ipAddress: $ipAddress)';
  }
}

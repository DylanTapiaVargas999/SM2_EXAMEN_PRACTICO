import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/login_history_model.dart';
import '../../../core/exceptions/error_handler.dart';

/// Servicio para manejar el historial de inicio de sesión
class LoginHistoryService {
  final FirebaseFirestore _firestore;

  LoginHistoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener dirección IP del usuario (usando servicio público)
  Future<String> _getUserIpAddress() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] ?? 'Desconocida';
      }
      return 'Desconocida';
    } catch (e) {
      // Si falla la obtención de IP, retornar valor por defecto
      return 'Desconocida';
    }
  }

  /// Registrar un nuevo inicio de sesión
  Future<void> registerLogin({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      // Obtener la dirección IP
      final ipAddress = await _getUserIpAddress();

      // Crear el registro de historial
      final loginHistory = LoginHistoryModel(
        id: '', // Se generará automáticamente
        userId: userId,
        email: email,
        displayName: displayName,
        loginDate: DateTime.now(),
        ipAddress: ipAddress,
      );

      // Guardar en Firestore
      await _firestore
          .collection('login_history')
          .add(loginHistory.toJson());
    } catch (e) {
      // No lanzar error para no interrumpir el flujo de login
      // Solo registrar el error
      print('Error al registrar historial de login: $e');
    }
  }

  /// Obtener el historial de inicios de sesión de un usuario
  /// Ordenado del más reciente al más antiguo
  Future<List<LoginHistoryModel>> getLoginHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('login_history')
          .where('userId', isEqualTo: userId)
          .orderBy('loginDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LoginHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  /// Stream del historial de inicios de sesión en tiempo real
  Stream<List<LoginHistoryModel>> getLoginHistoryStream(String userId) {
    try {
      return _firestore
          .collection('login_history')
          .where('userId', isEqualTo: userId)
          .orderBy('loginDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => LoginHistoryModel.fromFirestore(doc))
              .toList());
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  /// Eliminar historial antiguo (opcional - mantener solo últimos N registros)
  Future<void> cleanOldHistory(String userId, {int keepLast = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('login_history')
          .where('userId', isEqualTo: userId)
          .orderBy('loginDate', descending: true)
          .get();

      // Si hay más de 'keepLast' registros, eliminar los más antiguos
      if (querySnapshot.docs.length > keepLast) {
        final docsToDelete = querySnapshot.docs.skip(keepLast);
        final batch = _firestore.batch();

        for (var doc in docsToDelete) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e) {
      // No lanzar error, solo registrar
      print('Error al limpiar historial antiguo: $e');
    }
  }

  /// Eliminar todo el historial de un usuario
  Future<void> deleteAllHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('login_history')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }
}

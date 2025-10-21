import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/login_history_model.dart';
import '../services/auth_repository.dart';
import '../services/login_history_service.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Provider del AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider que escucha los cambios de estado de autenticación de Firebase
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider del LoginHistoryService
final loginHistoryServiceProvider = Provider<LoginHistoryService>((ref) {
  return LoginHistoryService();
});

/// Provider para obtener el historial de inicios de sesión del usuario actual
/// Stream que se actualiza en tiempo real
final loginHistoryStreamProvider = StreamProvider.autoDispose<List<LoginHistoryModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final loginHistoryService = ref.watch(loginHistoryServiceProvider);
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return loginHistoryService.getLoginHistoryStream(user.id);
});

/// Provider para obtener el historial de inicios de sesión del usuario actual
/// Versión Future (para cuando no se necesita actualizaciones en tiempo real)
final loginHistoryFutureProvider = FutureProvider.autoDispose<List<LoginHistoryModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final loginHistoryService = ref.watch(loginHistoryServiceProvider);
  
  if (user == null) {
    return [];
  }
  
  return await loginHistoryService.getLoginHistory(user.id);
});

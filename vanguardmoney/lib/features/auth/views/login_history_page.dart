import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../providers/auth_providers.dart';
import '../models/login_history_model.dart';

/// Página para mostrar el historial de inicios de sesión del usuario
class LoginHistoryPage extends ConsumerWidget {
  const LoginHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginHistoryAsync = ref.watch(loginHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Sesiones'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loginHistoryAsync.when(
        data: (loginHistory) {
          if (loginHistory.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildHistoryList(context, loginHistory);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(context, error),
      ),
    );
  }

  /// Widget para mostrar la lista de historial
  Widget _buildHistoryList(BuildContext context, List<LoginHistoryModel> history) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.spaceM),
      itemCount: history.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.spaceS),
      itemBuilder: (context, index) {
        final loginEntry = history[index];
        return _buildHistoryCard(context, loginEntry);
      },
    );
  }

  /// Widget para mostrar una tarjeta de historial
  Widget _buildHistoryCard(BuildContext context, LoginHistoryModel loginEntry) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con icono y nombre de usuario
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.blueClassic.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    Icons.login,
                    color: AppColors.blueClassic,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loginEntry.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontSizeM,
                        ),
                      ),
                      SizedBox(height: AppSizes.spaceXS),
                      Text(
                        loginEntry.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyDark,
                          fontSize: AppSizes.fontSizeS,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizes.spaceM),
            
            // Divider
            Divider(color: AppColors.greyLight, height: 1),
            
            SizedBox(height: AppSizes.spaceM),
            
            // Información de fecha y hora
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.greyDark,
                ),
                SizedBox(width: AppSizes.spaceS),
                Text(
                  'Fecha: ${dateFormat.format(loginEntry.loginDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackGrey,
                    fontSize: AppSizes.fontSizeS,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizes.spaceS),
            
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.greyDark,
                ),
                SizedBox(width: AppSizes.spaceS),
                Text(
                  'Hora: ${timeFormat.format(loginEntry.loginDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackGrey,
                    fontSize: AppSizes.fontSizeS,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizes.spaceS),
            
            // Información de IP
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: AppColors.greyDark,
                ),
                SizedBox(width: AppSizes.spaceS),
                Text(
                  'IP: ${loginEntry.ipAddress}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackGrey,
                    fontSize: AppSizes.fontSizeS,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppColors.greyMedium,
            ),
            SizedBox(height: AppSizes.spaceL),
            Text(
              'No hay historial de sesiones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.spaceM),
            Text(
              'Aquí se mostrarán tus inicios de sesión',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado de error
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.redCoral,
            ),
            SizedBox(height: AppSizes.spaceL),
            Text(
              'Error al cargar el historial',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.redCoral,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.spaceM),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.greyDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

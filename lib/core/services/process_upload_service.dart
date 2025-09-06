import 'package:flutter/foundation.dart';
import './api_service.dart';
import './serv_users/auth_service.dart';

class ProcessUploadService {
  static final ProcessUploadService _instance =
      ProcessUploadService._internal();
  factory ProcessUploadService() => _instance;
  ProcessUploadService._internal();

  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> uploadProcess({
    required String groupId,
    required String processName,
    required List<String> pausePlanIds,
  }) async {
    try {
      debugPrint('🔄 Subiendo proceso...');

      // Crear fechas automáticamente
      final now = DateTime.now().toUtc();
      final oneYearFromNow = DateTime(now.year + 1, now.month, now.day).toUtc();

      final processData = {
        'groupId': groupId,
        'processName': processName,
        'pausePlanIds': pausePlanIds,
        'startDate': now.toIso8601String(),
        'endDate': oneYearFromNow.toIso8601String(),
      };

      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      debugPrint('📦 Datos del proceso: $processData');

      final response = await _apiService.post(
        endpoint: '/admin/process-upload',
        data: processData,
        token: token,
      );

      if (response['status'] == true) {
        debugPrint('✅ Proceso subido exitosamente');
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error subiendo proceso');
    } catch (e) {
      debugPrint('❌ Error en uploadProcess: $e');
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';

class ProcessService {
  static Future<Map<String, dynamic>> uploadProcess({
    required String groupId,
    required String processName,
    required List<String> pausePlanIds,
    required DateTime startDate,
    DateTime? endDate,
    List<Map<String, dynamic>>? notifications,
  }) async {
    try {
      debugPrint('📤 Preparando datos del proceso...');

      // Asegurar que las fechas estén en UTC y formato ISO8601
      final DateTime startUtc = startDate.toUtc();
      final DateTime endUtc =
          (endDate ?? startUtc.add(const Duration(days: 365))).toUtc();

      final processData = {
        'groupId': groupId,
        'processName': processName,
        'pausePlanIds': pausePlanIds,
        'startDate': startUtc.toIso8601String(),
      };

      debugPrint('📦 Datos a enviar: $processData');

      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      debugPrint('📦 Datos del proceso a enviar: $processData');

      final response = await ApiService().post(
        endpoint: '/admin/process-upload',
        data: processData,
        token: token,
      );

      debugPrint('📡 Respuesta: $response');

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error al crear el proceso');
      }

      return response['data'];
    } catch (e) {
      debugPrint('❌ Error en uploadProcess: $e');
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../../data/models/pause_history.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';

class HistoryService {
  static Future<List<PauseHistory>> getPauseHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('📝 Solicitando historial de pausas...');
      
      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró un token de administrador');
      }

      final response = await ApiService().get(
        '/admin/pause-history?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'
      );
      
      if (response['status'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((item) => PauseHistory.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error obteniendo historial: $e');
      rethrow;
    }
  }

  static Future<String> exportHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('📊 Exportando historial...');
      
      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró un token de administrador');
      }

      final response = await ApiService().post(
        endpoint: '/admin/pause-history/export',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        token: token,
      );

      if (response['status'] == true && response['data'] != null) {
        return response['data']['url'] as String;
      }

      throw Exception('Error al exportar datos');
    } catch (e) {
      debugPrint('❌ Error exportando historial: $e');
      rethrow;
    }
  }
}

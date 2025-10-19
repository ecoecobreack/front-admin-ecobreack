import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';
import 'drive_service.dart';

class ActivityService {
  static Future<Map<String, dynamic>> createActivity({
    required String name,
    required String description,
    required int maxTime,
    required List<String> steps,
    required String icon,
    required String videoUrl,
    required bool sensorEnabled,
  }) async {
    try {
      debugPrint('📝 Iniciando creación de actividad...');
      debugPrint('📋 Datos recibidos:');
      debugPrint('- Nombre: $name');
      debugPrint('- Descripción: ${description.length} caracteres');
      debugPrint('- Tiempo máximo: $maxTime segundos');
      debugPrint('- Pasos: ${steps.length} pasos');
      debugPrint('- Icono: $icon');
      debugPrint('- Video ID: $videoUrl');
      debugPrint('- Sensor: ${sensorEnabled ? "Activado" : "Desactivado"}');

      if (maxTime <= 0) {
        throw Exception(
          'El tiempo máximo debe ser mayor a 0 segundos (recibido: $maxTime)',
        );
      }

      if (name.trim().isEmpty) {
        throw Exception('El nombre no puede estar vacío');
      }

      if (description.trim().isEmpty) {
        throw Exception('La descripción no puede estar vacía');
      }

      // Validación adicional del ID del video
      if (videoUrl.isEmpty) {
        throw Exception('El ID del video es requerido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró un token de administrador');
      }

      final exerciseData = {
        'nombre': name.trim(), // Placeholder for backend requirement
        'duracion': maxTime, // Using maxTime as duration
        'descripcion': description.trim(),
        'pasos': steps.map((step) => step.trim()).toList(),
        'icono': "Icons.visibility",
        'videoUrl': videoUrl,
        'sensorEnabled': sensorEnabled,
        'idCategory': "xeL6ZXfHmLKtcvRSM8sE",
        // Remove createdAt from request, let backend handle it
      };

      debugPrint('📦 Enviando datos al servidor: $exerciseData');

      final response = await ApiService().post(
        endpoint: '/admin/exercises',
        data: exerciseData,
        token: token,
      );

      debugPrint('✅ Respuesta del servidor: $response');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creando actividad: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getActivities() async {
    try {
      debugPrint('📝 Solicitando lista de actividades...');

      // Try to get token with refresh
      String? token;
      for (int i = 0; i < 2; i++) {
        token = await AuthService.getAdminToken(forceRefresh: i > 0);
        if (token != null) break;
        if (i == 0) await Future.delayed(const Duration(milliseconds: 500));
      }

      if (token == null) {
        throw Exception('No se encontró un token de administrador');
      }

      final response = await ApiService().get(
        '/admin/exercises',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response['status'] == true && response['data'] != null) {
        debugPrint('✅ Actividades cargadas exitosamente');
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error obteniendo actividades: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateActivity({
    required String id,
    required String name,
    required String description,
    required int maxTime,
    required String videoUrl,
    required bool sensorEnabled,
    required String icon,
    required List<String> steps,
  }) async {
    try {
      // Validate inputs first
      if (name.trim().isEmpty) {
        throw Exception('El nombre no puede estar vacío');
      }
      if (description.trim().isEmpty) {
        throw Exception('La descripción no puede estar vacía');
      }
      if (maxTime > 300) {
        throw Exception('Tiempo máximo no puede exceder 300 segundos');
      }

      // Get fresh token with retry logic
      String? token;
      for (int i = 0; i < 2; i++) {
        token = await AuthService.getAdminToken(forceRefresh: i > 0);
        if (token != null) break;
        if (i == 0) {
          debugPrint('🔄 Intentando refrescar token...');
          continue;
        }
      }

      if (token == null) {
        throw Exception('No se pudo obtener un token válido');
      }

      final sanitizedData = {
        'nombre': _sanitizeString(name),
        'descripcion': _sanitizeString(description),
        'pasos': steps.map(_sanitizeString).toList(),
        'duracion': maxTime,
        'icono': icon,
        'videoUrl': _sanitizeString(videoUrl),
        'sensorEnabled': sensorEnabled,
      };

      debugPrint('📤 Enviando actualización a servidor...');
      final response = await ApiService().put(
        endpoint: '/admin/exercises/$id',
        data: sanitizedData,
        token: token,
      );

      debugPrint('✅ Actividad actualizada exitosamente');
      return response;
    } catch (e) {
      debugPrint('❌ Error actualizando actividad: $e');
      rethrow;
    }
  }

  static String _sanitizeString(String value) {
    return value
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '')
        .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '')
        .trim();
  }

  static Future<void> deleteActivity(String id) async {
    try {
      debugPrint('🗑️ Eliminando actividad: $id');

      if (id.isEmpty) {
        throw Exception('ID de actividad no válido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await ApiService().delete(
        endpoint: 'admin/exercises/$id', // Sin slash inicial
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando actividad');
      }

      debugPrint('✅ Actividad eliminada exitosamente');
    } catch (e) {
      debugPrint('❌ Error eliminando actividad: $e');
      rethrow;
    }
  }

  static Future<void> deleteMultipleActivities(List<String> ids) async {
    try {
      debugPrint('🗑️ Eliminando ${ids.length} actividades...');

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      // Eliminar actividades en paralelo
      await Future.wait(
        ids.map(
          (id) => ApiService().delete(
            endpoint: 'admin/activities/$id',
            token: token,
          ),
        ),
      );

      debugPrint('✅ ${ids.length} actividades eliminadas exitosamente');
    } catch (e) {
      debugPrint('❌ Error eliminando múltiples actividades: $e');
      rethrow;
    }
  }
}

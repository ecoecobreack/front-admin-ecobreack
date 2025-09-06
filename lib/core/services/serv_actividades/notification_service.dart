import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../../data/models/notification_model.dart';
import '../../../data/models/notification_plan.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      final response = await _apiService.get('/admin/notifications');

      if (response['status'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      rethrow;
    }
  }

  Future<List<NotificationPlan>> getNotificationPlans() async {
    try {
      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      final response = await ApiService().get(
        '/admin/notification-plans',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response['status'] == true && response['data'] != null) {
        final plans =
            (response['data'] as List)
                .map((item) => NotificationPlan.fromJson(item))
                .toList();

        // Ordenar por fecha de inicio
        plans.sort((a, b) => a.startDate.compareTo(b.startDate));

        return plans;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting notification plans: $e');
      rethrow;
    }
  }

  Future<NotificationPlan> createNotificationPlan(NotificationPlan plan) async {
    try {
      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      debugPrint('📤 Enviando plan al servidor: ${plan.toJson()}');

      final response = await _apiService.post(
        endpoint: '/admin/notification-plans',
        data: plan.toJson(),
        token: token,
      );

      if (response['status'] == true && response['data'] != null) {
        debugPrint('✅ Plan creado exitosamente');
        return NotificationPlan.fromJson(response['data']);
      }
      throw Exception(
        response['message'] ?? 'Error al crear plan de notificación',
      );
    } catch (e) {
      debugPrint('❌ Error creating notification plan: $e');
      rethrow;
    }
  }

  Future<void> updatePlanStatus(String planId, bool isActive) async {
    try {
      debugPrint('🔄 Actualizando estado del plan: $planId -> $isActive');

      if (planId.isEmpty) {
        throw Exception('ID de plan inválido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _apiService.put(
        endpoint: '/admin/notification-plans/$planId/status',
        data: {'isActive': isActive},
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando estado');
      }

      debugPrint('✅ Estado actualizado correctamente');
    } catch (e) {
      debugPrint('❌ Error actualizando estado del plan: $e');
      rethrow;
    }
  }

  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required String type,
    DateTime? scheduledFor,
    String? time,
    List<String>? targetUsers,
  }) async {
    try {
      final token = await AuthService.getAdminToken();
      if (token == null) throw Exception('No autorizado');

      final response = await _apiService.post(
        endpoint: '/admin/notifications',
        data: {
          'title': title,
          'message': message,
          'type': type,
          'scheduledFor': scheduledFor?.toIso8601String(),
          'time': time,
          'targetUsers': targetUsers,
        },
        token: token,
      );

      if (response['status'] == true && response['data'] != null) {
        return NotificationModel.fromJson(response['data']);
      }
      throw Exception('Error al crear notificación');
    } catch (e) {
      debugPrint('❌ Error creating notification: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      debugPrint('🗑️ Eliminando plan: $id');

      if (id.isEmpty) {
        throw Exception('ID del plan no válido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _apiService.delete(
        endpoint: 'admin/notification-plans/$id', // Removed leading slash
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando el plan');
      }

      debugPrint('✅ Plan eliminado correctamente');
    } catch (e) {
      debugPrint('❌ Error eliminando plan de notificación: $e');
      rethrow;
    }
  }

  Future<void> onPausePlanCreated(Map<String, dynamic> pausePlan) async {
    try {
      debugPrint('🔄 Procesando nuevo plan de pausas para notificaciones...');
      debugPrint('📦 Plan recibido: ${json.encode(pausePlan)}');

      // Crear plan de notificaciones automáticamente
      final notificationPlan = NotificationPlan(
        name: 'Recordatorios: ${pausePlan['name']}',
        startDate: DateTime.parse(pausePlan['startDate']),
        endDate: DateTime.parse(pausePlan['endDate']),
        time: pausePlan['time'] ?? '08:00', // Valor por defecto si no existe
        assignedPlans: {}, // Se llenarán manualmente desde la UI
        id: '', // ID vacío ya que es nuevo
      );

      final result = await createNotificationPlan(notificationPlan);
      debugPrint('✅ Plan de notificaciones creado: ${result.id}');
      debugPrint('📅 Período: ${result.startDate} - ${result.endDate}');
    } catch (e) {
      debugPrint('❌ Error en sincronización de planes: $e');
      rethrow;
    }
  }
}

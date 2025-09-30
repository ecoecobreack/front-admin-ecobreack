import 'package:flutter/material.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';
import '../../../data/models/process_group.dart';
import '../../../data/models/user.dart';

class ProcessGroupService {
  static final ProcessGroupService _instance = ProcessGroupService._internal();
  factory ProcessGroupService() => _instance;
  ProcessGroupService._internal();

  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getGroups() async {
    try {
      debugPrint('🔄 Obteniendo grupos de proceso...');
      final token = await AuthService.getAdminToken();

      if (token == null) {
        throw Exception('No autorizado');
      }

      final response = await _apiService.get(
        '/admin/process-groups',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response['status'] == true) {
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error obteniendo grupos');
    } catch (e) {
      debugPrint('❌ Error en getGroups: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required int color,
    List<User> members = const [],
  }) async {
    try {
      debugPrint('🔄 Creando nuevo grupo...');
      final token = await AuthService.getAdminToken();

      if (token == null) {
        throw Exception('No autorizado');
      }

      final hexColor = color; // Usando el valor numérico ARGB del color

      final response = await _apiService.post(
        endpoint: '/admin/process-groups',
        data: {
          'name': name,
          'description': description,
          'color': hexColor,
          'members': members.map((user) => user.toJson()).toList(),
        },
        token: token,
      );

      if (response['status'] == true) {
        debugPrint('✅ Grupo creado exitosamente');
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error creando grupo');
    } catch (e) {
      debugPrint('❌ Error en createGroup: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateGroup(Map<String, dynamic> group) async {
    try {
      debugPrint('🔄 Actualizando grupo ${group['id']}...');
      final token = await AuthService.getAdminToken();

      if (token == null) {
        throw Exception('No autorizado');
      }

      final response = await _apiService.put(
        endpoint: '/admin/process-groups/${group['id']}',
        data: group,
        token: token,
      );

      debugPrint('📝 Respuesta del servidor: ${response.toString()}');

      if (response['status'] == true) {
        debugPrint('✅ Grupo actualizado exitosamente');
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error actualizando grupo');
    } catch (e) {
      debugPrint('❌ Error en updateGroup: $e');
      rethrow;
    }
  }

  Future<void> deletePlans(List<String> planIds, String groupId) async {
    try {
      debugPrint('🗑️ Eliminando planes: $planIds');

      if (planIds.isEmpty) {
        throw Exception('No se proporcionaron IDs de planes para eliminar');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _apiService.delete(
        endpoint: 'admin/process-groups/$groupId/plans', // Sin slash inicial
        body: {'ids': planIds},
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando los planes');
      }

      debugPrint('✅ Planes eliminados correctamente');
    } catch (e) {
      debugPrint('❌ Error en deletePlans: $e');
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      debugPrint('🗑️ Eliminando grupo: $groupId');

      if (groupId.isEmpty) {
        throw Exception('ID del grupo no válido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _apiService.delete(
        endpoint: 'admin/process-groups/$groupId', // Sin slash inicial
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando el grupo');
      }

      debugPrint('✅ Grupo eliminado correctamente');
    } catch (e) {
      debugPrint('❌ Error en deleteGroup: $e');
      rethrow;
    }
  }

  Future<void> deleteProcess(String id) async {
    try {
      debugPrint('🗑️ Eliminando proceso: $id');

      if (id.isEmpty) {
        throw Exception('ID del proceso no válido');
      }

      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _apiService.delete(
        endpoint: 'admin/notification-plans/process/$id', // Sin slash inicial
        token: token,
      );

      if (response['status'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando el proceso');
      }

      debugPrint('✅ Proceso eliminado correctamente');
    } catch (e) {
      debugPrint('❌ Error en deleteProcess: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateGroupMembers(
    String groupId,
    List<User> members,
  ) async {
    try {
      debugPrint('🔄 Actualizando miembros del grupo $groupId...');
      final token = await AuthService.getAdminToken();

      if (token == null) {
        throw Exception('No autorizado');
      }

      List<User> validMembers =
          members.where((user) => user.id.isNotEmpty).toList();
      List<String> userIds = validMembers.map((user) => user.id).toList();

      debugPrint(
        '🔄 Enviando solicitud de actualización de miembros: $userIds',
      );

      final response = await _apiService.put(
        endpoint: '/admin/process-groups/$groupId/members',
        data: {'members': userIds},
        token: token,
      );

      debugPrint('📝 Respuesta del servidor: ${response.toString()}');
      if (response['status'] == true) {
        debugPrint('✅ Miembros actualizados exitosamente');
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error actualizando miembros');
    } catch (e) {
      debugPrint('❌ Error en updateGroupMembers: $e');
      rethrow;
    }
  }
}

// Actualizar el método de extensión para usar toARGB32
extension ColorExtension on Color {
  String toHex() {
    final value = toARGB32();
    final hex = (value & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '#$hex';
  }
}

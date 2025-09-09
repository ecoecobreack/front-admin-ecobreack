import 'package:flutter/foundation.dart';
import '../api_service.dart';
import 'auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      debugPrint('🔄 Iniciando obtención de usuarios');
      final token = await AuthService.getAdminToken();

      if (token == null) {
        debugPrint('❌ Error: Token no encontrado');
        throw Exception('No autorizado');
      }

      debugPrint('🔑 Token obtenido correctamente');
      final apiService = ApiService();
      final response = await apiService.get('/admin/usersAll');

      debugPrint('📦 Respuesta del servidor:');
      debugPrint('- Status: ${response['status']}');
      debugPrint('- Tiene datos: ${response['data'] != null}');

      if (response['status'] == true && response['data'] != null) {
        final users = List<Map<String, dynamic>>.from(response['data']);
        debugPrint('✅ Usuarios obtenidos: ${users.length}');
        return users;
      }

      debugPrint('⚠️ No se encontraron usuarios');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error obteniendo usuarios: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      rethrow;
    }
  }
}

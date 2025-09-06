import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _storage = const FlutterSecureStorage();

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> authenticateAdmin(String email, String password) async {
    try {
      final response = await ApiService().authenticateAdmin(email, password);
      if (response['status'] == true) {
        final token = response['data']['token'];
        await FirebaseAuth.instance.signInWithCustomToken(token);
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        debugPrint('🔐 Admin authenticated, token obtained: $idToken');
        await _storage.write(key: 'admin_token', value: idToken);
        // Store credentials for refresh
        await _storage.write(key: 'admin_email', value: email);
        await _storage.write(key: 'admin_password', value: password);
        debugPrint('✅ Token almacenado exitosamente');
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      debugPrint('❌ Error en authenticateAdmin: $e');
      rethrow;
    }
  }

  static Future<String?> getAdminToken({bool forceRefresh = false}) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'admin_token');

      if (token == null || forceRefresh) {
        debugPrint('🔄 Token no encontrado o refresh forzado');

        final email = await storage.read(key: 'admin_email');
        final password = await storage.read(key: 'admin_password');

        if (email != null && password != null) {
          debugPrint('🔑 Reautenticando con credenciales guardadas');
          await authenticateAdmin(email, password);
          token = await storage.read(key: 'admin_token');
        }

        if (token == null) {
          debugPrint('❌ No se pudo obtener un nuevo token');
          return null;
        }
      }

      // Validar formato del token
      if (!token.contains('.') || token.split('.').length != 3) {
        debugPrint('❌ Token inválido, forzando reautenticación');
        return getAdminToken(forceRefresh: true);
      }

      debugPrint('✅ Token válido encontrado');
      return token;
    } catch (e) {
      debugPrint('❌ Error obteniendo token: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _storage.delete(key: 'admin_token');
      debugPrint('✅ Token eliminado exitosamente');
    } catch (e) {
      debugPrint('❌ Error en logout: $e');
      rethrow;
    }
  }
}

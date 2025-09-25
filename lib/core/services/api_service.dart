import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'serv_users/auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);

  static Future<String> resolveBaseUrl() async {
    if (kDebugMode) {
      // For local development
      return 'https://backeco-zwl8.onrender.com/';
    }
    // For production
    return 'https://backeco-zwl8.onrender.com/'; // Update with your production URL
  }

  String _getOrigin() {
    if (kIsWeb) {
      return 'https://backeco-zwl8.onrender.com/';
    }
    return 'https://backeco-zwl8.onrender.com/';
  }

  Future<Map<String, dynamic>> authenticateAdmin(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔐 Autenticando admin con email: $email');
      final baseUrl = await resolveBaseUrl();
      debugPrint(
        '🔐 Intentando autenticar admin en: $baseUrl/admin/login/privileged',
      );

      final response = await _client
          .post(
            Uri.parse('$baseUrl/admin/login/privileged'),
            headers: {
              'Content-Type': 'application/json',
              'Origin': _getOrigin(),
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      debugPrint('📡 Código de respuesta: ${response.statusCode}');
      final responseData = json.decode(response.body);
      debugPrint('📝 Respuesta: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          debugPrint('✅ Autenticación exitosa');
          return responseData;
        }
      }

      throw Exception(responseData['message'] ?? 'Error de autenticación');
    } catch (e, stackTrace) {
      debugPrint('❌ Error en autenticación: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final token = await AuthService.getAdminToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final Uri uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: query);

      final requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        ...?headers,
      };

      debugPrint('🔄 GET request to: $uri');
      debugPrint('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(_timeout);

      // Handle authentication errors
      if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await AuthService.getAdminToken(forceRefresh: true);
        if (newToken != null) {
          requestHeaders['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _client
              .get(uri, headers: requestHeaders)
              .timeout(_timeout);

          if (retryResponse.statusCode == 200) {
            return json.decode(retryResponse.body);
          }
        }
        throw Exception('Token inválido o expirado');
      }

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData;
      }

      throw Exception(
        responseData['message'] ?? 'Error en la respuesta del servidor',
      );
    } catch (e) {
      debugPrint('❌ Error en petición GET: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final uri = Uri.parse('$baseUrl$endpoint');

      // Remove any undefined or null values
      final cleanData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null);

      // Sanitize the data
      final sanitizedData = _sanitizeData(cleanData);

      debugPrint('🔄 POST request to: $uri');
      debugPrint('📦 Clean data: $sanitizedData');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: json.encode(sanitizedData),
          )
          .timeout(_timeout);

      // Decode response with UTF-8
      final String decodedBody = utf8.decode(response.bodyBytes);
      final responseData = json.decode(decodedBody) as Map<String, dynamic>;

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📝 Response data: $responseData');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      }

      throw Exception(
        responseData['message'] ??
            'Error ${response.statusCode}: ${response.reasonPhrase}',
      );
    } catch (e) {
      debugPrint('❌ Error en POST request: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('🔄 PUT request to: $uri');
      debugPrint('🔑 Using token: ${token.substring(0, 20)}...');

      // Validar token antes de hacer la petición
      if (!token.contains('.') || token.split('.').length != 3) {
        throw Exception('Token inválido');
      }

      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(_sanitizeData(data)),
          )
          .timeout(_timeout);

      if (response.statusCode == 403) {
        // Intentar refrescar token y reintentar
        final newToken = await AuthService.getAdminToken(forceRefresh: true);
        if (newToken != null) {
          return put(endpoint: endpoint, data: data, token: newToken);
        }
        throw Exception('Sesión expirada');
      }

      final responseData = json.decode(utf8.decode(response.bodyBytes));
      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📝 Response data: $responseData');

      if (response.statusCode == 200) {
        return responseData;
      }

      throw Exception(responseData['message'] ?? 'Error en la operación PUT');
    } catch (e) {
      debugPrint('❌ Error en PUT request: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        // Clean strings
        return MapEntry(key, _sanitizeString(value));
      } else if (value is Map) {
        return MapEntry(key, _sanitizeData(value as Map<String, dynamic>));
      } else if (value is List) {
        return MapEntry(
          key,
          value
              .map(
                (e) =>
                    e is Map
                        ? _sanitizeData(e as Map<String, dynamic>)
                        : e is String
                        ? _sanitizeString(e)
                        : e,
              )
              .toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  String _sanitizeString(String value) {
    return value
        .replaceAll(
          RegExp(r'[\u0000-\u001F\u007F-\u009F]'),
          '',
        ) // Remove control chars
        .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '') // Remove surrogate pairs
        .trim();
  }

  Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body, // <-- nuevo parámetro
  }) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final cleanEndpoint =
          endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final url = '$baseUrl/$cleanEndpoint';

      debugPrint('🗑️ DELETE request to: $url');
      if (token != null) {
        debugPrint('🔑 Using token: ${token.substring(0, 20)}...');
      }

      final uri = Uri.parse(url);
      debugPrint('🔍 URI parsed: ${uri.toString()}');

      final response = await _client
          .delete(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
              ...?headers,
            },
            body:
                body != null
                    ? json.encode(body)
                    : null, // <-- aquí se envía el body
          )
          .timeout(_timeout);

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📝 Response data: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'status': true,
            'message': 'Eliminado correctamente',
            'statusCode': response.statusCode,
          };
        }
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'status': true,
            'message': 'Eliminado correctamente',
            'statusCode': response.statusCode,
          };
        }
      }

      throw Exception('Error en DELETE request: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en DELETE request: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createActivity(
    String token,
    Map<String, dynamic> activityData,
  ) async {
    try {
      final baseUrl = await resolveBaseUrl();

      final response = await _client
          .post(
            Uri.parse('$baseUrl/admin/activities'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(activityData),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['status'] == true) {
          return responseData;
        }
      }

      throw Exception(responseData['message'] ?? 'Error al crear actividad');
    } catch (e, stackTrace) {
      debugPrint('❌ Error en createActivity: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }
}

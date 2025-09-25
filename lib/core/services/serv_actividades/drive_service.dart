import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../serv_users/auth_service.dart';

class DriveService {
  static String getVideoName(Map<String, dynamic> video) {
    return video['id'];
  }

  static String? getStreamUrl(Map<String, dynamic> video) {
    return video['streamUrl'] ?? video['webContentLink'];
  }

  static String getEmbedUrl(String videoId) {
    return 'https://drive.google.com/file/d/$videoId/preview';
  }

  static String? extractFileId(String url) {
    try {
      if (url.contains('/file/d/')) {
        return url.split('/file/d/')[1].split('/')[0];
      } else if (url.contains('id=')) {
        return url.split('id=')[1].split('&')[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String cleanVideoId(String videoId) {
    try {
      if (videoId.contains('drive.google.com')) {
        // Si es una URL completa, extraer el ID
        final id = extractFileId(videoId);
        if (id == null) throw Exception('ID de video inválido');
        return id;
      } else if (videoId.contains('/')) {
        // Si contiene /, tomar la última parte
        return videoId.split('/').last;
      }
      // Si es solo el ID, devolverlo tal cual
      return videoId;
    } catch (e) {
      debugPrint('❌ Error limpiando ID de video: $e');
      throw Exception('ID de video inválido');
    }
  }

  static String cleanVideoUrl(String videoUrl) {
    if (videoUrl.contains('drive.google.com')) {
      final id = extractFileId(videoUrl);
      if (id == null) throw Exception('ID de video inválido');
      return id;
    } else if (videoUrl.endsWith('.mp4') ||
        videoUrl.endsWith('.webm') ||
        videoUrl.endsWith('.mov') ||
        videoUrl.endsWith('.avi')) {
      // Si es un archivo local, retornar el nombre tal cual
      return videoUrl;
    }
    throw Exception('Formato de video no soportado');
  }

  static Future<List<Map<String, dynamic>>> listVideos() async {
    try {
      debugPrint('📁 Solicitando lista de videos...');
      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró un token de administrador');
      }

      final response = await ApiService().get('/admin/drive/videos');

      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> rawVideos = response['data'];
        return rawVideos
            .map(
              (video) => {
                ...Map<String, dynamic>.from(video),
                'thumbnailUrl': video['thumbnailUrl'],
                'embedUrl': getEmbedUrl(video['id']),
                'name': video['name'] ?? 'Sin nombre',
                'size': video['size'] ?? 0,
                'duration': video['duration'],
              },
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error listando videos: $e');
      return [];
    }
  }

  static Future<bool> validateDriveFile(String url) async {
    try {
      String fileId = url;
      if (url.contains('drive.google.com')) {
        final extracted = extractFileId(url);
        if (extracted == null) return false;
        fileId = extracted;
      }

      final token = await AuthService.getAdminToken();
      if (token == null) return false;

      final response = await ApiService().get('/admin/drive/validate/$fileId');
      return response['status'] == true &&
          response['data']?['parents']?.contains(
                '1iSJMKnKE0oXp3QxlY03nsKQsv1KHMbhc',
              ) ==
              true;
    } catch (e) {
      debugPrint('❌ Error validando archivo: $e');
      return false;
    }
  }

  static Future<void> ensureVideoAccess(String videoId) async {
    try {
      debugPrint('🔒 Verificando acceso al video: $videoId');
      final token = await AuthService.getAdminToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await ApiService().get('/admin/drive/validate/$videoId');
      if (response['status'] != true) {
        throw Exception('No tienes permisos para acceder a este video');
      }
    } catch (e) {
      debugPrint('❌ Error verificando acceso al video: $e');
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';

class PlatformService {
  static bool get isAdminPlatform => 
    kIsWeb || defaultTargetPlatform == TargetPlatform.windows || 
    defaultTargetPlatform == TargetPlatform.macOS || 
    defaultTargetPlatform == TargetPlatform.linux;
}

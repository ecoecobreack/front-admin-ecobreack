import 'package:flutter/material.dart';
import 'package:web/web.dart' as web; // Usamos la API moderna
import 'dart:ui_web' as ui_web;

class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WebVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late final String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'webVideoPlayer-${widget.videoUrl}';
    _registerView();
  }

  void _registerView() {
    // Crear elemento iframe usando package:web
    final videoElement =
        web.HTMLIFrameElement()
          ..src = widget.videoUrl
          ..style.border = ''
          ..allowFullscreen = true;

    // Registrar la vista
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => videoElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}

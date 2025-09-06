import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class WebVideoPlayer extends StatefulWidget {
  final String embedUrl;

  const WebVideoPlayer({super.key, required this.embedUrl});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late final String _viewId;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-player-${DateTime.now().microsecondsSinceEpoch}';
    if (kIsWeb) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    try {
      final iframe =
          html.IFrameElement()
            ..src = widget.embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow =
                'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope'
            ..allowFullscreen = true;

      // Register view factory with the correct registry
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => iframe,
      );

      _setupEventListeners(iframe);
    } catch (e) {
      _handleError(e);
    }
  }

  void _setupEventListeners(html.IFrameElement iframe) {
    iframe.onLoad.listen((_) {
      if (mounted) setState(() => _isLoading = false);
    });

    iframe.onError.listen((_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error al cargar el video';
          _isLoading = false;
        });
      }
    });
  }

  void _handleError(dynamic error) {
    debugPrint('❌ Error initializing player: $error');
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child:
              _hasError
                  ? _buildErrorWidget()
                  : HtmlElementView(viewType: _viewId),
        ),
        if (_isLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF9ACA60)),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF9ACA60), size: 40),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: const TextStyle(color: Color(0xFF9ACA60)),
          ),
        ],
      ),
    );
  }
}

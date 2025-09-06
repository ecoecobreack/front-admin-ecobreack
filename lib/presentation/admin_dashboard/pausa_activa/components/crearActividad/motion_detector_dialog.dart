import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MotionDetectorDialog extends StatefulWidget {
  final bool sensorEnabled;

  const MotionDetectorDialog({super.key, required this.sensorEnabled});

  @override
  State<MotionDetectorDialog> createState() => _MotionDetectorDialogState();
}

class _MotionDetectorDialogState extends State<MotionDetectorDialog> {
  bool isDetectionComplete = false;
  bool isFirstAnimationComplete = false;
  bool isDetectionFailed = false;
  int secondsElapsed = 0;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.sensorEnabled) {
      startDetection();
    }
  }

  @override
  void didUpdateWidget(covariant MotionDetectorDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sensorEnabled && !oldWidget.sensorEnabled) {
      startDetection();
    } else if (!widget.sensorEnabled) {
      _stopAccelerometerListener();
    }
  }

  void startDetection() {
    setState(() {
      isFirstAnimationComplete = false;
      isDetectionComplete = false;
      isDetectionFailed = false;
      secondsElapsed = 0;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isFirstAnimationComplete = true;
        });
        _startAccelerometerListener();
      }
    });
  }

  void _startAccelerometerListener() {
    const movementThreshold = 15.0;
    const requiredDuration = 5; // seconds
    int secondsElapsed = 0;

    _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      final movement = (event.x.abs() + event.y.abs() + event.z.abs());
      if (movement > movementThreshold) {
        secondsElapsed++;
        setState(() {
          this.secondsElapsed = secondsElapsed;
        });

        if (secondsElapsed >= requiredDuration) {
          _registerPauseActivity();
          setState(() {
            isDetectionComplete = true;
            isDetectionFailed = false;
          });
          _stopAccelerometerListener();
          return;
        }
      }
    });

    _timer = Timer(const Duration(seconds: 6), () {
      if (secondsElapsed < requiredDuration) {
        setState(() {
          isDetectionFailed = true;
          isDetectionComplete = false;
        });
        _stopAccelerometerListener();
      }
    });
  }

  Future<void> _registerPauseActivity() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('pausas').add({
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'pausa_activa',
          'duration': 5,
        });
      }
    } catch (e) {
      debugPrint('Error registering pause activity: $e');
    }
  }

  void _stopAccelerometerListener() {
    _streamSubscription?.cancel();
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopAccelerometerListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFirstAnimationComplete) ...[
              Lottie.asset(
                'assets/animaciones/movimiento.json',
                width: 200,
                height: 200,
              ),
              const Text(
                'Prepárate para realizar tu pausa activa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
            ] else if (!isDetectionComplete && !isDetectionFailed) ...[
              Lottie.asset(
                'assets/animaciones/detectando.json',
                width: 200,
                height: 200,
              ),
              Text(
                'Mueve tu dispositivo suavemente\n$secondsElapsed/5 segundos',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
            ] else if (isDetectionFailed) ...[
              Lottie.asset(
                'assets/animaciones/fallo.json',
                width: 200,
                height: 200,
              ),
              const Text(
                '¡No se detectó suficiente movimiento!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  startDetection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0067AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'VOLVER A INTENTAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              Lottie.asset(
                'assets/animaciones/detectado_exito.json',
                width: 200,
                height: 200,
              ),
              const Text(
                '¡Movimiento detectado con éxito!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.pushNamed(context, '/actividad');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC6DA23),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'COMENZAR PAUSA ACTIVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:skinvista/screens/scan_result.dart';

import '../bloc/prediction/prediction_bloc.dart';
import '../bloc/prediction/prediction_event.dart';
import '../bloc/prediction/prediction_state.dart';
import '../core/locator.dart';
import '../repositories/prediction_repository.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  int _selectedCameraIndex = 1;
  bool _isSwitchingCamera = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  AnimationController? _scanLineController;
  Animation<double>? _scanLineAnimation;
  AnimationController? _targetController;
  Animation<double>? _targetAnimation;
  AnimationController? _flickerController;
  Animation<double>? _flickerAnimation;
  AnimationController? _zoomPulseController;
  Animation<double>? _zoomPulseAnimation;
  AnimationController? _segmentController;
  Animation<double>? _segmentAnimation;
  bool _showGuide = true;
  bool _flashOn = false;
  Color _captureColor = Colors.red;
  double _zoomLevel = 1.0;
  bool _isStable = false;
  bool _showFocusMessage = false;
  bool _showAnalysisMessage = false;
  bool _showConditionMessage = false;
  bool _hasConfirmedArea = false;
  bool _hasSeenWarning = false;
  bool _isLoading = false;

  final String _picPurifyApiKey = 'rR2xP51RMlMyJjA8C7MyLj5RVm06eUxc';

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _setupAnimations();
  }

  Future<void> _initializeCameras() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        await _initializeCameraController();
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<void> _initializeCameraController() async {
    if (cameras == null || cameras!.isEmpty) return;

    _selectedCameraIndex = _selectedCameraIndex.clamp(0, cameras!.length - 1);
    _controller = CameraController(
      cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _controller!.setZoomLevel(_zoomLevel);
      await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera controller: $e');
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _pulseController!, curve: Curves.easeOut));
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(CurvedAnimation(parent: _scanLineController!, curve: Curves.linear));
    _targetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _targetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _targetController!, curve: Curves.easeInOut));
    _flickerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _flickerAnimation = Tween<double>(begin: 0.6, end: 0.9).animate(CurvedAnimation(parent: _flickerController!, curve: Curves.easeInOut));
    _zoomPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _zoomPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _zoomPulseController!, curve: Curves.easeOut));
    _segmentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
    _segmentAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(CurvedAnimation(parent: _segmentController!, curve: Curves.linear));

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showGuide = false);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isStable = true);
        _flickerController!.stop();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSeenWarning) {
        _showWarningDialog();
      }
    });
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2 || _isSwitchingCamera) return;

    setState(() {
      _isSwitchingCamera = true;
    });

    try {
      final currentZoom = _zoomLevel;
      final currentFlash = _flashOn;

      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
      await _initializeCameraController();

      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.setZoomLevel(currentZoom);
        await _controller!.setFlashMode(currentFlash ? FlashMode.torch : FlashMode.off);
      }
    } catch (e) {
      print('Error switching camera: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingCamera = false;
        });
      }
    }
  }

  Future<bool> _isImageSafe(String imagePath) async {
    try {
      print("Starting _isImageSafe with imagePath: $imagePath");
      if (!File(imagePath).existsSync()) {
        print("Error: Image file does not exist at $imagePath");
        return true; // Assume safe if file doesn't exist
      }

      print("Preparing request to PicPurify API...");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://www.picpurify.com/analyse/1.1'),
      );
      request.fields['API_KEY'] = _picPurifyApiKey;
      request.fields['task'] = 'porn_moderation,suggestive_nudity_moderation';
      request.files.add(await http.MultipartFile.fromPath('file_image', imagePath));

      print("Request fields: ${request.fields}, files count: ${request.files.length}");
      print("Sending request to PicPurify API...");
      var response = await request.send().timeout(const Duration(seconds: 30), onTimeout: () {
        print("Request timed out after 30 seconds");
        return http.StreamedResponse(Stream.empty(), 408); // Timeout status
      });
      print("Received response stream, converting to Response...");
      var responseData = await http.Response.fromStream(response);

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${responseData.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(responseData.body);
        print("Decoded JSON: $result");
        if (result['status'] == 'success') {
          bool isPorn = result['porn_moderation']?['porn_content'] == 'true' || false;
          bool isNude = (result['nudity_moderation']?['raw_nudity_content'] == 'true' || false) ||
              (result['nudity_moderation']?['partial_nudity_content'] == 'true' || false);
          bool isSafe = !(isPorn || isNude);
          print("Image Safety Check: Porn: $isPorn, Nude: $isNude, Safe: $isSafe");
          return isSafe;
        } else {
          print("API Failed: ${result['error']['errorMsg'] ?? 'No error message'}");
          return true; // Assume safe on API failure
        }
      } else {
        print("API Error: Status ${response.statusCode}, Body: ${responseData.body}");
        return true; // Assume safe on non-200 status
      }
    } catch (e) {
      print("Exception in _isImageSafe: $e");
      return true; // Assume safe on exception
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Usage Instructions"),
        content: const Text(
          "Please use this app to photograph visible skin areas only (e.g., arms, legs, face). Do not take pictures of private or inappropriate areas. Misuse may result in account suspension.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _hasSeenWarning = true);
              Navigator.pop(context);
            },
            child: const Text("Understood"),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isLoading) return;

    setState(() {
      _isLoading = true;
      _captureColor = Colors.green;
      _showAnalysisMessage = true;
      _pulseController!.forward().then((_) => _pulseController!.reverse());
      _segmentController!.repeat();
    });

    try {
      XFile image = await _controller!.takePicture();
      print("Captured image at: ${image.path}, exists: ${File(image.path).existsSync()}");
      bool isSafe = await _isImageSafe(image.path);

      // Show the result modal
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ResultModal(
          imagePath: image.path,
          isAcceptable: isSafe,
          onProceed: isSafe
              ? () {
            Navigator.pop(context); // Close modal
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoaderScreen(imagePath: image.path),
              ),
            );
          }
              : null,
          onRetake: isSafe
              ? null
              : () {
            Navigator.pop(context); // Close modal
            setState(() {
              _hasConfirmedArea = false; // Reset to allow retake
            });
          },
        ),
      );

      if (isSafe) {
        await Gal.putImage(image.path);
      } else {
        await File(image.path).delete();
        print("Deleted unsafe image: ${image.path}");
      }
    } catch (e) {
      print("Error in _takePicture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing image")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _captureColor = Colors.red;
          _showAnalysisMessage = false;
          _showConditionMessage = false;
          _segmentController!.stop();
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized || _isSwitchingCamera) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _controller!.setFocusPoint(const Offset(0.5, 0.5));
          _pulseController!.forward().then((_) => _pulseController!.reverse());
          _targetController!.forward().then((_) => _targetController!.reverse());
          setState(() => _showFocusMessage = true);
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) setState(() => _showFocusMessage = false);
          });
        },
        child: Stack(
          children: [
            SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: CameraPreview(_controller!),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              ),
            ),
            Positioned(
              top: 40,
              right: 60,
              child: IconButton(
                icon: Icon(
                  _selectedCameraIndex == 0 ? Icons.camera_rear : Icons.camera_front,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleCamera,
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation,
                  _pulseAnimation,
                  _scanLineAnimation,
                  _targetAnimation,
                  _flickerAnimation,
                  _zoomPulseAnimation,
                  _segmentAnimation,
                ]),
                builder: (context, child) {
                  final pulseScale = _pulseAnimation!.value;
                  final baseScale = _scaleAnimation!.value;
                  final zoomPulseScale = _zoomPulseAnimation!.value;
                  final zoomAdjustedSize = 250 / _zoomLevel.clamp(1.0, 3.0);
                  final rotationAngle = (_zoomLevel - 1.0) * 0.1;
                  return Transform(
                    transform: Matrix4.identity()
                      ..scale(baseScale * pulseScale * zoomPulseScale)
                      ..rotateZ(rotationAngle),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: ARGuidePainter(
                            flashOn: _flashOn,
                            scanLinePosition: _scanLineAnimation!.value * (zoomAdjustedSize / 2),
                            zoomLevel: _zoomLevel,
                            targetOpacity: _targetAnimation!.value,
                            flickerOpacity: _isStable ? 0.8 : _flickerAnimation!.value,
                            showCondition: _showConditionMessage,
                            segmentAngle: _showAnalysisMessage ? _segmentAnimation!.value : 0.0,
                          ),
                          child: Container(
                            width: zoomAdjustedSize,
                            height: zoomAdjustedSize,
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          child: Text(
                            "Align skin here",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: screenSize.height * 0.25,
              child: Container(
                width: screenSize.width,
                alignment: Alignment.center,
                child: Text(
                  _zoomLevel < 1.5
                      ? "Distance: Too Far"
                      : _zoomLevel > 3.0
                      ? "Distance: Too Close"
                      : "Distance: Optimal",
                  style: TextStyle(
                    color: _zoomLevel < 1.5 || _zoomLevel > 3.0 ? Colors.yellow : Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_showFocusMessage)
              Center(
                child: Text(
                  "Focus Locked",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_showAnalysisMessage)
              Center(
                child: Text(
                  "Analyzing...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_showConditionMessage)
              Center(
                child: Text(
                  "Condition Detected",
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              top: screenSize.height * 0.2,
              child: Container(
                width: screenSize.width,
                alignment: Alignment.center,
                child: Text(
                  _isStable ? "Ready" : "Hold Steady",
                  style: TextStyle(
                    color: _isStable ? Colors.green : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenSize.height * 0.25,
              child: Container(
                width: screenSize.width,
                alignment: Alignment.center,
                child: Text(
                  "Photograph visible skin only",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showGuide ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "How to Take a Good Picture",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "1. Center the skin area in the circle\n"
                            "2. Hold the camera steady\n"
                            "3. Use bright, even lighting",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: _showGuide ? Colors.yellow : Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() => _showGuide = !_showGuide);
                },
              ),
            ),
            Positioned(
              right: 10,
              top: screenSize.height * 0.3,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: _zoomLevel,
                  min: 1.0,
                  max: 5.0,
                  onChanged: (value) {
                    setState(() {
                      _zoomLevel = value;
                      _controller!.setZoomLevel(_zoomLevel);
                      _zoomPulseController!.forward().then((_) => _zoomPulseController!.reverse());
                    });
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _flashOn = !_flashOn;
                          _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
                        });
                      },
                    ),
                    if (!_hasConfirmedArea)
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _hasConfirmedArea = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Confirm Area"),
                      )
                    else
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _captureColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController?.dispose();
    _pulseController?.dispose();
    _scanLineController?.dispose();
    _targetController?.dispose();
    _flickerController?.dispose();
    _zoomPulseController?.dispose();
    _segmentController?.dispose();
    super.dispose();
  }
}

class ARGuidePainter extends CustomPainter {
  final bool flashOn;
  final double scanLinePosition;
  final double zoomLevel;
  final double targetOpacity;
  final double flickerOpacity;
  final bool showCondition;
  final double segmentAngle;

  ARGuidePainter({
    required this.flashOn,
    required this.scanLinePosition,
    required this.zoomLevel,
    required this.targetOpacity,
    required this.flickerOpacity,
    required this.showCondition,
    required this.segmentAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = showCondition
        ? Colors.green
        : Color.lerp(Colors.yellow, Colors.orange, (zoomLevel - 1.0) / 4.0) ?? Colors.yellow;
    final paint = Paint()
      ..color = flashOn
          ? baseColor.withOpacity(flickerOpacity * 0.8)
          : baseColor.withOpacity(flickerOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (segmentAngle > 0) {
      const segmentCount = 8;
      const segmentGap = 0.2;
      for (int i = 0; i < segmentCount; i++) {
        final startAngle = (i * (2 * 3.14159 / segmentCount)) + segmentAngle;
        final sweepAngle = (2 * 3.14159 / segmentCount) - segmentGap;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    } else {
      canvas.drawCircle(center, radius, paint);
    }

    final cornerPaint = Paint()
      ..color = baseColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final cornerLength = flashOn ? 25.0 : 20.0;
    canvas.drawLine(Offset(center.dx - radius, center.dy - radius),
        Offset(center.dx - radius + cornerLength, center.dy - radius), cornerPaint);
    canvas.drawLine(Offset(center.dx - radius, center.dy - radius),
        Offset(center.dx - radius, center.dy - radius + cornerLength), cornerPaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy - radius),
        Offset(center.dx + radius - cornerLength, center.dy - radius), cornerPaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy - radius),
        Offset(center.dx + radius, center.dy - radius + cornerLength), cornerPaint);
    canvas.drawLine(Offset(center.dx - radius, center.dy + radius),
        Offset(center.dx - radius + cornerLength, center.dy + radius), cornerPaint);
    canvas.drawLine(Offset(center.dx - radius, center.dy + radius),
        Offset(center.dx - radius, center.dy + radius - cornerLength), cornerPaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy + radius),
        Offset(center.dx + radius - cornerLength, center.dy + radius), cornerPaint);
    canvas.drawLine(Offset(center.dx + radius, center.dy + radius),
        Offset(center.dx + radius, center.dy + radius - cornerLength), cornerPaint);

    final scanPaint = Paint()
      ..color = baseColor.withOpacity(0.5)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + scanLinePosition),
      Offset(center.dx + radius, center.dy + scanLinePosition),
      scanPaint,
    );

    if (targetOpacity > 0) {
      final targetPaint = Paint()
        ..color = baseColor.withOpacity(targetOpacity)
        ..strokeWidth = 2.0;
      const markerSize = 10.0;
      canvas.drawLine(
        Offset(center.dx - radius - markerSize, center.dy),
        Offset(center.dx - radius + markerSize, center.dy),
        targetPaint,
      );
      canvas.drawLine(
        Offset(center.dx + radius - markerSize, center.dy),
        Offset(center.dx + radius + markerSize, center.dy),
        targetPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - radius - markerSize),
        Offset(center.dx, center.dy - radius + markerSize),
        targetPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy + radius - markerSize),
        Offset(center.dx, center.dy + radius + markerSize),
        targetPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ARGuidePainter oldDelegate) =>
      oldDelegate.flashOn != flashOn ||
          oldDelegate.scanLinePosition != scanLinePosition ||
          oldDelegate.zoomLevel != zoomLevel ||
          oldDelegate.targetOpacity != targetOpacity ||
          oldDelegate.flickerOpacity != flickerOpacity ||
          oldDelegate.showCondition != showCondition ||
          oldDelegate.segmentAngle != segmentAngle;
}

// Result Modal Widget
class ResultModal extends StatelessWidget {
  final String imagePath;
  final bool isAcceptable;
  final VoidCallback? onProceed;
  final VoidCallback? onRetake;

  const ResultModal({
    super.key,
    required this.imagePath,
    required this.isAcceptable,
    this.onProceed,
    this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAcceptable
                  ? "Image is acceptable!"
                  : "Image is not acceptable. Please retake.",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isAcceptable && onProceed != null)
              ElevatedButton(
                onPressed: onProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Proceed"),
              )
            else if (!isAcceptable && onRetake != null)
              ElevatedButton(
                onPressed: onRetake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retake"),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class LoaderScreen extends StatelessWidget {
  final String imagePath;

  const LoaderScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PredictionBloc(repository: getIt<PredictionRepository>())
        ..add(FetchPrediction(imagePath)),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BlocListener<PredictionBloc, PredictionState>(
            listener: (context, state) {
              if (state is PredictionSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanResult(
                      condition: state.prediction.condition,
                      confidence: state.prediction.confidence,
                      imagePath: state.imagePath,
                    ),
                  ),
                );
              } else if (state is PredictionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
                Navigator.pop(context);
              }
            },
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Processing...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
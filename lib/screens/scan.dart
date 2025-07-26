import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:skinvista/screens/scan_result.dart';
import '../bloc/prediction/prediction_bloc.dart';
import '../bloc/prediction/prediction_event.dart';
import '../bloc/prediction/prediction_state.dart';
import '../core/locator.dart';
import '../core/widgets/result_modal.dart';
import '../repositories/prediction_repository.dart';

class SpotInfo {
  final double size;
  final double intensity;
  final String status;

  SpotInfo({required this.size, required this.intensity, required this.status});
}

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  ui.Image? _capturedImage;
  late List<CameraDescription> _cameras;
  int _currentCameraIndex = 0; // Track current camera (0 for back, 1 for front)
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  AnimationController? _scanController;
  Animation<double>? _scanAnimation;
  AnimationController? _glowController;
  Animation<double>? _glowAnimation;
  AnimationController? _lockController;
  Animation<double>? _lockAnimation;
  AnimationController? _hudController;
  Animation<double>? _hudAnimation;
  AnimationController? _pulseWaveController;
  Animation<double>? _pulseWaveAnimation;
  AnimationController? _postCaptureController;
  Animation<double>? _postCaptureAnimation;
  AnimationController? _energyPulseController;
  Animation<double>? _energyPulseAnimation;
  AnimationController? _particleAnalysisController;
  Animation<double>? _particleAnalysisAnimation;
  AnimationController? _gridFadeController;
  Animation<double>? _gridFadeAnimation;
  AnimationController? _dataStreamController;
  Animation<double>? _dataStreamAnimation;
  bool _flashOn = false;
  Color _captureColor = Colors.red;
  double _zoomLevel = 1.0;
  bool _isStable = false;
  bool _isLoading = false;
  bool _hasConfirmedArea = false;
  bool _hasSeenWarning = false;
  bool _isLocked = false;
  double _scanSpeed = 1.0;
  List<HUDParticle> _particles = [];
  List<DataStreamParticle> _dataStreams = [];
  List<DraggableHUD> _draggableHUDs = [];
  double _brightness = 0.5;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _gyroZ = 0.0;
  bool _showPostCapture = false;
  String? _capturedImagePath;
  int _detectedSpots = 0;
  Offset _magnifierPos = Offset.zero;
  Offset? _targetedSpot;
  double _hudRotation = 0.0;
  List<Offset> _activeSpots = [];
  bool _isScanningMode = false;
  Offset? _particleAttractor;
  Timer? _imageStreamTimer;
  final GlobalKey _gestureKey = GlobalKey();
  bool? _hasVibrationSupport;
  Map<Offset, SpotInfo> _spotDetails = {};
  bool _isHudExpanded = false;
  Offset? _selectedHudPos;
  double _focusAreaSize = 50.0;
  bool _isFocusing = false;
  List<Offset> _analysisParticles = [];
  List<DataStreamParticle> _postCaptureDataStreams = [];
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  bool _isDisposing = false;

  final String _picPurifyApiKey = 'rR2xP51RMlMyJjA8C7MyLj5RVm06eUxc';
  // final String _picPurifyApiKey = 'k4ElcplQRB8Pg17CJMKMZ11vPIDCTpNj';

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _setupAnimations();
    _setupMotionSensors();
    _setupInteractiveElements();
    _checkVibrationSupport();
    _handleShake();
  }

  Future<void> _checkVibrationSupport() async {
    _hasVibrationSupport = await Vibration.hasVibrator();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      _currentCameraIndex = 0; // Start with back camera
      await _initializeCamera();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        if (!_controller!.value.isInitialized) {
          await _controller!.dispose();
          _controller = null;
        }
      }
      if (_cameras.isEmpty || _currentCameraIndex >= _cameras.length) {
        print('No cameras available or invalid camera index');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras available')),
        );
        return;
      }
      setState(() {
        _controller = CameraController(
          _cameras[_currentCameraIndex],
          ResolutionPreset.high,
          enableAudio: false,
        );
      });
      await _controller!.initialize();
      if (!_controller!.value.isInitialized) {
        throw Exception('Camera failed to initialize');
      }
      await _controller!.setZoomLevel(_zoomLevel.clamp(1.0, 5.0));
      await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      if (!_isDisposing && !_controller!.value.isStreamingImages) {
        await _controller!.startImageStream((image) => _updateSpots(image));
      }
      if (mounted) {
        setState(() {}); // Trigger UI rebuild only after initialization
      }
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize camera: $e')),
      );
      if (mounted) {
        setState(() {
          _controller = null; // Ensure controller is null on failure
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No additional cameras available or camera busy')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _controller = null; // Temporarily nullify to prevent UI access
    });
    try {
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      _pauseAnimations();
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _initializeCamera();
      if (_controller == null || !_controller!.value.isInitialized || !_controller!.value.isStreamingImages) {
        throw Exception('Camera failed to initialize or start stream');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resumeAnimations();
        });
      }
    } catch (e) {
      print('Error switching camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error switching camera: $e')),
      );
      // Revert to previous camera if switch fails
      _currentCameraIndex = (_currentCameraIndex - 1) % _cameras.length;
      await _initializeCamera();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resumeAnimations();
        });
      }
    }
  }

  void _setupMotionSensors() {
    DateTime _lastUpdate = DateTime.now();
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (_isDisposing) return;
      if (DateTime.now().difference(_lastUpdate).inMilliseconds > 30) {
        setState(() {
          _tiltX = (event.y * 10).clamp(-20, 20);
          _tiltY = (event.x * 10).clamp(-20, 20);
          _lastUpdate = DateTime.now();
        });
      }
    });
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      if (_isDisposing) return;
      if (DateTime.now().difference(_lastUpdate).inMilliseconds > 30) {
        if (mounted) {
          setState(() {
            _gyroZ = event.z.clamp(-2, 2);
            _hudRotation += _gyroZ * 0.05;
            _lastUpdate = DateTime.now();
          });
        }
      }
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _scanAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _scanController!, curve: Curves.linear),
    );

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
    );

    _lockController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _lockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController!, curve: Curves.easeInOut),
    );

    _hudController = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    _hudAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _hudController!, curve: Curves.linear),
    );

    _pulseWaveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _pulseWaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseWaveController!, curve: Curves.easeOut),
    );

    _postCaptureController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _postCaptureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _postCaptureController!, curve: Curves.easeInOut),
    );

    _energyPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _energyPulseController!.reverse();
        if (status == AnimationStatus.dismissed) _energyPulseController!.forward();
      });
    _energyPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _energyPulseController!, curve: Curves.easeOut),
    );

    _particleAnalysisController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _particleAnalysisAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleAnalysisController!, curve: Curves.easeInOut),
    );

    _gridFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _gridFadeAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _gridFadeController!, curve: Curves.easeInOut),
    );

    _dataStreamController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _dataStreamAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dataStreamController!, curve: Curves.linear),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isStable = true);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSeenWarning) _showWarningDialog();
    });

    _scanController!.addListener(() {
      if (_particles.length < 10 && math.Random().nextDouble() < 0.05 * _zoomLevel) {
        final angle = math.Random().nextDouble() * 2 * 3.14159;
        const radius = 140.0;
        final centerX = 150 + radius * math.cos(angle);
        final centerY = 150 + radius * math.sin(angle);
        _particles.add(HUDParticle(centerX: centerX, centerY: centerY));
      }
      if (_dataStreams.length < 20 && math.Random().nextDouble() < 0.1 && _activeSpots.isNotEmpty) {
        _dataStreams.add(DataStreamParticle(_activeSpots[math.Random().nextInt(_activeSpots.length)]));
      }
      if (mounted) {
        setState(() {
          _particles = _particles.where((p) => p.update(_scanSpeed, _particleAttractor)).toList();
          _dataStreams = _dataStreams.where((p) => p.update()).toList();
        });
      }
    });
  }

  void _setupInteractiveElements() {
    _draggableHUDs.add(DraggableHUD(
      initialPos: Offset(50, 50),
      type: HUDType.scanner,
      onTap: () => _toggleHudExpansion(Offset(50, 50)),
    ));
    _draggableHUDs.add(DraggableHUD(
      initialPos: Offset(200, 200),
      type: HUDType.infoBubble,
      onTap: () => _toggleHudExpansion(Offset(200, 200)),
    ));
  }

  void _toggleHudExpansion(Offset pos) {
    setState(() {
      _isHudExpanded = !_isHudExpanded;
      _selectedHudPos = _isHudExpanded ? pos : null;
    });
    if (_hasVibrationSupport == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  // Future<XFile> _cropImageToARFrame(XFile originalImage, Size screenSize) async {
  //   // Pass additional parameters to ensure accurate cropping
  //   return await compute(_cropImageIsolate, [
  //     originalImage.path,
  //     screenSize,
  //     _controller!.value.previewSize!, // Pass actual preview size
  //     _currentCameraIndex, // Pass camera index to handle front/back camera
  //   ]);
  // }

  Future<XFile> _cropImageToARFrame(XFile originalImage, Size screenSize) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: originalImage.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0), // Force square
      maxWidth: 600,
      maxHeight: 600,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.cyan,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return croppedFile != null ? XFile(croppedFile.path) : originalImage;
  }

  static Future<XFile> _cropImageIsolate(List<dynamic> args) async {
    String path = args[0];
    Size screenSize = args[1];
    Size previewSize = args[2];
    int cameraIndex = args[3];
    try {
      final bytes = await File(path).readAsBytes();
      img.Image? original = img.decodeImage(bytes);
      if (original == null) throw Exception('Failed to decode image');

      final int imageWidth = original.width;
      final int imageHeight = original.height;
      const double arFrameSize = 600.0;
      final double previewWidth = previewSize.width;
      final double previewHeight = previewSize.height;
      final double previewAspectRatio = previewWidth / previewHeight;
      final double screenAspectRatio = screenSize.width / screenSize.height;

      // Calculate the dimensions of the camera preview as displayed on the screen
      double displayWidth, displayHeight;
      if (previewAspectRatio > screenAspectRatio) {
        displayWidth = screenSize.width;
        displayHeight = displayWidth / previewAspectRatio;
      } else {
        displayHeight = screenSize.height;
        displayWidth = displayHeight * previewAspectRatio;
      }

      // The AR frame is a 300x300 square in the UI (as defined in GestureDetector)
      const double uiFrameSize = 300.0; // Size of the AR frame in the UI
      final double arFrameLeft = (screenSize.width - uiFrameSize) / 2;
      final double arFrameTop = (screenSize.height - uiFrameSize) / 2;

      // Calculate scaling factors to map UI coordinates to image coordinates
      final double scaleX = imageWidth / displayWidth;
      final double scaleY = imageHeight / displayHeight;

      // Adjust for front camera mirroring (if using front camera)
      bool isFrontCamera = cameraIndex != 0; // Assuming index 0 is back camera
      final int cropLeft = isFrontCamera
          ? (imageWidth - (arFrameLeft + uiFrameSize) * scaleX).round()
          : (arFrameLeft * scaleX).round();
      final int cropTop = (arFrameTop * scaleY).round();
      final int cropWidth = (uiFrameSize * scaleX).round();
      final int cropHeight = (uiFrameSize * scaleY).round();

      // Clamp coordinates to prevent out-of-bounds errors
      final int adjustedLeft = cropLeft.clamp(0, math.max(0, imageWidth - cropWidth)).toInt();
      final int adjustedTop = cropTop.clamp(0, math.max(0, imageHeight - cropHeight)).toInt();
      final int adjustedWidth = cropWidth.clamp(1, math.max(1, imageWidth - adjustedLeft)).toInt();
      final int adjustedHeight = cropHeight.clamp(1, math.max(1, imageHeight - adjustedTop)).toInt();

      // Debug logging
      print('Original Image: ${imageWidth}x${imageHeight}');
      print('Preview Size: ${previewWidth}x${previewHeight}');
      print('Display Size: ${displayWidth}x${displayHeight}');
      print('Crop: left=$adjustedLeft, top=$adjustedTop, width=$adjustedWidth, height=$adjustedHeight');

      img.Image cropped = img.copyCrop(
        original,
        x: adjustedLeft,
        y: adjustedTop,
        width: adjustedWidth,
        height: adjustedHeight,
      );

      // Resize to desired output size (e.g., 600x600) for consistency
      img.Image resized = img.copyResize(
        cropped,
        width: arFrameSize.toInt(),
        height: arFrameSize.toInt(),
        interpolation: img.Interpolation.cubic, // High-quality resizing
      );

      final croppedBytes = img.encodeJpg(cropped, quality: 90);
      final tempPath = path.replaceAll('.jpg', '_cropped.jpg');
      await File(tempPath).writeAsBytes(croppedBytes);

      // Save original for debugging
      await File(path).copy(path.replaceAll('.jpg', '_original.jpg'));

      return XFile(tempPath);
    } catch (e) {
      print('Error cropping image: $e');
      return XFile(path);
    }
  }

  Future<bool> _isImageSafe(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://www.picpurify.com/analyse/1.1'),
      );
      request.fields['API_KEY'] = _picPurifyApiKey;
      request.fields['task'] = 'porn_moderation,suggestive_nudity_moderation';
      request.files.add(await http.MultipartFile.fromPath('file_image', imagePath));

      var response = await request.send().timeout(const Duration(seconds: 30));
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var result = jsonDecode(responseData.body);
        if (result['status'] == 'success') {
          bool isPorn = result['porn_moderation']?['porn_content'] == 'true' || false;
          bool isNude = (result['nudity_moderation']?['raw_nudity_content'] == 'true' || false) ||
              (result['nudity_moderation']?['partial_nudity_content'] == 'true' || false);
          return !(isPorn || isNude);
        }
      }
      return true;
    } catch (e) {
      print('Error in _isImageSafe: $e');
      return true;
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
      _controller?.stopImageStream();
      _pauseAnimations();
    });

    try {
      if (_hasVibrationSupport == true) {
        Vibration.vibrate(duration: 50);
      }
      // Set focus and exposure before capturing
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
      XFile image = await _controller!.takePicture();
      final screenSize = MediaQuery.of(context).size;
      XFile croppedImage = await _cropImageToARFrame(image, screenSize);

      final imageFile = File(croppedImage.path);
      final uiImage = img.decodeImage(imageFile.readAsBytesSync());
      if (uiImage != null) {
        final uiImageProvider = MemoryImage(img.encodePng(uiImage));
        final completer = Completer<ui.Image>();
        uiImageProvider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, _) => completer.complete(info.image)),
        );
        _capturedImage = await completer.future;
      }

      setState(() {
        _capturedImagePath = croppedImage.path;
        _showPostCapture = true;
        _analysisParticles.clear();
        _postCaptureDataStreams.clear();
        for (var spot in _activeSpots) {
          for (int i = 0; i < 8; i++) {
            _analysisParticles.add(Offset(
              spot.dx + math.Random().nextDouble() * 30 - 15,
              spot.dy + math.Random().nextDouble() * 30 - 15,
            ));
          }
          _postCaptureDataStreams.add(DataStreamParticle(spot));
        }
      });

      _energyPulseController!.forward();
      _particleAnalysisController!.forward();
      _gridFadeController!.forward();
      _dataStreamController!.forward();
      await _postCaptureController!.forward(from: 0.0);

      setState(() => _showPostCapture = false);

      bool isSafe = await _isImageSafe(croppedImage.path);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ResultModal(
          imagePath: croppedImage.path,
          isAcceptable: isSafe,
          onProceed: isSafe
              ? () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoaderScreen(imagePath: croppedImage.path),
              ),
            );
          }
              : null,
          onRetake: isSafe
              ? null
              : () {
            Navigator.pop(context);
            setState(() => _hasConfirmedArea = false);
          },
        ),
      );

      if (isSafe) {
        await Gal.putImage(croppedImage.path);
        await File(image.path).delete();
      } else {
        await File(croppedImage.path).delete();
        await File(image.path).delete();
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
          _resumeAnimations();
          _controller?.startImageStream((image) => _updateSpots(image));
          _energyPulseController!.stop();
          _particleAnalysisController!.stop();
          _gridFadeController!.stop();
          _dataStreamController!.stop();
        });
      }
    }
  }

  void _pauseAnimations() {
    _pulseController?.stop();
    _scanController?.stop();
    _glowController?.stop();
    _lockController?.stop();
    _hudController?.stop();
    _pulseWaveController?.stop();
    _postCaptureController?.stop();
    _energyPulseController?.stop();
    _particleAnalysisController?.stop();
    _gridFadeController?.stop();
    _dataStreamController?.stop();
  }

  void _resumeAnimations() {
    if (!_isLoading) {
      _pulseController?.repeat(reverse: true);
      _scanController?.repeat();
      _glowController?.repeat(reverse: true);
      _hudController?.repeat();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final RenderBox? box = _gestureKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = box != null ? box.globalToLocal(details.globalPosition) : details.localPosition;
    if (_hasVibrationSupport == true) {
      Vibration.vibrate(duration: 30);
    }
    setState(() {
      if (_activeSpots.isNotEmpty && _activeSpots.any((spot) => (spot - localPos).distance < 20)) {
        final spot = _activeSpots.firstWhere((spot) => (spot - localPos).distance < 20);
        _handleSpotTap(spot);
      } else if (!_isLocked) {
        _targetedSpot = localPos;
        _lockController!.forward().then((_) {
          _pulseWaveController!.forward(from: 0.0);
          _isLocked = true;
        });
      } else {
        _targetedSpot = null;
        _lockController!.reverse().then((_) => _isLocked = false);
      }
    });
  }

  void _handleDoubleTap() {
    setState(() {
      _isScanningMode = !_isScanningMode;
      _scanSpeed = _isScanningMode ? 2.0 : 1.0;
      _scanController!.duration = Duration(seconds: (3 / _scanSpeed).round());
      _scanController!.reset();
      _scanController!.repeat();
    });
    if (_hasVibrationSupport == true) {
      Vibration.vibrate(pattern: [50, 50, 50, 50]);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final RenderBox? box = _gestureKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = box != null ? box.globalToLocal(details.focalPoint) : details.focalPoint;
    setState(() {
      if (details.scale != 1.0) {
        _zoomLevel = (_zoomLevel * details.scale).clamp(1.0, 5.0);
        _controller!.setZoomLevel(_zoomLevel);
        _isFocusing = true;
        _focusAreaSize = (_focusAreaSize * details.scale).clamp(30.0, 100.0);
        _magnifierPos = localPos;
      }

      final delta = details.focalPointDelta;
      for (var hud in _draggableHUDs) {
        if ((hud.pos - localPos).distance < 30) {
          hud.pos = localPos;
          if (_hasVibrationSupport == true) {
            Vibration.vibrate(duration: 20);
          }
          break;
        }
      }

      if (delta.dx.abs() > 2.0) {
        _scanSpeed = (_scanSpeed + delta.dx * 0.005).clamp(0.5, 2.5);
        _scanController!.duration = Duration(seconds: (3 / _scanSpeed).round());
        _scanController!.repeat();
      }

      _magnifierPos = localPos;

      if (delta.distance > 10 && !_draggableHUDs.any((hud) => (hud.pos - localPos).distance < 30)) {
        _particleAttractor = localPos;
      } else if (delta.distance < 5) {
        _particleAttractor = null;
        _isFocusing = false;
      }
    });
  }

  void _handleLongPress(LongPressStartDetails details) {
    final RenderBox? box = _gestureKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = box != null ? box.globalToLocal(details.globalPosition) : details.localPosition;
    setState(() {
      _particleAttractor = localPos;
      if (_hasVibrationSupport == true) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() => _particleAttractor = null);
  }

  void _handleSpotTap(Offset spot) {
    setState(() {
      _spotDetails[spot] = SpotInfo(
        size: 10 + math.Random().nextDouble() * 20,
        intensity: _brightness * 100,
        status: 'Analyzing',
      );
      _dataStreams.add(DataStreamParticle(spot)
        ..text = "Size: ${_spotDetails[spot]!.size.toStringAsFixed(1)}");
      _pulseWaveController!.forward(from: 0.0);
    });
    if (_hasVibrationSupport == true) {
      Vibration.vibrate(pattern: [0, 50, 30, 50]);
    }
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx.abs() > 5) {
      setState(() {
        _isScanningMode = details.delta.dx > 0;
        _scanSpeed = _isScanningMode ? 2.0 : 1.0;
        _scanController!.duration = Duration(seconds: (3 / _scanSpeed).round());
        _scanController!.repeat();
      });
      if (_hasVibrationSupport == true) {
        Vibration.vibrate(duration: 50);
      }
    }
  }

  void _handleShake() {
    _shakeSubscription = accelerometerEventStream(samplingPeriod: Duration(milliseconds: 100))
        .listen((event) {
      if (event.x.abs() > 15 || event.y.abs() > 15) {
        setState(() {
          _activeSpots.clear();
          _spotDetails.clear();
          _isLocked = false;
          _targetedSpot = null;
        });
        if (_hasVibrationSupport == true) {
          Vibration.vibrate(pattern: [0, 100, 50, 100]);
        }
      }
    });
  }

  void _updateSpots(CameraImage image) {
    _imageStreamTimer?.cancel();
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final totalPixels = image.width * image.height;

    double sum = 0.0;
    int sampleCount = 0;
    const sampleStep = 100;

    for (int i = 0; i < bytes.length; i += sampleStep) {
      sum += bytes[i].toDouble();
      sampleCount++;
    }

    final newBrightness = sampleCount > 0 ? (sum / (sampleCount * 255.0)).clamp(0.0, 1.0) : _brightness;

    if (mounted) {
      setState(() {
        _brightness = newBrightness;
        _activeSpots.clear();
        if (_brightness < 0.3 || _brightness > 0.7) {
          _activeSpots.add(Offset(
            150 + math.cos(_scanAnimation!.value) * 50,
            150 + math.sin(_scanAnimation!.value) * 50,
          ));
          if (_zoomLevel > 2.0) {
            _activeSpots.add(Offset(
              150 - math.cos(_scanAnimation!.value) * 30,
              150 - math.sin(_scanAnimation!.value) * 30,
            ));
          }
        }
        _detectedSpots = _activeSpots.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    var tmp = MediaQuery.of(context).size;

    final screenH = math.max(tmp.height, tmp.width);
    final screenW = math.min(tmp.height, tmp.width);

    tmp = _controller!.value.previewSize!;

    final previewH = math.max(tmp.height, tmp.width);
    final previewW = math.min(tmp.height, tmp.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;
    return Scaffold(
      body: Stack(
        children: [
          ClipRRect(
            child: OverflowBox(
              maxHeight: screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
              maxWidth: screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
              child: CameraPreview(
                _controller!,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            ),
          ),
          Center(
            child: GestureDetector(
              key: _gestureKey,
              onTapUp: _handleTapUp,
              onDoubleTap: _handleDoubleTap,
              onScaleUpdate: _handleScaleUpdate,
              onHorizontalDragUpdate: _handleSwipe,
              onLongPressStart: _handleLongPress,
              onLongPressEnd: _handleLongPressEnd,
              child: SizedBox(
                width: 300,
                height: 300,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseAnimation,
                    _scanAnimation,
                    _glowAnimation,
                    _lockAnimation,
                    _hudAnimation,
                    _pulseWaveAnimation,
                    _postCaptureAnimation,
                    _energyPulseAnimation,
                    _particleAnalysisAnimation,
                    _gridFadeAnimation,
                    _dataStreamAnimation,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: EnhancedIronManAROverlay(
                        pulseScale: _pulseAnimation!.value,
                        scanAngle: _scanAnimation!.value,
                        glowOpacity: _glowAnimation!.value,
                        isStable: _isStable,
                        zoomLevel: _zoomLevel,
                        isLocked: _isLocked,
                        lockProgress: _lockAnimation!.value,
                        hudAngle: _hudAnimation!.value + _hudRotation,
                        pulseWaveProgress: _pulseWaveAnimation!.value,
                        particles: _particles,
                        dataStreams: _dataStreams,
                        brightness: _brightness,
                        tiltX: _tiltX,
                        tiltY: _tiltY,
                        gyroZ: _gyroZ,
                        scanSpeed: _scanSpeed,
                        postCaptureProgress: _postCaptureAnimation?.value ?? 0.0,
                        capturedImagePath: _capturedImagePath,
                        showPostCapture: _showPostCapture,
                        capturedImage: _capturedImage,
                        detectedSpots: _detectedSpots,
                        magnifierPos: _magnifierPos,
                        targetedSpot: _targetedSpot,
                        activeSpots: _activeSpots,
                        isScanningMode: _isScanningMode,
                        draggableHUDs: _draggableHUDs,
                        particleAttractor: _particleAttractor,
                        spotDetails: _spotDetails,
                        isHudExpanded: _isHudExpanded,
                        selectedHudPos: _selectedHudPos,
                        isFocusing: _isFocusing,
                        focusAreaSize: _focusAreaSize,
                        energyPulseProgress: _energyPulseAnimation?.value ?? 0.0,
                        particleAnalysisProgress: _particleAnalysisAnimation?.value ?? 0.0,
                        gridFadeOpacity: _gridFadeAnimation?.value ?? 0.0,
                        analysisParticles: _analysisParticles,
                        dataStreamProgress: _dataStreamAnimation?.value ?? 0.0,
                        postCaptureDataStreams: _postCaptureDataStreams,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_isFocusing)
            Positioned(
              left: _magnifierPos.dx - _focusAreaSize / 2,
              top: _magnifierPos.dy - _focusAreaSize / 2,
              child: Container(
                width: _focusAreaSize,
                height: _focusAreaSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _isLocked
                      ? "Confirm area to start scanning"
                      : (_isScanningMode
                      ? "Scanning Active"
                      : (_isStable ? "Ready to Scan" : "Stabilizing...")),
                  style: TextStyle(
                    color: _isLocked
                        ? Colors.blue
                        : (_isScanningMode ? Colors.cyan : (_isStable ? Colors.green : Colors.yellow)),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _zoomLevel,
                  min: 1.0,
                  max: 5.0,
                  onChanged: (value) {
                    setState(() {
                      _zoomLevel = value;
                      _controller!.setZoomLevel(_zoomLevel);
                    });
                  },
                  activeColor: Colors.cyan,
                  inactiveColor: Colors.grey,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              color: Colors.black.withOpacity(0.5),
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
                  GestureDetector(
                    onTap: _hasConfirmedArea ? _takePicture : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyan, width: 4),
                        gradient: RadialGradient(
                          colors: [_captureColor, _captureColor.withOpacity(0.3)],
                          center: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _switchCamera,
                  ),
                  ElevatedButton(
                    onPressed: !_hasConfirmedArea ? () => setState(() => _hasConfirmedArea = true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading && !_showPostCapture)
            const Center(child: CircularProgressIndicator(color: Colors.cyan)),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status Dashboard",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Zoom: ${_zoomLevel.toStringAsFixed(1)}x",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Light: ${(_brightness * 100).toInt()}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Spots: $_detectedSpots",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Scan Speed: ${_scanSpeed.toStringAsFixed(1)}x",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Camera: ${_cameras[_currentCameraIndex].lensDirection == CameraLensDirection.back ? 'Back' : 'Front'}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing _ScanState');
    _isDisposing = true;
    _imageStreamTimer?.cancel();
    _shakeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _controller?.stopImageStream();
    _pauseAnimations();
    _controller?.dispose();
    _pulseController?.dispose();
    _scanController?.dispose();
    _glowController?.dispose();
    _lockController?.dispose();
    _hudController?.dispose();
    _pulseWaveController?.dispose();
    _postCaptureController?.dispose();
    _energyPulseController?.dispose();
    _particleAnalysisController?.dispose();
    _gridFadeController?.dispose();
    _dataStreamController?.dispose();
    print('Finished disposing _ScanState');
    super.dispose();
  }
}

enum HUDType { scanner, infoBubble }

class DraggableHUD {
  Offset pos;
  final HUDType type;
  final VoidCallback? onTap;

  DraggableHUD({required Offset initialPos, required this.type, this.onTap}) : pos = initialPos;
}

class HUDParticle {
  double x, y;
  double angle;
  double speed;
  double life;
  final double centerX, centerY;

  HUDParticle({required this.centerX, required this.centerY})
      : x = centerX,
        y = centerY,
        angle = math.Random().nextDouble() * 2 * 3.14159,
        speed = 0.5 + math.Random().nextDouble(),
        life = 1.0;

  bool update(double scanSpeed, Offset? attractor) {
    if (attractor != null) {
      final dx = attractor.dx - x;
      final dy = attractor.dy - y;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (distance > 5) {
        angle = math.atan2(dy, dx);
        speed += 0.1;
      }
    }
    x += math.cos(angle) * speed * scanSpeed;
    y += math.sin(angle) * speed * scanSpeed;
    life -= 0.05;
    return life > 0;
  }
}

class DataStreamParticle {
  Offset pos;
  String text;
  double life;

  DataStreamParticle(this.pos)
      : text = math.Random().nextBool() ? "0" : "1",
        life = 1.0;

  bool update() {
    pos = Offset(pos.dx, pos.dy + 2);
    life -= 0.05;
    return life > 0;
  }
}

class EnhancedIronManAROverlay extends CustomPainter {
  final double pulseScale;
  final double scanAngle;
  final double glowOpacity;
  final bool isStable;
  final double zoomLevel;
  final bool isLocked;
  final double lockProgress;
  final double hudAngle;
  final double pulseWaveProgress;
  final List<HUDParticle> particles;
  final List<DataStreamParticle> dataStreams;
  final double brightness;
  final double tiltX;
  final double tiltY;
  final double gyroZ;
  final double scanSpeed;
  final double postCaptureProgress;
  final String? capturedImagePath;
  final bool showPostCapture;
  final ui.Image? capturedImage;
  final int detectedSpots;
  final Offset magnifierPos;
  final Offset? targetedSpot;
  final List<Offset> activeSpots;
  final bool isScanningMode;
  final List<DraggableHUD> draggableHUDs;
  final Offset? particleAttractor;
  final Map<Offset, SpotInfo> spotDetails;
  final bool isHudExpanded;
  final Offset? selectedHudPos;
  final bool isFocusing;
  final double focusAreaSize;
  final double energyPulseProgress;
  final double particleAnalysisProgress;
  final double gridFadeOpacity;
  final List<Offset> analysisParticles;
  final double dataStreamProgress;
  final List<DataStreamParticle> postCaptureDataStreams;

  EnhancedIronManAROverlay({
    required this.pulseScale,
    required this.scanAngle,
    required this.glowOpacity,
    required this.isStable,
    required this.zoomLevel,
    required this.isLocked,
    required this.lockProgress,
    required this.hudAngle,
    required this.pulseWaveProgress,
    required this.particles,
    required this.dataStreams,
    required this.brightness,
    required this.tiltX,
    required this.tiltY,
    required this.gyroZ,
    required this.scanSpeed,
    required this.postCaptureProgress,
    required this.capturedImagePath,
    required this.showPostCapture,
    required this.capturedImage,
    required this.detectedSpots,
    required this.magnifierPos,
    required this.targetedSpot,
    required this.activeSpots,
    required this.isScanningMode,
    required this.draggableHUDs,
    required this.particleAttractor,
    required this.spotDetails,
    required this.isHudExpanded,
    required this.selectedHudPos,
    required this.isFocusing,
    required this.focusAreaSize,
    required this.energyPulseProgress,
    required this.particleAnalysisProgress,
    required this.gridFadeOpacity,
    required this.analysisParticles,
    required this.dataStreamProgress,
    required this.postCaptureDataStreams,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + tiltX, size.height / 2 + tiltY);
    final baseRadius = size.width * 0.45 * pulseScale;

    if (showPostCapture && capturedImage != null) {
      canvas.drawImageRect(
        capturedImage!,
        Rect.fromLTWH(0, 0, capturedImage!.width.toDouble(), capturedImage!.height.toDouble()),
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        Paint(),
      );

      for (int i = 0; i < 4; i++) {
        final pulseRadius = baseRadius * (energyPulseProgress + i * 0.25);
        final pulsePaint = Paint()
          ..color = Color.lerp(Colors.cyan, Colors.purple, energyPulseProgress)!.withOpacity(0.6 * (1 - energyPulseProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + math.sin(energyPulseProgress * math.pi) * 2;
        canvas.drawCircle(center, pulseRadius, pulsePaint);
        final distortionPaint = Paint()
          ..color = Colors.yellow.withOpacity(0.3 * (1 - energyPulseProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: pulseRadius + math.cos(energyPulseProgress * 6) * 5)),
          distortionPaint,
        );
      }

      final particlePaint = Paint()..style = PaintingStyle.fill;
      for (var particle in analysisParticles) {
        final t = particleAnalysisProgress.clamp(0.0, 1.0);
        final angle = math.atan2(particle.dy - center.dy, particle.dx - center.dx);
        final burst = math.Random().nextDouble() < 0.1 ? 10 : 0;
        final newPos = Offset.lerp(particle, center, t)! + Offset(math.cos(angle) * burst, math.sin(angle) * burst);
        particlePaint.color = Colors.yellow.withOpacity(1 - t);
        canvas.drawCircle(newPos, 4.0 * (1 - t), particlePaint);
        for (int i = 1; i < 3; i++) {
          final trailPos = Offset.lerp(particle, newPos, i / 3)!;
          particlePaint.color = Colors.yellow.withOpacity((1 - t) * (1 - i / 3));
          canvas.drawCircle(trailPos, 2.0 * (1 - t), particlePaint);
        }
      }

      final gridPaint = Paint()
        ..color = Colors.cyan.withOpacity(gridFadeOpacity)
        ..strokeWidth = 1;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(postCaptureProgress * math.pi);
      canvas.translate(-center.dx, -center.dy);
      for (int i = -6; i <= 6; i++) {
        canvas.drawLine(
          Offset(i * 25 + 150, 0),
          Offset(i * 25 + 150, size.height),
          gridPaint,
        );
        canvas.drawLine(
          Offset(0, i * 25 + 150),
          Offset(size.width, i * 25 + 150),
          gridPaint,
        );
        final glowPaint = Paint()
          ..color = Colors.cyan.withOpacity(gridFadeOpacity * 0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(i * 25 + 150, i * 25 + 150), 3, glowPaint);
      }
      canvas.restore();

      for (int i = 1; i <= 3; i++) {
        final ringPaint = Paint()
          ..color = Colors.green.withOpacity(0.7 - i * 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + math.sin(postCaptureProgress * math.pi * 2) * 1;
        final radius = baseRadius * (0.7 + i * 0.2) * postCaptureProgress;
        canvas.drawCircle(center, radius, ringPaint);
        for (int j = 0; j < 8; j++) {
          final angle = j * math.pi / 4 + postCaptureProgress * math.pi;
          final segmentPaint = Paint()
            ..color = Colors.green.withOpacity(0.9 - i * 0.2)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)),
            3 + math.sin(postCaptureProgress * math.pi * 4) * 2,
            segmentPaint,
          );
        }
      }

      for (var spot in activeSpots) {
        final spotPaint = Paint()
          ..color = Colors.red.withOpacity(0.7 * (1 - postCaptureProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(spot, 10 + postCaptureProgress * 15, spotPaint);
        for (int i = 0; i < 3; i++) {
          final orbitAngle = postCaptureProgress * math.pi * 2 + i * 2 * math.pi / 3;
          final orbitPaint = Paint()
            ..color = Colors.red.withOpacity(0.8)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(spot.dx + 20 * math.cos(orbitAngle), spot.dy + 20 * math.sin(orbitAngle)),
            2 + postCaptureProgress * 2,
            orbitPaint,
          );
        }
        final heatmapPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.red.withOpacity(0.3 * (1 - postCaptureProgress)),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: spot, radius: 25));
        canvas.drawCircle(spot, 25, heatmapPaint);
      }

      final dataPaint = TextPainter(textDirection: TextDirection.ltr);
      for (var stream in postCaptureDataStreams) {
        final t = dataStreamProgress.clamp(0.0, 1.0);
        final newPos = Offset.lerp(stream.pos, center, t)!;
        dataPaint.text = TextSpan(
          text: "${stream.text}${math.Random().nextInt(10)}",
          style: TextStyle(color: Colors.cyan.withOpacity(1 - t), fontSize: 12),
        );
        dataPaint.layout();
        dataPaint.paint(canvas, newPos);
      }

      final progressText = TextPainter(
        text: TextSpan(
          text: "Analysis: ${(postCaptureProgress * 100).toInt()}%",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      progressText.paint(canvas, center - Offset(progressText.width / 2, progressText.height / 2));
      return;
    }

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isScanningMode ? Colors.cyan : Colors.blue).withOpacity(0.3 * brightness),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius + 50));
    canvas.drawCircle(center, baseRadius + 50, bgPaint);

    final gridPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.2 * brightness)
      ..strokeWidth = 1;
    for (int i = -5; i <= 5; i++) {
      for (int j = -5; j <= 5; j++) {
        final x = 150 + i * 30 + tiltX * 0.5;
        final y = 150 + j * 30 + tiltY * 0.5;
        canvas.drawCircle(Offset(x, y), 2 + pulseScale * 2, gridPaint);
      }
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final shadowOffset = Offset(tiltX * 0.2, tiltY * 0.2);
    for (var spot in activeSpots) {
      canvas.drawCircle(spot + shadowOffset, 12, shadowPaint);
    }

    if (targetedSpot != null) {
      final reticlePaint = Paint()
        ..color = Colors.blue.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(targetedSpot!, 20 * pulseScale, reticlePaint);
      canvas.drawLine(targetedSpot! - Offset(30, 0), targetedSpot! + Offset(30, 0), reticlePaint);
      canvas.drawLine(targetedSpot! - Offset(0, 30), targetedSpot! + Offset(0, 30), reticlePaint);
      final labelPainter = TextPainter(
        text: TextSpan(text: "Target Acquired", style: TextStyle(color: Colors.white, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, targetedSpot! + Offset(-labelPainter.width / 2, -40));

      if (pulseWaveProgress > 0) {
        for (int i = 0; i < 3; i++) {
          final radius = baseRadius * (pulseWaveProgress + i * 0.3);
          final echoPaint = Paint()
            ..color = Colors.blue.withOpacity((1 - pulseWaveProgress) * (0.5 - i * 0.1))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(targetedSpot!, radius, echoPaint);
        }
      }
    }

    for (var spot in activeSpots) {
      final spotPaint = Paint()
        ..color = Colors.red.withOpacity(0.7 + glowOpacity * 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(spot, 10 * zoomLevel.clamp(1.0, 2.0), spotPaint);
      if (isScanningMode) {
        final scanWave = Paint()
          ..color = Colors.cyan.withOpacity(0.5 - pulseWaveProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(spot, 15 + pulseWaveProgress * 20, scanWave);
      }
      if (spotDetails.containsKey(spot)) {
        final info = spotDetails[spot]!;
        final infoPaint = TextPainter(
          text: TextSpan(
            text: '${info.status}\n${info.size.toStringAsFixed(1)}mm',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        infoPaint.paint(canvas, spot + Offset(15, -15));
      }
    }

    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.cyan.withOpacity(0.6 - i * 0.15);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(hudAngle * (i % 2 == 0 ? 1 : -1) * 0.5);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawCircle(center, baseRadius + i * 15, ringPaint);
      canvas.restore();
    }

    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var particle in particles) {
      particlePaint.color = Colors.cyan.withOpacity(particle.life * brightness);
      final offsetParticle = Offset(particle.x + tiltX * 0.5, particle.y + tiltY * 0.5);
      canvas.drawCircle(offsetParticle, 3.0, particlePaint);
    }

    final dataPaint = TextPainter(textDirection: TextDirection.ltr);
    for (var particle in dataStreams) {
      dataPaint.text = TextSpan(
        text: particle.text,
        style: TextStyle(color: Colors.cyan.withOpacity(particle.life), fontSize: 12),
      );
      dataPaint.layout();
      dataPaint.paint(canvas, particle.pos);
    }

    if (isScanningMode) {
      final sweepPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.7)
        ..strokeWidth = 3.0;
      final sweepEnd = Offset(
        center.dx + baseRadius * math.cos(scanAngle),
        center.dy + baseRadius * math.sin(scanAngle),
      );
      canvas.drawLine(center, sweepEnd, sweepPaint);
      canvas.drawCircle(sweepEnd, 5.0, sweepPaint..style = PaintingStyle.fill);
    }

    final compassCenter = Offset(size.width / 2, 50);
    final compassPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(compassCenter, 30, compassPaint);
    canvas.save();
    canvas.translate(compassCenter.dx, compassCenter.dy);
    canvas.rotate(hudAngle);
    canvas.drawLine(Offset.zero, Offset(0, -25), compassPaint..color = Colors.yellow);
    canvas.restore();
    for (var spot in activeSpots) {
      final angle = math.atan2(spot.dy - 150, spot.dx - 150);
      canvas.drawCircle(compassCenter + Offset(30 * math.cos(angle), 30 * math.sin(angle)), 3, compassPaint);
    }

    final bracketPaint = Paint()
      ..color = isLocked ? Colors.blue : (isStable ? Colors.green : Colors.yellow)
      ..strokeWidth = 3.0;
    final bracketLength = 25.0 + (lockProgress * 10.0);

    void drawBracket(Offset start, Offset hEnd, Offset vEnd) {
      Offset clampedStart = Offset(
        start.dx.clamp(0.0, size.width),
        start.dy.clamp(0.0, size.height),
      );
      Offset clampedHEnd = Offset(
        hEnd.dx.clamp(0.0, size.width),
        hEnd.dy.clamp(0.0, size.height),
      );
      Offset clampedVEnd = Offset(
        vEnd.dx.clamp(0.0, size.width),
        vEnd.dy.clamp(0.0, size.height),
      );
      canvas.drawLine(clampedStart, clampedHEnd, bracketPaint);
      canvas.drawLine(clampedStart, clampedVEnd, bracketPaint);
    }

    drawBracket(
      center - Offset(baseRadius, -baseRadius),
      center - Offset(baseRadius - bracketLength, -baseRadius),
      center - Offset(baseRadius, -baseRadius + bracketLength),
    );
    drawBracket(
      center + Offset(baseRadius, -baseRadius),
      center + Offset(baseRadius - bracketLength, -baseRadius),
      center + Offset(baseRadius, -baseRadius + bracketLength),
    );
    drawBracket(
      center - Offset(baseRadius, baseRadius),
      center - Offset(baseRadius - bracketLength, baseRadius),
      center - Offset(baseRadius, baseRadius - bracketLength),
    );
    drawBracket(
      center + Offset(baseRadius, baseRadius),
      center + Offset(baseRadius - bracketLength, baseRadius),
      center + Offset(baseRadius, baseRadius - bracketLength),
    );

    for (var hud in draggableHUDs) {
      final hudPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (hud.type == HUDType.scanner) {
        canvas.drawCircle(hud.pos, isHudExpanded && selectedHudPos == hud.pos ? 40 : 20, hudPaint);
        if (isHudExpanded && selectedHudPos == hud.pos) {
          final scanData = TextPainter(
            text: TextSpan(
              text: 'Scan Speed: ${scanSpeed.toStringAsFixed(1)}x\nSpots: $detectedSpots',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          scanData.paint(canvas, hud.pos + Offset(-scanData.width / 2, 25));
        }
      } else if (hud.type == HUDType.infoBubble) {
        final rect = Rect.fromCenter(
          center: hud.pos,
          width: isHudExpanded && selectedHudPos == hud.pos ? 100 : 50,
          height: isHudExpanded && selectedHudPos == hud.pos ? 60 : 30,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(5)),
          hudPaint,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: isHudExpanded && selectedHudPos == hud.pos
                ? "Spots: $detectedSpots\nBrightness: ${(brightness * 100).toInt()}%\nZoom: ${zoomLevel.toStringAsFixed(1)}x"
                : "Spots: $detectedSpots",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, hud.pos - Offset(textPainter.width / 2, textPainter.height / 2));
      }
    }

    if (particleAttractor != null) {
      final attractorPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(particleAttractor!, 30 * pulseWaveProgress, attractorPaint);
    }
  }

  @override
  bool shouldRepaint(EnhancedIronManAROverlay oldDelegate) =>
      oldDelegate.pulseScale != pulseScale ||
          oldDelegate.scanAngle != scanAngle ||
          oldDelegate.glowOpacity != glowOpacity ||
          oldDelegate.isStable != isStable ||
          oldDelegate.zoomLevel != zoomLevel ||
          oldDelegate.isLocked != isLocked ||
          oldDelegate.lockProgress != lockProgress ||
          oldDelegate.hudAngle != hudAngle ||
          oldDelegate.pulseWaveProgress != pulseWaveProgress ||
          oldDelegate.particles != particles ||
          oldDelegate.dataStreams != dataStreams ||
          oldDelegate.brightness != brightness ||
          oldDelegate.tiltX != tiltX ||
          oldDelegate.tiltY != tiltY ||
          oldDelegate.gyroZ != gyroZ ||
          oldDelegate.scanSpeed != scanSpeed ||
          oldDelegate.postCaptureProgress != postCaptureProgress ||
          oldDelegate.capturedImagePath != capturedImagePath ||
          oldDelegate.showPostCapture != showPostCapture ||
          oldDelegate.capturedImage != capturedImage ||
          oldDelegate.detectedSpots != detectedSpots ||
          oldDelegate.magnifierPos != magnifierPos ||
          oldDelegate.targetedSpot != targetedSpot ||
          oldDelegate.activeSpots != activeSpots ||
          oldDelegate.isScanningMode != isScanningMode ||
          oldDelegate.draggableHUDs != draggableHUDs ||
          oldDelegate.particleAttractor != particleAttractor ||
          oldDelegate.spotDetails != spotDetails ||
          oldDelegate.isHudExpanded != isHudExpanded ||
          oldDelegate.selectedHudPos != selectedHudPos ||
          oldDelegate.isFocusing != isFocusing ||
          oldDelegate.focusAreaSize != focusAreaSize ||
          oldDelegate.energyPulseProgress != energyPulseProgress ||
          oldDelegate.particleAnalysisProgress != particleAnalysisProgress ||
          oldDelegate.gridFadeOpacity != gridFadeOpacity ||
          oldDelegate.analysisParticles != analysisParticles ||
          oldDelegate.dataStreamProgress != dataStreamProgress ||
          oldDelegate.postCaptureDataStreams != postCaptureDataStreams;
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
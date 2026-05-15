import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

enum EyeState { open, closed, unknown }

class EyeDetectionResult {
  final EyeState leftEye;
  final EyeState rightEye;
  final EyeState overallState;
  final double? leftOpenProbability;
  final double? rightOpenProbability;
  final bool faceDetected;

  const EyeDetectionResult({
    required this.leftEye,
    required this.rightEye,
    required this.overallState,
    this.leftOpenProbability,
    this.rightOpenProbability,
    required this.faceDetected,
  });

  static const EyeDetectionResult noFace = EyeDetectionResult(
    leftEye: EyeState.unknown,
    rightEye: EyeState.unknown,
    overallState: EyeState.unknown,
    faceDetected: false,
  );
}

class FaceDetectionService {
  static const double _eyeOpenThreshold = 0.5;

  late final FaceDetector _detector;
  bool _isProcessing = false;

  FaceDetectionService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Required for eye open probability
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.15,
      ),
    );
  }

  Future<EyeDetectionResult> processImage(CameraImage image, CameraDescription camera) async {
    // Prevent concurrent processing — drop frames if busy
    if (_isProcessing) return EyeDetectionResult.noFace;
    _isProcessing = true;

    try {
      final inputImage = _buildInputImage(image, camera);
      if (inputImage == null) return EyeDetectionResult.noFace;

      final faces = await _detector.processImage(inputImage);
      if (faces.isEmpty) return EyeDetectionResult.noFace;

      // Use the largest face (closest to camera)
      final face = faces.reduce(
        (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b,
      );

      final leftProb = face.leftEyeOpenProbability;
      final rightProb = face.rightEyeOpenProbability;

      final leftState = _classify(leftProb);
      final rightState = _classify(rightProb);

      // Both eyes must be open for green; either closed = red
      final overall = (leftState == EyeState.open && rightState == EyeState.open)
          ? EyeState.open
          : (leftState == EyeState.closed || rightState == EyeState.closed)
              ? EyeState.closed
              : EyeState.unknown;

      return EyeDetectionResult(
        leftEye: leftState,
        rightEye: rightState,
        overallState: overall,
        leftOpenProbability: leftProb,
        rightOpenProbability: rightProb,
        faceDetected: true,
      );
    } catch (e) {
      debugPrint('[EyeSentinel] Detection error: $e');
      return EyeDetectionResult.noFace;
    } finally {
      _isProcessing = false;
    }
  }

  EyeState _classify(double? probability) {
    if (probability == null) return EyeState.unknown;
    return probability >= _eyeOpenThreshold ? EyeState.open : EyeState.closed;
  }

  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      final rotation = _getRotation(camera.sensorOrientation);

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  InputImageRotation _getRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}

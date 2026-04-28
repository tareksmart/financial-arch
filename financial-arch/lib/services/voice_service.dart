import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Service for handling speech-to-text voice input
class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  String _recognizedText = '';
  bool _isListening = false;
  bool _isAvailable = false;
  String? _error;
  double _confidenceLevel = 0.0;

  // Getters
  String get recognizedText => _recognizedText;
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String? get error => _error;
  double get confidenceLevel => _confidenceLevel;

  /// Initialize voice service
  Future<bool> initialize() async {
    try {
      _error = null;
      _isAvailable = await _speechToText.initialize(
        onError: (error) => _handleError(error.errorMsg),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isDenied) {
        _handleError('Microphone permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        _handleError(
            'Microphone permission permanently denied. Please enable in settings.');
        openAppSettings();
        return false;
      }
      return status.isGranted;
    } catch (e) {
      _handleError('Permission request failed: ${e.toString()}');
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable) {
      _handleError('Speech recognition not available');
      return;
    }

    if (_isListening) {
      return;
    }

    try {
      _error = null;
      _recognizedText = '';
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidenceLevel = result.confidence;
          notifyListeners();
        },
        localeId: localeId,
      );
    } catch (e) {
      _handleError('Error starting voice recognition: ${e.toString()}');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
        notifyListeners();
      }
    } catch (e) {
      _handleError('Error stopping voice recognition: ${e.toString()}');
    }
  }

  /// Cancel listening and clear text
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Error canceling voice recognition: ${e.toString()}');
    }
  }

  /// Get recognized text and clear it
  String getAndClearRecognizedText() {
    final text = _recognizedText;
    _recognizedText = '';
    _confidenceLevel = 0.0;
    notifyListeners();
    return text;
  }

  /// Handle errors
  void _handleError(String message) {
    _error = message;
    _isListening = false;
    notifyListeners();
    debugPrint('Voice Service Error: $message');
  }

  /// Dispose resources
  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}

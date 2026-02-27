import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognitionService {
  static final VoiceRecognitionService _instance = VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  bool _isListening = false;
  
  // Emergency keywords
  final List<String> _emergencyKeywords = [
    'emergency',
    'help',
    'ambulance',
    'hospital',
    'accident',
    'injured',
    'hurt',
  ];

  Future<bool> initialize() async {
    if (_initialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('[Voice] Microphone permission denied');
      return false;
    }

    _initialized = await _speech.initialize(
      onStatus: (status) => print('[Voice] Status: $status'),
      onError: (error) => print('[Voice] Error: $error'),
    );

    return _initialized;
  }

  Future<void> startListening({
    required Function() onEmergencyDetected,
    required Function(String) onResult,
  }) async {
    if (!_initialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (_isListening) return;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase();
        print('[Voice] Recognized: $words');
        
        onResult(words);
        
        // Check for emergency keywords
        for (final keyword in _emergencyKeywords) {
          if (words.contains(keyword)) {
            print('[Voice] 🚨 Emergency keyword detected: $keyword');
            stopListening();
            onEmergencyDetected();
            break;
          }
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  bool get isListening => _isListening;
  bool get isAvailable => _initialized;

  void dispose() {
    stopListening();
  }
}

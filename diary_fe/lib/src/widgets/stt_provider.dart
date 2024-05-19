import 'package:diary_fe/env/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class STTProvider with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;

  String _filePath = '';

  STTProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _recorder.openRecorder();
    await _requestPermissions();
    await _setFilePath();
  }

  Future<void> _requestPermissions() async {
    final status = await [
      Permission.microphone,
    ].request();

    if (status[Permission.microphone] != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<void> _setFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/audio';
    final dir = Directory(path);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    _filePath = '$path/audio.wav';
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> toggleRecording(TextEditingController textController) async {
    if (isRecording) {
      await _stopRecording(textController);
    } else {
      await _startRecording();
    }
    notifyListeners();
  }

  Future<void> _startRecording() async {
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );
    isRecording = true;
  }

  Future<void> _stopRecording(TextEditingController textController) async {
    final path = await _recorder.stopRecorder();
    isRecording = false;
    if (path != null) {
      final result = await _convertSpeechToText(_filePath);
      textController.text += result;
    }
  }
  Future<String> _convertSpeechToText(String filePath) async {
    final dio = Dio();
    final apiKey = Env.sttKey;
    const uri = 'https://api.openai.com/v1/audio/transcriptions';

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'audio.wav'),
        'model': 'whisper-1',
        'language': 'ko',
      });

      final response = await dio.post(
        uri,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['text'];
      } else {
        return 'Error: ${response.statusMessage}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
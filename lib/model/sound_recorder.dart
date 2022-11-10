import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  // final String path = "/data/user/0/com.example.pocket_ktv/cache/example.wav";
  bool _isRecorderInitialised = false;
  bool get isRecording => _audioRecorder!.isRecording;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    // get the permission status of microphone
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Micorphone permission denied');
    }
    await _audioRecorder!.openAudioSession();
    _isRecorderInitialised = true;
  }

  void dispose() {
    // if Recorder isn't initialised
    if (!_isRecorderInitialised) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  // start recorder
  Future record(path) async {
    // if Recorder isn't initialised
    if (!_isRecorderInitialised) return;
    print('********* record outputpath : $path');
    // start recorder
    await _audioRecorder!.startRecorder(toFile: path);
  }

  // stop recorder
  Future stop() async {
    // if Recorder isn't initialised
    if (!_isRecorderInitialised) return;
    // stop recorder
    await _audioRecorder!.stopRecorder();
  }
}

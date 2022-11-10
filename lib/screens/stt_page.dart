import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/language.dart';
import 'package:pocket_ktv/model/sound_recorder.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pocket_ktv/model/stt_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttPage extends StatefulWidget {
  const SttPage({
    Key? key,
  }) : super(key: key);

  @override
  _SttPageState createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
  final recorder = SoundRecorder();
  var _isRecording = false;
  var level = 0.0;
  final _logEvents = true;
  final SpeechToText speech = SpeechToText();
  var _hasSpeech = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  var offset = Offset.zero;
  GlobalKey key = GlobalKey();
  bool userStop = false;
  var language = Language.minnan;
  bool isFinal = false;

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  @override
  void dispose() {
    recorder.dispose();
    cancelListening();
    super.dispose();
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    try {
      final hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        // debugLogging: true,
      );
      // if (hasSpeech) {
      //   // Get the list of languages installed on the supporting platform so they
      //   // can be displayed in the UI for selection by the user.
      //   _localeNames = await speech.locales();
      //   _currentLocale = (await speech.systemLocale())!;
      // }
      if (!mounted) return;
      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      _logEvent('Speech recognition failed: ${e.toString()}');
      setState(() {
        _hasSpeech = false;
      });
    }
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
  }

  Future<void> stopListening() async {
    _logEvent('stop');
    await speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 30),

      /// [pauseFor] sets the maximum duration of a pause in speech with no words
      /// detected, after that it automatically stops the listen for you.
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: language == Language.english ? 'en_US' : 'ja_JP',
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      isFinal = result.finalResult;
    });
    if (result.finalResult && userStop) {
      Navigator.pop(
        context,
        SttResult(
          result: result.recognizedWords,
          language: language,
        ),
      );
    }
  }

  void _startRecording() async {
    await recorder.init();
    Directory tempDir = await path_provider.getTemporaryDirectory();
    final wavePath = '${tempDir.path}/Song.wav';
    await recorder.record(wavePath);
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    await recorder.stop();
    setState(() {
      _isRecording = false;
    });
  }

  bool get _useStt =>
      language == Language.english || language == Language.japanese;

  final _languages = <Language>[
    Language.minnan,
    Language.chinese,
    Language.english,
    Language.japanese,
  ];

  String _getLanguageName(Language lang) {
    var name = '';
    switch (lang) {
      case Language.minnan:
        name = '台語';
        break;
      case Language.chinese:
        name = '國語';
        break;
      case Language.english:
        name = '英語';
        break;
      default:
        name = '日語';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            }
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
        actions: [
          Center(
            child: Text(
              _getLanguageName(language),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
            onPressed: () async {
              cancelListening();
              await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('選取語音搜尋使用的語言'),
                    children: _languages
                        .map(
                          (lang) => SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                language = lang;
                              });
                            },
                            child: Text(_getLanguageName(lang)),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
            icon: const Icon(
              Icons.sports_basketball_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(
            top: 74.h,
          ),
          child: Column(
            children: [
              Text(
                "請說出您想搜尋的歌曲",
                style: TextStyle(
                  fontSize: 24.sp,
                ),
              ),
              Spacer(),
              GestureDetector(
                key: key,
                child: _VoiceMic(
                  level: level,
                  isActive: _useStt ? speech.isListening : _isRecording,
                ),
                onLongPressStart: (details) {
                  // Vibration.
                  HapticFeedback.mediumImpact();

                  if (_useStt) {
                    startListening();
                  } else {
                    _startRecording();
                  }

                  // Initialize offset.
                  setState(() {
                    offset = details.globalPosition;
                  });
                },
                onLongPressMoveUpdate: (details) {
                  // Update offset when long press move.
                  setState(() {
                    offset = details.globalPosition;
                  });
                },
                onLongPressEnd: (details) async {
                  RenderBox box =
                      key.currentContext?.findRenderObject() as RenderBox;
                  Offset position = box.localToGlobal(Offset.zero);
                  Rect rect = position & box.size;
                  if (rect.contains(offset)) {
                    userStop = true;
                    if (_useStt) {
                      await stopListening();
                      if (isFinal) {
                        Navigator.pop(
                          context,
                          SttResult(
                            result: speech.lastRecognizedWords,
                            language: language,
                          ),
                        );
                      }
                    } else {
                      _stopRecording();
                      Navigator.pop(
                        context,
                        SttResult(
                          result: '',
                          language: language,
                        ),
                      );
                    }
                  } else {
                    if (_useStt) {
                      cancelListening();
                    } else {
                      _stopRecording();
                    }
                  }
                },
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceMic extends StatelessWidget {
  final double level;
  final bool isActive;

  const _VoiceMic({
    Key? key,
    required this.level,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //TODO: remove them
      // padding: const EdgeInsets.all(15),
      // margin: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: .26,
            spreadRadius: level * 3,
            color: Colors.black.withOpacity(.05),
          ),
        ],
        color: isActive ? Colors.red : Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mic, size: 100),
    );
  }
}

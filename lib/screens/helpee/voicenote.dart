import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/widgets/myanim.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceNote extends StatefulWidget {
  final Color backgroundColor;
  final Color iconsColor;
  final Color barsColor;
  final Function(String path, Duration duration) onDone;
  final Function onDelete;

  VoiceNote(
      {Key key,
      this.backgroundColor,
      this.iconsColor,
      this.barsColor,
      this.onDone,
      this.onDelete})
      : super(key: key);

  @override
  _VoiceNoteState createState() => _VoiceNoteState();
}

class _VoiceNoteState extends State<VoiceNote> {
  //getting file info
  final LocalFileSystem localFileSystem = LocalFileSystem();
  //recoder and player
  Recording recording = new Recording();
  AudioPlayer audioPlugin = new AudioPlayer();
  //Server calls
  final AuthService _auth = AuthService();

  //Controll recorder and player variables
  bool isRecorded = false;
  bool isRecording = false;
  bool isPlaying = false;
  String lastPath = '';
  String filename = '';
  Timer _timer;
  int minutes = 0;
  int seconds = 0;
  Duration _duration = new Duration(minutes: 0, seconds: 0);

  Widget _recordIcon() {
    AssetImage assetImage = AssetImage('assets/images/recording.png');
    Image image = Image(
      image: assetImage,
      height: 40,
      color: widget.iconsColor,
    );
    return image;
  }

  Widget _stopIcon() {
    AssetImage assetImage = AssetImage('assets/images/stopred.png');
    Image image = Image(
      image: assetImage,
      height: 40,
      color: widget.iconsColor,
    );
    return image;
  }

  Widget _playIcon() {
    AssetImage assetImage = AssetImage('assets/images/play.png');
    Image image = Image(
      image: assetImage,
      height: 40,
      color: widget.iconsColor,
    );
    return image;
  }

  Widget _playButtonDisabled() {
    return MyAnim(
      sizeNormal: 40,
      sizeSmall: 30,
      speedMiliseconds: 500,
      curve: Curves.fastOutSlowIn,
      centerWidget: Icon(
        Icons.mic,
        color: Colors.white,
        size: 20,
      ),
      color: Colors.red,
    );
  }

  //Getting permission of microphone
  _reqPermission() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }
  //Region calls

  void startRecording() {
    print('Rec start rec');
    _start();
  }

  void stopRecording() {
    print('Rec stop rec');
    _stop();
  }

  void playVoiceNote() {
    print(_duration);
    if (_duration.inSeconds == 0 && _duration.inMinutes == 0) return;
    print('Playing');
    audioPlugin = AudioPlayer();
    audioPlugin.play(lastPath);
    audioPlugin.onPlayerStateChanged.listen((event) {
      playerStateChanged(event);
    });
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer t) => _setTimerDuration());
    setState(() {
      isPlaying = true;
    });
  }

  void playerStateChanged(AudioPlayerState state) {
    if (state == AudioPlayerState.COMPLETED) stopVoiceNote();
  }

  void stopVoiceNote() {
    audioPlugin.stop();
    _timer.cancel();
    setState(() {
      isPlaying = false;
      minutes = 0;
      seconds = 0;
    });
  }

  void deleteLastRecording() async {
    if (lastPath == '') return;

    await io.File(lastPath).delete();
    setState(() {
      lastPath = '';
      isRecorded = false;
      minutes = 0;
      seconds = 0;
      _duration = new Duration();
    });
    print("last rec deleted");
    widget.onDelete.call();
  }

  random(min, max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }

  _start() async {
    seconds = 0;
    minutes = 0;
    try {
      if (await Permission.microphone.isGranted) {
        print('Permission Granted');
        String path = "";
        String myid = await _auth.getLocalString(Appdetails.myidKey);
        //format myid
        String currentFilename =
            myid + DateTime.now().millisecondsSinceEpoch.toString();
        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        String recPath = appDocDirectory.path + '/' + 'helpal/voices/$myid';
        print(recPath);

        bool ifExist = await io.Directory(recPath).exists();
        if (!ifExist) {
          await io.Directory(recPath).create(recursive: true);
        }
        path = recPath + '/$currentFilename';

        print(path);
        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.AAC);
        bool isRec = await AudioRecorder.isRecording;

        setState(() {
          filename = currentFilename;
          lastPath = path + '.m4a';
          isRecording = isRec;
          recording = new Recording(duration: new Duration(), path: "");
        });

        const oneSec = const Duration(seconds: 1);
        _timer = new Timer.periodic(oneSec, (Timer t) => _setTimerDuration());
      } else {
        //Notification for microphon permission
        _reqPermission();
      }
    } catch (e) {
      print('need permission:' + e.toString());
    }
  }

  _setTimerDuration() {
    print("Timer Updating");
    setState(() {
      seconds++;
      if (seconds > 59) {
        seconds = 0;
        minutes++;
      }
    });
  }

  _stop() async {
    if (_timer != null) _timer.cancel();

    var record = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRec = await AudioRecorder.isRecording;
    File file = localFileSystem.file(record.path);
    print("File length: ${await file.length()}");
    setDuration(record.duration);
    setState(() {
      recording = record;
      isRecording = isRec;
    });
  }

  void setDuration(Duration dur) {
    setState(() {
      _duration = dur;
      isRecorded = true;
    });
    widget.onDone(lastPath, _duration);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 10),
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //REGION PLAY BUTTON
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      child: !isRecording && !isPlaying
                          ? _playIcon()
                          : isRecording && !isPlaying
                              ? _playButtonDisabled()
                              : _stopIcon(),
                      onTap: () {
                        //play voice note
                        if (!isRecording && !isPlaying) {
                          playVoiceNote();
                        } else if (!isRecording && isPlaying) {
                          stopVoiceNote();
                        }
                      },
                    ),
                  ),
                  //END PLAY BUTTON
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    _duration.inSeconds > 0
                        ? "--||||||-|--||||||||----|||||||||----"
                        : "----------------------------------",
                    style: TextStyle(
                      color: _duration.inSeconds > 0
                          ? widget.barsColor
                          : Colors.grey[400],
                      fontSize: 22,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: isRecording ? 45 : 35,
                        height: isRecording ? 45 : 35,
                        child: isRecorded
                            ? InkWell(
                                child:
                                    Icon(Icons.close, color: widget.iconsColor),
                                onTap: () {
                                  deleteLastRecording();
                                },
                              )
                            : GestureDetector(
                                /* onVerticalDragStart: (details) {
                            print(details.globalPosition.dy);
                          },
                          onVerticalDragUpdate: (details) {
                            print(details.globalPosition.dy);
                          }, */
                                child: _recordIcon(),
                                onTapDown: (details) {
                                  startRecording();
                                  //HapticFeedback.vibrate();
                                },
                                onTapUp: (details) => stopRecording(),
                              ),
                      ),
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
}

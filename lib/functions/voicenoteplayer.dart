import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/functions/storagehandler.dart';
import 'package:overlay_support/overlay_support.dart';

class VoiceNotePlayer extends StatefulWidget {
  final String firestoreFilename;
  final String fileUrl;
  final Color activeColor;

  const VoiceNotePlayer(
      {Key key,
      this.firestoreFilename = "",
      this.fileUrl = "",
      this.activeColor = Colors.black})
      : super(key: key);

  @override
  _VoiceNotePlayerState createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  String disabledBars = "---------------------------------------";
  String enabledBars = "---||||||--||||||||||||||----||||||-||---";
  //voice note
  bool isplaying = false;
  bool isAvailable = false;

  AudioPlayer audioPlugin = new AudioPlayer();

  Color fieldsBgColor() => widget.activeColor.withAlpha(30);
  TextStyle disableStyle() => TextStyle(color: Colors.grey[800], fontSize: 26);
  TextStyle enableStyle() => TextStyle(color: widget.activeColor, fontSize: 26);

  void playVoiceNote(String path) {
    setState(() {
      isplaying = false;
    });
    print('Playing');
    audioPlugin = AudioPlayer();
    audioPlugin.play(path);
    audioPlugin.onPlayerStateChanged.listen((event) {
      playerStateChanged(event);
    });
  }

  void playerStateChanged(AudioPlayerState state) {
    if (state == AudioPlayerState.COMPLETED) stopVoiceNote();
  }

  void stopVoiceNote() {
    audioPlugin.stop();
    setState(() {
      isplaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    isAvailable =
        widget.fileUrl == "" && widget.firestoreFilename == "" ? false : true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: fieldsBgColor(),
      ),
      child: ListTile(
        leading: InkWell(
            child: Icon(
              Icons.play_arrow,
              color: isAvailable ? Colors.grey[700] : Colors.grey[500],
              size: 35,
            ),
            onTap: () async {
              if (isplaying) {
                stopVoiceNote();
              } else {
                //play voice note
                if (!isAvailable) {
                  toast("Voice note not found", duration: Toast.LENGTH_SHORT);
                  return;
                }
                String url = "";
                //if direct url
                if (widget.fileUrl != "") {
                  url = widget.fileUrl;
                }
                //if firestore file
                else {
                  url = await StorageHandler.getDownloadUrl(
                      widget.firestoreFilename, UploadTypes.VoiceNote);
                  print("Playing $url");
                }

                playVoiceNote(url);
              }
            }),
        title: Text(
          isAvailable ? enabledBars : disabledBars,
          style: isAvailable ? enableStyle() : disableStyle(),
        ),
      ),
    );
  }
}

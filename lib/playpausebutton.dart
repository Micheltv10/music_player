import 'package:flutter/material.dart';
import 'package:music_player/main.dart';
import 'package:ocarina/ocarina.dart';

class PlayPauseButtonWidget extends StatefulWidget {
  final bool playing;
  final Player player;
  final int size;
  final BoolConsumer setPlaying;
  PlayPauseButtonWidget({ Key? key, required this.playing, required this.player, required this.size, required this.setPlaying}) : super(key: key);

  @override
  _PlayPauseButtonWidgetState createState() => _PlayPauseButtonWidgetState(playing);
}

class _PlayPauseButtonWidgetState extends State<PlayPauseButtonWidget> {
  bool playing;
  _PlayPauseButtonWidgetState(this.playing);
@override
  void didUpdateWidget(covariant PlayPauseButtonWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    playing = widget.playing;
    print('_playPauseButtonWidgetState.didUpdateWidget playing = $playing');
  }

  

  @override
  Widget build(BuildContext context) {
    if (playing) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: widget.size.toDouble(),
        onPressed: () async {
          await widget.player.pause();
            widget.setPlaying(false);
            setState(() {
              playing = false;
            });
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: widget.size.toDouble(),
        onPressed: () async {
          await widget.player.play();
            widget.setPlaying(true);
            setState(() {
              playing = true;
            });
        },
      );
    }
  }
}
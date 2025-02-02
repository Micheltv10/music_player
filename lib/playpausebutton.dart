import 'package:flutter/material.dart';
import 'package:music_player/config.dart';
import 'package:music_player/main.dart';
import 'package:music_player/player.dart';

class PlayPauseButtonWidget extends StatefulWidget {
  final bool playing;
  final Player player;
  final int size;
  final BoolConsumer setPlaying;
  const PlayPauseButtonWidget({ Key? key, required this.playing, required this.player, required this.size, required this.setPlaying}) : super(key: key);

  @override
  _PlayPauseButtonWidgetState createState() => _PlayPauseButtonWidgetState(playing);
}

class _PlayPauseButtonWidgetState extends State<PlayPauseButtonWidget> {
  bool playing;
  _PlayPauseButtonWidgetState(this.playing);
@override
  void didUpdateWidget(covariant PlayPauseButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    playing = widget.playing;
  }

  

  @override
  Widget build(BuildContext context) {
    if (playing) {
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: widget.size.toDouble(),
        onPressed: () async {
          await widget.player.pause();
            widget.setPlaying(false);
            setState(() {
              playing = false;
            });
        },
        color: currentTheme.currentTheme() == ThemeMode.dark ? Colors.white : Colors.black,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
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
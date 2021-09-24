import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/karaoke.dart';
import 'package:music_player/player.dart';
import 'package:music_player/playpausebutton.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:music_player/types.dart';
import 'main.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PlayerWidget extends StatefulWidget {
  final Player player;
  final bool playing;
  final SongData currentSong;
  final String currentArtist;
  final BoolConsumer setPlaying;
  final Audiotagger tagger;
  const PlayerWidget(
      {Key? key,
      required this.playing,
      required this.currentArtist,
      required this.currentSong,
      required this.player,
      required this.setPlaying,
      required this.tagger,})
      : super(key: key);

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState(playing);
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool playing;
  _PlayerWidgetState(this.playing);

  songNameLength(songName) {
    if (songName.toString().length > 15) {
      return Marquee(
        text: songName,
        style: const TextStyle(
          fontSize: 20,
        ),
        blankSpace: 40.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10,
      );
    } else {
      return Text(
        songName,
        style: const TextStyle(fontSize: 20),
      );
    }
  }

  @override
  void didUpdateWidget(PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    playing = widget.playing;
  }

  artistNameLength(artistName) {
    if (artistName == "") {
      return const Text(
        "<unknown>",
        style: TextStyle(fontSize: 13),
      );
    }
    if (artistName.toString().length > 24) {
      return Marquee(
        text: artistName,
        style: const TextStyle(
          fontSize: 13,
        ),
        blankSpace: 40.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10,
      );
    } else {
      return Text(
        artistName,
        style: const TextStyle(fontSize: 13),
      );
    }
  }

  Future<double> getSongDuration() async {
    final filePath = "storage/emulated/0/Download/${widget.currentSong}.mp3";
    Map? map = await widget.tagger.readAudioFileAsMap(path: filePath);
    int length = map!['length'];
    return length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.currentSong.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Spacer(
              flex: 2,
            ),
            CarouselSlider(
              options: CarouselOptions(height: 400.0, viewportFraction: 0.95),
              items: [1, 2].map((i) {
                return FutureBuilder<Widget>(
                  future: sliderCarousel(i),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    }

                    return const CircularProgressIndicator();
                  },
                );
              }).toList(),
            ),
            const Spacer(
              flex: 2,
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 25),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ColoredBox(
                              color: Colors.deepPurple,
                              child: Center(
                                child: songNameLength(widget.currentSong),
                              ),
                            ),
                          ),
                        )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FutureBuilder<double>(
                              future: getSongDuration(),
                              builder: (context, snapshot) {
                                return PositionSliderWidget(
                                  player: widget.player,
                                  maxPosition:
                                      snapshot.hasData ? snapshot.data! : 10,
                                );
                              }),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlayPauseButtonWidget(
                              player: widget.player,
                              playing: playing,
                              size: 64,
                              setPlaying: widget.setPlaying,
                            ),
                          ],
                        )),
                  ]),
                ),
              ],
            ),
          ],
        ));
  }

  Future<Widget> sliderCarousel(i) async {
    if (i == 1) {
      return await getArtwork();
    } else {
      return KaraokeWidget(song: widget.currentSong, player: widget.player);
    }
  }

  getArtwork() async {
    Widget artwork;
    final String filePath =
        "/storage/emulated/0/Download/${widget.currentSong}.mp3";
    final output = await widget.tagger.readArtwork(path: filePath);
    artwork = output != null
        ? Image.memory(output)
        : const Icon(
            Icons.music_note,
            size: 256,
          );
    return artwork;
  }
}

class PositionSliderWidget extends StatefulWidget {
  final double maxPosition;
  final Player player;
  const PositionSliderWidget(
      {Key? key, required this.maxPosition, required this.player})
      : super(key: key);

  @override
  _PositionSliderWidgetState createState() => _PositionSliderWidgetState();
}

class _PositionSliderWidgetState extends State<PositionSliderWidget> {
  int position = 0;
  bool disposed = false;
  Timer? timer;

  startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 300), onTimer);
  }

  onTimer(Timer timer) async {
    if (widget.player.isLoaded()) {
    var newPosition = await widget.player.position();
    if (!disposed) {
      setState(() {
        position = newPosition;
      });
    }
    }
  }

  @override
  dispose() {
    disposed = true;
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }
  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
  @override
  Widget build(BuildContext context) {
    if ((position / 1000) > widget.maxPosition) {
      position = widget.maxPosition.toInt() * 1000;
    }
    return Column(
      children: [
        Slider(
          value: (position / 1000),
          min: 0,
          max: widget.maxPosition,
          onChanged: (double newValue) {
            widget.player.seek(Duration(seconds: newValue.toInt()));
          },
        ),
        /*Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(format(Duration(seconds: (position / 1000).toInt()))), Text(format(Duration(seconds: widget.maxPosition.toInt())))],
          ),
        )*/
      ],
    );
  }
}

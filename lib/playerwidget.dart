import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/karaoke.dart';
import 'package:music_player/player.dart';
import 'package:music_player/playpausebutton.dart';
import 'package:music_player/tagger.dart';
import 'package:music_player/types.dart';
import 'main.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PlayerWidget extends StatefulWidget {
  final Player player;
  final bool playing;
  final SongData currentSong;
  final String currentArtist;
  final BoolConsumer setPlaying;
  final AudioTagger tagger;
  const PlayerWidget({
    Key? key,
    required this.playing,
    required this.currentArtist,
    required this.currentSong,
    required this.player,
    required this.setPlaying,
    required this.tagger,
  }) : super(key: key);

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState(playing);
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool playing;
  _PlayerWidgetState(this.playing);

  songNameLength(songName) {
    if (songName.toString().length > 33) {
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

  Future<int> getSongDuration() async {
    Duration length = await widget.currentSong.songDuration;
    return length.inSeconds;
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
            CarouselSlider(
              options: CarouselOptions(height: 400.0, viewportFraction: 0.95),
              items: [1, 2, 3, 4].map((i) {
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
                                child: songNameLength(widget.currentSong.title),
                              ),
                            ),
                          ),
                        )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.deepPurple,
                              inactiveTrackColor: Colors.deepPurpleAccent,
                              trackShape: const RoundedRectSliderTrackShape(),
                              trackHeight: 5.0,
                              thumbColor: Colors.purple,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 8.0),
                            ),
                            child: FutureBuilder<int>(
                                future: getSongDuration(),
                                builder: (context, snapshot) {
                                  return PositionSliderWidget(
                                    player: widget.player,
                                    maxPosition:
                                        snapshot.hasData ? snapshot.data! : 10,
                                  );
                                }),
                          ),
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
      return await Image.network(widget.currentSong.coverUri.toString());
    }
    if (i == 2) {
      return KaraokeWidget(song: widget.currentSong, player: widget.player);
    }
    if (i == 3) {
      return SelectAudioKindWidget(
          player: widget.player, currentSong: widget.currentSong);
    } else {
      return ShowNotesWidget(
        songData: widget.currentSong,
      );
    }
  }

  getArtwork() async {
    Widget artwork;
    final String filePath = widget.currentSong.songUri.toFilePath();
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
  final int maxPosition;
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
          max: widget.maxPosition.toDouble(),
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

class SelectAudioKindWidget extends StatefulWidget {
  final Player player;
  final SongData currentSong;
  const SelectAudioKindWidget(
      {Key? key, required this.player, required this.currentSong})
      : super(key: key);

  @override
  _SelectAudioKindWidgetState createState() => _SelectAudioKindWidgetState();
}

class _SelectAudioKindWidgetState extends State<SelectAudioKindWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          width: 1,
          height: 1,
          child: widget.player.youtubeWidget,
        ),
        SizedBox(
          width: size.width,
          height: size.height * 0.39,
          child: ListView.builder(
              itemCount: widget.currentSong.audios.length,
              itemBuilder: (context, index) {
                final size = MediaQuery.of(context).size;
                AudioData audioData = widget.currentSong.audios[index];
                return Center(
                  child: SizedBox(
                    height: 90,
                    width: size.width * 0.9,
                    child: Column(
                      children: [
                        Text("Name = ${audioData.name.toString()}"),
                        audioDataKindIcon(audioData),
                        TextButton(
                          onPressed: () async {
                            if (audioData.kind == "song") {
                              await widget.player.load(audioData.uri);
                              await widget.player.play();
                            } else {
                              await widget.player.load(audioData.uri);
                              await widget.player.play();
                            }
                          },
                          child: Text("Play"),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
        TextButton(
            onPressed: () {
              widget.player.dispose();
            },
            child: Text('Dispose'))
      ],
    );
  }
}

Widget audioDataKindIcon(AudioData audioData) {
  if (audioData.kind == AudioKind.firstVoice) {
    return Icon(Icons.person);
  }
  if (audioData.kind == AudioKind.secondVoice) {
    return Icon(Icons.people);
  }
  if (audioData.kind == AudioKind.thirdVoice) {
    return Icon(Icons.person);
  }
  if (audioData.kind == AudioKind.guitar) {
    return Icon(Icons.groups);
  }
  if (audioData.kind == AudioKind.song) {
    return Icon(Icons.music_note);
  }
  if (audioData.kind == AudioKind.pronunciation) {
    return Icon(Icons.record_voice_over);
  } else {
    return Text('How?');
  }
}

class ShowNotesWidget extends StatefulWidget {
  final SongData songData;
  const ShowNotesWidget({
    Key? key,
    required this.songData,
  }) : super(key: key);

  @override
  _ShowNotesWidgetState createState() => _ShowNotesWidgetState();
}

class _ShowNotesWidgetState extends State<ShowNotesWidget> {
  getNotesImage() {
    final url = (widget.songData.images
            .firstWhere((element) => element.kind == ImageKind.notes))
        .uri
        .toString();
    print('ShowNotesWidgetState.notesImage url = $url');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    print('ShowNotesWidgetState build');
    return SizedBox(
      child: Image(
        image: NetworkImage(getNotesImage()),
      ),
    );
  }
}

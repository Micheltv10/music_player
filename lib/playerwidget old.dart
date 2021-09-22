import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/helpers/get_directory_lyrics.dart';
import 'package:music_player/playpausebutton.dart';
import 'package:ocarina/ocarina.dart';
import 'package:audiotagger/audiotagger.dart';
import 'main.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PlayerWidget extends StatefulWidget {
  OcarinaPlayer player;
  bool playing;
  String currentSong;
  String currentArtist;
  BoolConsumer setPlaying;
  final tagger = new Audiotagger();
  PlayerWidget(
      {Key? key,
      required this.playing,
      required this.currentArtist,
      required this.currentSong,
      required this.player,
      required this.setPlaying})
      : super(key: key);

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState(playing);
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool playing;
  final tagger = new Audiotagger();
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
      return Text(
        "<unknown>",
        style: const TextStyle(fontSize: 13),
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

  Future<double> getSongDuration() async{
    final filePath = "storage/emulated/0/Download/${widget.currentSong}.mp3";
    Map? map = await tagger.readAudioFileAsMap(path: filePath);
    int length = map!['length'];
    return length.toDouble();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.currentSong),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Spacer(
              flex: 2,
            ),
            CarouselSlider(
              options: CarouselOptions(height: 400.0),
              items: [1, 2, 3, 4, 5].map((i) {
                return FutureBuilder<Widget>(
                  future: sliderCarousel(i),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    }

                    return Container(child: CircularProgressIndicator());
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
                          child: Stack(
                            children: [
                              FutureBuilder<double>(
                                future: getSongDuration(),
                                builder: (context, snapshot) {
                                  return AnimatedSlider(widget: widget,minPosition: 0, maxPosition: snapshot.hasData? snapshot.data! : 10 ,);
                                }
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [Text("data"), Text("data")],
                          ),
                        )
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
      return Text('data');
    }
  }

  getArtwork() async {
    Widget artwork;
    final String filePath = "/storage/emulated/0/Download/${widget.currentSong}.mp3";
    final output = await tagger.readArtwork(path: filePath);
    artwork = output != null ? Image.memory(output) : const Icon(Icons.music_note, size: 256,);
    return artwork;
  }
}

class AnimatedSlider extends StatefulWidget {
  final double maxPosition;
  final double minPosition;
  const AnimatedSlider({
    Key? key,
    required this.widget,
    required this.maxPosition,
    required this.minPosition
  }) : super(key: key);

  final PlayerWidget widget;

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider> with TickerProviderStateMixin{
    late AnimationController _animationController;
    double position = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_AnimatedSliderState.build builds");
    return FutureBuilder<int>(
      future: widget.widget.player.position(),
      builder: (context, snapshot) {
        return Slider(
          onChanged: null,
          min: widget.minPosition,
          max: widget.maxPosition,
          value: snapshot.hasData? (position = snapshot.data!.toDouble() / 1000) : position,
        );
      }
    );
  }
}

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
  String dropdownValue = 'One';
  ImageKind imageValue = ImageKind.cover;
  AudioKind audioValue = AudioKind.song;
  TextKind textValue = TextKind.lyrics;
  _PlayerWidgetState(this.playing);
  CarouselController carouselController = CarouselController();

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
            carouselController: carouselController,
            options: CarouselOptions(height: 400.0, viewportFraction: 0.95),
            items: [
              1,
              2,
            ].map((i) {
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
          Container(
            decoration: BoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<TextKind>(
                  value: textValue,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (TextKind? newValue) {
                    setState(() {
                      textValue = newValue!;
                    });
                    carouselController.jumpToPage(1);
                  },
                  items: getTexts(),
                ),
                DropdownButton<ImageKind>(
                  value: imageValue,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (ImageKind? newValue) {
                    setState(() {
                      imageValue = newValue!;
                    });
                    carouselController.jumpToPage(2);
                  },
                  items: getImages(),
                ),
                DropdownButton<AudioKind>(
                  value: audioValue,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  items: getAudios(),
                  onChanged: (AudioKind? newValue) async{
                    setState(() {
                      audioValue = newValue!;
                    });
                    var uri = widget.currentSong.audios.firstWhere((element) => element.kind == newValue).uri;
                    await widget.player.load(uri);
                    widget.player.play();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem<AudioKind>> getAudios() {
    List<String> titles = [];
    List audios = widget.currentSong.audios;
    if (audios.isEmpty) {
      return [
        const DropdownMenuItem(
          value: AudioKind.song,
          child: Text("No Audios"),
        )
      ];
    }
    List<DropdownMenuItem<AudioKind>> items = [];

    for (int i = 0; i < audios.length; i++) {
      AudioData audio = audios[i];
      print("getAudios Audio.kind ${audio.kind.toString().substring(10)}");
      items.add(DropdownMenuItem<AudioKind>(
        value: audio.kind,
        child: Text(audio.kind.toString().substring(10)),
      ));
    }

    return items;
  }

  List<DropdownMenuItem<ImageKind>> getImages() {
    List<String> titles = [];
    List images = widget.currentSong.images;
    if (images.isEmpty) {
      return [
        const DropdownMenuItem(
          value: ImageKind.cover,
          child: Text("No Images"),
        )
      ];
    }
    List<DropdownMenuItem<ImageKind>> items = [];
    for (int i = 0; i < images.length; i++) {
      ImageData image = images[i];
      items.add(DropdownMenuItem<ImageKind>(
        value: image.kind,
        child: Text(image.kind.toString().substring(10)),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<TextKind>> getTexts() {
    List<String> titles = [];
    List texts = widget.currentSong.texts;
    if (texts.isEmpty) {
      return [
        const DropdownMenuItem(
          value: TextKind.lyrics,
          child: Text("No Texts"),
        )
      ];
    }
    List<DropdownMenuItem<TextKind>> items = [];
    for (int i = 0; i < texts.length; i++) {
      TextData text = texts[i];
      items.add(DropdownMenuItem<TextKind>(
        value: text.kind,
        child: Text(text.kind.toString().substring(9)),
      ));
    }
    return items;
  }

  Future<Widget> sliderCarousel(i) async {
    if (i == 1) {
      if (imageValue == ImageKind.artist) {
        return Image(
            image: NetworkImage(widget.currentSong.images
                .firstWhere((element) => element.kind == ImageKind.artist)
                .uri
                .toString()));
      }
      if (imageValue == ImageKind.cover) {
        return Image(
            image: NetworkImage(widget.currentSong.images
                .firstWhere((element) => element.kind == ImageKind.cover)
                .uri
                .toString()));
      } else {
        return Image(image: NetworkImage(widget.currentSong.images.firstWhere((element) => element.kind == ImageKind.notes).uri.toString()));
      }
    }
    if (i == 2) {
      if (textValue == TextKind.lyrics){
      return KaraokeWidget(song: widget.currentSong, player: widget.player);
      }if (textValue == TextKind.phonetics){
        return Text((await widget.currentSong.texts.firstWhere((element) => element.kind == TextKind.phonetics).text).join(" "));
      }else {
        return Text((await widget.currentSong.texts.firstWhere((element) => element.kind == TextKind.translation).text).join(" "));
      }
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
      position = (widget.maxPosition.toInt() / 10).toInt();
    }
    print("position =$position");
    print('Max position = ${widget.maxPosition.toInt()}');

    return Column(
      children: [
        Slider(
          value: (position / 100),
          min: 0,
          max: widget.maxPosition.toDouble(),
          onChanged: (double newValue) {
            // widget.player.seek(Duration(seconds: newValue.toInt()));
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
          child: widget.player.widget,
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

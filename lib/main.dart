import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/playpausebutton.dart';
import 'package:ocarina/ocarina.dart';
import 'helpers/get_directory_music.dart';
import 'package:audiotagger/audiotagger.dart';
import 'playerwidget.dart';

typedef BoolConsumer = void Function(bool value);
void main() async {
  runApp(MyApp(
    songNames: await getDirectoriesMusic(),
  ));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  List<String> songNames;
  MyApp({Key? key, required this.songNames}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Music Player',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: MyHomePage(
          title: 'Home',
          songNames: songNames,
        ),
      );
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.songNames})
      : super(key: key);
  List<String> songNames;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SlidableController slidableController = SlidableController();
  OcarinaPlayer? player;
  bool? playing;
  String? currentSong;
  String? currentArtist;
  List? queue;
  final tagger = Audiotagger();
  bool timerStarted = false;

  void setPlaying(bool value) {
    setState(() {
      playing = value;
    });
  }

  Future<double> getSongDuration(songName) async {
    String filePath = "storage/emulated/0/Download/$songName.mp3";
    final Map? audiomap = await tagger.readAudioFileAsMap(path: filePath);
    int length = audiomap!['length'];
    return length.toDouble();
  }

  Widget songNameLength(String songName) {
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

  Widget artistNameLength(String artistName) {
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

  void startTimer(Duration time) => Timer.periodic(time, playNextSong);
  void playNextSong(Timer timer) async {
    String filePath = "storage/emulated/0/Download/$currentSong.mp3";
    final Map? audiomap = await tagger.readAudioFileAsMap(path: filePath);
    int length = audiomap!['length'];
    int position = await player!.position();

    if (((position / 1000) + 1) >= length) {
      await player!.dispose();
      if (queue != null) {
        String filePathQueue = "storage/emulated/0/Download/${queue?[0]}.mp3";
        final Map? map = await tagger.readTagsAsMap(path: filePathQueue);
        final newPlayer = OcarinaPlayer(filePath: filePath);
        await newPlayer.load();
        await newPlayer.play();
        setState(() {
          player = newPlayer;
          currentSong = queue![0];
          currentArtist = map?["artist"];
          
        });
        queue!.removeAt(0);
      } else {
        final _random = Random();
        String newSong =
            widget.songNames[_random.nextInt(widget.songNames.length)];
        final Map? map = await tagger.readTagsAsMap(
            path: 'storage/emulated/0/Download/$newSong.mp3');
        final newPlayer =
            OcarinaPlayer(filePath: "storage/emulated/0/Download/$newSong.mp3");
        await newPlayer.load();
        await newPlayer.play();
        setState(() {
          player = newPlayer;
          currentSong = newSong;
          currentArtist = map?["artist"];
          
        });
      }
    } else {
      print(
          '_MyHomePageState.playNextSong position = ${(position / 1000).toString()}');
    }
  }

  smallPlayerWidget() {
    final size = MediaQuery.of(context).size;
    if (player != null) {
      if (player!.isLoaded()) {
        return SizedBox(
          width: double.infinity,
          height: 91,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.deepPurple[300]),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlayerWidget(
                            playing: playing!,
                            player: player!,
                            currentArtist: currentArtist!,
                            currentSong: currentSong!,
                            setPlaying: setPlaying,
                          )),
                );
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 0, right: 8),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Container(
                            child: FutureBuilder<Widget>(
                              future: getArtwork(currentSong),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Widget> snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 75,
                        width: size.width * 0.48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 25,
                              child: songNameLength(currentSong!),
                            ),
                            SizedBox(
                              height: 22,
                              child: artistNameLength(currentArtist!),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Center(
                        child: PlayPauseButtonWidget(
                          player: player!,
                          playing: playing!,
                          size: 32,
                          setPlaying: setPlaying,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.deepPurple,
                      inactiveTrackColor: Colors.deepPurpleAccent,
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 5.0,
                      thumbColor: Colors.purple,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
                    ),
                    child: FutureBuilder<double>(
                        future: getSongDuration(currentSong),
                        builder: (context, snapshot) {
                          return PositionSliderWidget(
                              maxPosition:
                                  snapshot.hasData ? snapshot.data! : 200000,
                              player: player!);
                        }),
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.deepPurple[300]),
            child: const Center(
                child: Text(
              'No Song selcted',
              style: TextStyle(fontSize: 30),
            )),
          ),
        );
      }
    } else {
      return SizedBox(
        width: double.infinity,
        height: 75,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: Colors.deepPurple[300]),
          child: const Center(
              child: Text(
            'No Song selcted',
            style: TextStyle(fontSize: 30),
          )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 15,
            right: 15,
            child: SizedBox(
              height: size.height * 0.99,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    left: 1, right: 1, bottom: 250, top: 1),
                itemCount: widget.songNames.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    controller: slidableController,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        icon: Icons.favorite_border,
                        color: Colors.red,
                        closeOnTap: false,
                        onTap: () {},
                      ),
                      IconSlideAction(
                        icon: Icons.playlist_add,
                        caption: 'Playlist Add',
                        color: Colors.green,
                        closeOnTap: false,
                        onTap: () async {
                          if (queue == null) {
                            queue = [(widget.songNames[index])];
                          } else {
                            queue!.add(widget.songNames[index]);
                          }
                          print(queue);
                        },
                      )
                    ],
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          )),
                      child: ListTile(
                        title: Text(widget.songNames[index]),
                        leading: CircleAvatar(
                          child: Center(
                            child: FutureBuilder<Widget>(
                              future: getArtwork(widget.songNames[index]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Widget> snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                }

                                return const CircularProgressIndicator();
                              },
                            ),
                          ),
                        ),
                        onTap: () async {
                          if (player != null) {
                            if (player!.isLoaded()) {
                              await player!.dispose();
                            }
                          }

                          final String filePath =
                              "/storage/emulated/0/Download/${widget.songNames[index]}.mp3";
                          final Map? map =
                              await tagger.readTagsAsMap(path: filePath);

                          final Map? audiomap =
                              await tagger.readAudioFileAsMap(path: filePath);

                          final newplayer = OcarinaPlayer(
                              filePath:
                                  'storage/emulated/0/Download/${widget.songNames[index]}.mp3');
                          await newplayer.load();
                          newplayer.play();

                          setState(() {
                            currentSong = widget.songNames[index];
                            currentArtist = map?["artist"];
                            player = newplayer;
                            setPlaying(true);
                          });
                          if (!timerStarted) {
                            timerStarted = true;
                            startTimer(const Duration(milliseconds: 500));
                          }
                        },
                      ),
                    ),
                    actionPane: const SlidableDrawerActionPane(), //
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.020,
            left: 10,
            right: 10,
            child: smallPlayerWidget(),
          ),
        ],
      ),
    );
  }

  Future<Widget> getArtwork(songName) async {
    Widget artwork;
    final String filePath = "/storage/emulated/0/Download/$songName.mp3";
    final output = await tagger.readArtwork(path: filePath);
    artwork = output != null
        ? Image.memory(output)
        : const Icon(
            Icons.music_note,
          );
    return artwork;
  }
}

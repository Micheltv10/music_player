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
typedef SetStateFunction = void Function(void Function() fn);
void main() async {
  runApp(MyApp(
    player: Player(),
    songNames: await getDirectoriesMusic(),
  ));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  List<String> songNames;
  final Player player;
  MyApp({Key? key, required this.songNames, required this.player}) : super(key: key);

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
          player: player,
        ),
      );
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final Player player;
  MyHomePage({Key? key, required this.title, required this.songNames, required this.player})
      : super(key: key);
  List<String> songNames;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SlidableController slidableController = SlidableController();
  Player get player => widget.player;
  bool? playing;
  String? get currentSong => nextSongTimer?.currentSong;
  String? get currentArtist => nextSongTimer?.currentArtist;
  Audiotagger? get tagger => nextSongTimer?.tagger;

  NextSongTimer? nextSongTimer;

  void setPlaying(bool value) {
    setState(() {
      playing = value;
    });
  }

  @override
  initState() {
    super.initState();
    nextSongTimer = NextSongTimer(
        currentSong: null,
        currentArtist: null,
        player: Player(),
        songNames: widget.songNames,
        setState: setState);
  }

  Future<double> getSongDuration(songName) async {
    String filePath = "storage/emulated/0/Download/$songName.mp3";
    final Map? audiomap = await tagger?.readAudioFileAsMap(path: filePath);
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
                nextSongTimer?.stopTimer();
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
                          nextSongTimer?.addToQueue(widget.songNames[index]);
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
                          

                          final String filePath =
                              "/storage/emulated/0/Download/${widget.songNames[index]}.mp3";
                          final Map? map =
                              await tagger?.readTagsAsMap(path: filePath);

                          final Map? audiomap =
                              await tagger?.readAudioFileAsMap(path: filePath);

                          
                          await player.load('storage/emulated/0/Download/${widget.songNames[index]}.mp3');
                          player.play();
                          nextSongTimer?.stopTimer();
                          setState(() {
                            nextSongTimer = NextSongTimer(
                                currentSong: widget.songNames[index],
                                currentArtist: map?["artist"],
                                player: player,
                                songNames: widget.songNames,
                                setState: setState);
                            setPlaying(true);
                          });
                          nextSongTimer
                              ?.startTimer(Duration(milliseconds: 500));
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
    final output = await tagger?.readArtwork(path: filePath);
    artwork = output != null
        ? Image.memory(output)
        : const Icon(
            Icons.music_note,
          );
    return artwork;
  }
}

class NextSongTimer {
  String? currentSong;

  final tagger = Audiotagger();

  Player player;

  List<String> queue = [];
  SetStateFunction setState;
  List<String> songNames;
  Timer? timer;
  String? currentArtist;

  NextSongTimer(
      {required this.currentSong,
      this.currentArtist,
      required this.songNames,
      required this.player,
      required this.setState});

  void startTimer(Duration time) {
    timer?.cancel();
    timer = Timer.periodic(time, playNextSong);
  }

  void stopTimer() {
    timer?.cancel();
  }

  void playNextSong(Timer timer) async {
    String filePath = "storage/emulated/0/Download/$currentSong.mp3";
    final Map? audiomap = await tagger.readAudioFileAsMap(path: filePath);
    int length = audiomap!['length'];

    int position = player?.isLoaded() == true ? (await player!.position()) : 0;

    if (((position / 1000) + 1) >= length) {
      if (queue.isNotEmpty) {
        String filePathQueue = "storage/emulated/0/Download/${queue[0]}.mp3";
        final Map? map = await tagger.readTagsAsMap(path: filePathQueue);
        await player.load(filePathQueue);
        await player.play();
        setState(() {
          currentSong = queue[0];
          currentArtist = map?["artist"];
        });
        print("_MyHomePageState.playNextSong currentSong = $currentSong");
        queue.removeAt(0);
      } else {
        final _random = Random();
        String newSong = songNames[_random.nextInt(songNames.length)];
        String filePath = "storage/emulated/0/Download/$newSong.mp3";
        final Map? map = await tagger.readTagsAsMap(
            path: filePath);
        await player.load(filePath);
        await player.play();
        print('player.dispose ${player?.hashCode}');
        setState(() {
          currentSong = newSong;
          currentArtist = map?["artist"];
        });
        print("_MyHomePageState.playNextSong currentSong = $currentSong");
      }
    }
  }

  addToQueue(songName) {
    queue.add(songName);
  }
}

class Player {
  OcarinaPlayer? currentPlayer;
  OcarinaPlayer? pendingPlayer;
  Future<void> load(filePath) {
    pendingPlayer = OcarinaPlayer(filePath: filePath);
    return pendingPlayer?.load() ?? Future.value(null);
  }
  Future<void> play(){
    if (pendingPlayer != null) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        
      }
      currentPlayer = pendingPlayer;
      pendingPlayer = null;

    }
    return currentPlayer?.play()  ?? Future.value(null);
  }
  Future<void> pause(){
    return currentPlayer?.pause() ?? Future.value(null);
  }
  void dispose() {
    currentPlayer?.dispose();
    currentPlayer = null;
    pendingPlayer?.dispose();
    pendingPlayer = null;
  }
  Future<int> position() {
    return currentPlayer?.position() ?? Future.value(0);
  }
  bool isLoaded() {
    return currentPlayer?.isLoaded() ?? false;
  }
  Future<void> seek(Duration duration) {
    return currentPlayer?.seek(duration) ?? Future.value(null);
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/optionpage.dart';
import 'package:music_player/player.dart';
import 'package:music_player/playpausebutton.dart';
import 'package:music_player/tagger.dart';
import 'package:music_player/taize_song_provider.dart';
import 'package:music_player/types.dart';
import 'config.dart';
import 'playerwidget.dart';

typedef BoolConsumer = void Function(bool value);
typedef SetStateFunction = void Function(void Function() fn);
void main() async {
  runApp(FutureBuilder<Iterable<SongData>>(
      future: taizeSongs,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? MyApp(
                player: Player(),
                songs: snapshot.data!,
                tagger: AudioTagger.instance,
              )
            : CircularProgressIndicator();
      }));
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  Iterable<SongData> songs;
  final Player player;
  final AudioTagger tagger;
  MyApp(
      {Key? key,
      required this.songs,
      required this.player,
      required this.tagger})
      : super(key: key);

  // This widget is the root of your application.

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: currentTheme.currentTheme(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Home',
        songs: widget.songs,
        player: widget.player,
        tagger: widget.tagger,
      ),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final Player player;
  final AudioTagger tagger;
  MyHomePage(
      {Key? key,
      required this.title,
      required this.songs,
      required this.player,
      required this.tagger})
      : super(key: key);
  Iterable<SongData> songs;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SlidableController slidableController = SlidableController();
  Player get player => widget.player;
  bool? playing;
  SongData? get currentSong => nextSongTimer?.currentSong;
  String? get currentArtist => nextSongTimer?.currentArtist;
  AudioTagger get tagger => widget.tagger;

  NextSongTimer? nextSongTimer;

  void setPlaying(bool value) {
    setState(() {
      playing = value;
    });
  }

  @override
  initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
    nextSongTimer = NextSongTimer(
        currentSong: null,
        currentArtist: null,
        player: Player(),
        songs: widget.songs,
        setState: setState,
        tagger: tagger);
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

    if (player.isLoaded()) {
      return SizedBox(
        width: double.infinity,
        height: 91,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: currentTheme.currentTheme() == ThemeMode.dark ? Colors.black : Colors.grey[300],),
          child: GestureDetector(
            onTap: () {
              nextSongTimer?.stopTimer();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerWidget(
                          playing: playing!,
                          player: player,
                          currentArtist: currentArtist ?? '',
                          currentSong: currentSong!,
                          setPlaying: setPlaying,
                          tagger: tagger,
                        )),
              );
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 0, right: 8),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          child:
                              Image.network(currentSong!.coverUri.toString()),
                          /*
                          child: FutureBuilder<Widget>(
                            future:
                                getArtwork(currentSong!.songUri.toFilePath()),
                            builder: (BuildContext context,
                                AsyncSnapshot<Widget> snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                          */
                          decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) async {
                        // Swiping in right direction.
                        if (details.delta.dx > 0) {}

                        // Swiping in left direction.
                        if (details.delta.dx < 0) {
                          /*await NextSongTimer(
                            currentSong: currentSong,
                            currentArtist: currentArtist,
                            player: player,
                            songs: widget.songs,
                            setState: setState,
                            tagger: tagger,
                          ).skipSong();
                          print('NextSongTimer.skipSong skipped Song');
                          print(
                              "NextSongTimer currentsong = ${currentSong!.title}");*/
                        }
                      },
                      child: SizedBox(
                        height: 75,
                        width: size.width * 0.48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 25,
                              child: songNameLength(currentSong!.title),
                            ),
                            SizedBox(
                              height: 22,
                              child: artistNameLength(currentArtist ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: PlayPauseButtonWidget(
                        player: player,
                        playing: playing!,
                        size: 32,
                        setPlaying: setPlaying,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.deepPurple,
                    inactiveTrackColor: Colors.deepPurpleAccent,
                    trackShape: const RoundedRectSliderTrackShape(),
                    trackHeight: 5.0,
                    thumbColor: Colors.purple,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 8.0),
                  ),
                  child: FutureBuilder<Duration>(
                      future: currentSong!.songDuration,
                      // getSongDuration(currentSong!.songUri.toFilePath()),
                      builder: (context, snapshot) {
                        return PositionSliderWidget(
                            maxPosition: snapshot.hasData
                                ? snapshot.data!.inSeconds
                                : 20,
                            player: player);
                      }),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainOptionMenuWidget(
                              player: widget.player,
                            )),
                  );
                },
                child: const Icon(Icons.more_vert),
              )),
        ],
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
                itemCount: widget.songs.length,
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
                          nextSongTimer?.addToQueue(widget.songs.elementAt(index));
                          
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
                        title: Text(widget.songs.elementAt(index).title),
                        leading: CircleAvatar(
                          child: Center(
                            child: Image.network(widget.songs
                                .elementAt(index)
                                .coverUri
                                .toString()),
                            /*
                            FutureBuilder<Widget>(
                              future: getArtwork(widget.songs.elementAt(index).songUri.toFilePath()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Widget> snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                }

                                return const CircularProgressIndicator();
                              },
                            ),
                            */
                          ),
                        ),
                        onTap: () async {
                          /*
                          final String filePath =
                              widget.songs.elementAt(index).songUri.toFilePath();
                          final Map? map =
                              await tagger.readTagsAsMap(path: filePath);
                          */
                          final uri = widget.songs.elementAt(index).songUri;
                          /*
                          if(uri.toString().endsWith('.mid')) {
                            print('onTap: downloading $uri ...');
                            final file = await DefaultCacheManager().getSingleFile(uri.toString());
                            print('onTap: downloaded to ${file.absolute}');
                          }
                          */
                          final duration =
                              await widget.songs.elementAt(index).songDuration;
                          await player.load(uri);
                          player.play();
                          nextSongTimer?.stopTimer();
                          setState(() {
                            nextSongTimer = NextSongTimer(
                              currentSong: widget.songs.elementAt(index),
                              currentArtist: null, // map?["artist"],
                              player: player,
                              songs: widget.songs,
                              setState: setState,
                              tagger: tagger,
                            );
                            setPlaying(true);
                          });
                          nextSongTimer
                              ?.startTimer(const Duration(milliseconds: 500));
                          print("");

                          print("MyHomePageState Song Duration = $duration");
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
      bottomNavigationBar: widget.player.youtubeWidget,
    );
  }

  Future<Widget> getArtwork(String songName) async {
    Widget artwork;
    final String filePath = songName;
    final output = await tagger.readArtwork(path: filePath);
    artwork = output != null
        ? Image.memory(output)
        : const Icon(
            Icons.music_note,
          );
    return artwork;
  }

  Future<double> getSongDuration(String songName) async {
    final String filePath = songName;
    final map = await tagger.readAudioFileAsMap(path: filePath);
    int output = map?['length'];
    return output.toDouble();
  }
}

class NextSongTimer {
  SongData? currentSong;

  Player player;

  List<SongData> queue = [];
  SetStateFunction setState;
  Iterable<SongData> songs;
  Timer? timer;
  String? currentArtist;
  AudioTagger tagger;

  NextSongTimer({
    required this.currentSong,
    this.currentArtist,
    required this.songs,
    required this.player,
    required this.setState,
    required this.tagger,
  });

  void startTimer(Duration time) {
    timer?.cancel();
    // timer = Timer.periodic(time, playNextSong);
  }

  void stopTimer() {
    timer?.cancel();
  }

  void playNextSong(Timer timer) async {
    String filePath = currentSong!.songUri.toFilePath();
    final Map? audiomap = await tagger.readAudioFileAsMap(path: filePath);
    int length = audiomap!['length'];
    int position = player.isLoaded() == true ? (await player.position()) : 0;

    if (((position / 1000) + 1) >= length) {
      if (queue.isNotEmpty) {
        String filePathQueue = queue[0].songUri.toFilePath();
        final Map? map = await tagger.readTagsAsMap(path: filePathQueue);
        await player.load(queue[0].songUri);
        await player.play();
        setState(() {
          currentSong = queue[0];
          currentArtist = map?["artist"];
        });
        queue.removeAt(0);
      } else {
        final index = Random().nextInt(songs.length);
        SongData newSong = songs.elementAt(index);
        Uri uri = newSong.songUri;
        final Map? map = await tagger.readTagsAsMap(path: uri.toFilePath());
        await player.load(uri);
        await player.play();
        setState(() {
          currentSong = newSong;
          currentArtist = map?["artist"];
        });
      }
    }
  }

  Future<void> skipSong() async {
    print('NextSongTimer.skipSong queue $queue');
    if (queue.isNotEmpty) {
      print('NextSongTimer.skipSong queue not Empty');
      String filePathQueue = queue[0].songUri.toFilePath();
      final Map? map = await tagger.readTagsAsMap(path: filePathQueue);
      await player.load(queue[0].songUri);
      await player.play();
      setState(() {
        currentSong = queue[0];
        print('currentSong: ${currentSong?.title}');
        currentArtist = map?["artist"];
      });
      print("NextSongTimer.skipSong Queue = $queue");
      queue.removeAt(0);
    } else {
      print('NextSongTimer.skipSong queue is empty');
      final index1 = Random().nextInt(songs.length);
      print('NextSongTimer.skipSong index = $index1');
      SongData newSong = songs.elementAt(index1);
      print('NextSongTimer.skipSong newSong = ${newSong.title}');
      Uri uri = newSong.songUri;
      final Map? map = await tagger.readTagsAsMap(path: uri.toString());
      setState(() {
        currentSong = newSong;
        print('currentSong: ${currentSong?.title}');
        currentArtist = map?["artist"];
      });
      await player.load(uri);
      await player.play();
    }
  }

  addToQueue(songName) {
    queue.add(songName);
    print("queue = ${queue.asMap()}");
  }
}

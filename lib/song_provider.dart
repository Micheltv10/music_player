import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:music_player/tagger.dart';
import 'package:music_player/types.dart';

import 'midi/midi_events.dart';
import 'midi/midi_file.dart';
import 'midi/midi_parser.dart';

extension StringUriExtension on String {
  Uri get uri => Uri.parse(this);
}

extension MidiFileExtension on MidiFile {
    static int getSumOfDeltaTicks(List<MidiEvent> events) {
    return  events.fold(0, foldEventsToTickSum);
  }
  static int foldEventsToTickSum(int previousValue, MidiEvent event) {
    return previousValue + event.deltaTime;
  }

  static int foldTracksToMaxTicks(int previousValue, List<MidiEvent> track) {
    return max(previousValue, getSumOfDeltaTicks(track));
  }
  Duration get duration {
      int beatsPerMinute = 120;
      int ticks = this.tracks.fold(0, foldTracksToMaxTicks);
      int ticksPerBeat = this.header.ticksPerBeat ?? 192;
      double beats = ticks / ticksPerBeat;
      double minutes = beats * beatsPerMinute;
      return Duration(minutes: minutes.toInt());
  
  }
}

class Locales {
  static Locale de = Locale('de');
  static Locale fr = Locale('fr');
  static Locale und = Locale('und');
}

class NetworkSongProvider extends SongProvider {

  static Future<List<int>> readResponse(HttpClientResponse response) {
  final completer = Completer<List<int>>();
  final contents = <int>[];
  response.listen((data) {
    contents.addAll(data);
  }, onDone: () => completer.complete(contents));
  return completer.future;
}
  static Future<Duration> provideMidiDuration(Uri uri) async {
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    final parser = MidiParser();
    final content = await readResponse(response);
    final midiFile = parser.parseMidiFromBuffer(content);
    return Future.value(midiFile.duration);
  }

  static Future<Duration> provideYoutubeDuration(Uri uri) {
    return Future.value(Duration(seconds: 100));
  }

  static Future<Duration> provideMp3Duration(Uri uri, AudioTagger tagger) async {
  final String filePath = uri.toFilePath();
  final Map map = await tagger.readAudioFileAsMap(path: filePath) ?? {};
  final length = map.containsKey('length') == true ? map['length'] as int : 100;
  return Duration(seconds: length);  }

  NetworkSongProvider(AudioTagger tagger)
      : super(Future.value([
          SongData(
            index: 0,
            title: 'Dans nos obscurités',
            subtitle: 'Alleluia',
            audios: [
              AudioData(
                durationProvider: (audio) => provideYoutubeDuration(audio.uri),
                kind: AudioKind.song,
                locale: Locales.fr,
                name: 'song',
                uri: 'https://www.youtube.com/watch?v=pfin1W0v7Ts'.uri,
              ),
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.soprano,
                locale: Locales.und,
                name: 'soprano',
                uri: 'https://www.taize.fr/IMG/mid/danobs_s.mid'.uri,
              ),
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.guitar,
                locale: Locales.und,
                name: 'guitar',
                uri: 'https://www.taize.fr/IMG/mid/danobs_g.mid'.uri,
              ),
              AudioData(
                durationProvider: (audio) => provideMp3Duration(audio.uri, tagger),
                kind: AudioKind.pronunciation,
                locale: Locales.fr,
                name: 'pronunciation',
                uri: 'https://taize.ulinater.de/french/dans_nos_obscurites.mp3'
                    .uri,
              ),
            ],
            images: [
              ImageData(
                kind: ImageKind.notes,
                name: 'notes',
                uri: 'https://www.taize.fr/IMG/gif/dans_nos_obscurites.gif'.uri,
              ),
              ImageData(
                kind: ImageKind.cover,
                name: 'cover',
                uri:
                    'https://img.discogs.com/cepNOlDOJGHeO4AtaS-BsaykXsI=/fit-in/600x598/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-8770045-1595973508-2049.jpeg.jpg'
                        .uri,
              ),
            ],
            texts: [
              TextData(
                  locale: Locales.fr,
                  kind: TextKind.lyrics,
                  name: 'lyrics',
                  uri: 'assets://lyrics/dans_nos_obscurites.txt'.uri),
              TextData(
                  locale: Locales.fr,
                  kind: TextKind.phonetics,
                  name: 'lyrics',
                  uri: 'assets://lyrics/dans_nos_obscurites.phonetics'.uri),
              TextData(
                  locale: Locales.de,
                  kind: TextKind.translation,
                  name: 'translation',
                  uri: 'assets://lyrics/dans_nos_obscurites.de.translation'.uri),
            ],
          ),
        ]));
}

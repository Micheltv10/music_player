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
    return events.fold(0, foldEventsToTickSum);
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
  static const Locale de = Locale('de');
  static const Locale en = Locale('en');
  static const Locale fr = Locale('fr');
  static const Locale und = Locale('und');
}

class NetworkSongData extends SongData {
  NetworkSongData({
    required AudioTagger tagger,
    required int index,
    required String title,
    String? album,
    String? youtubeId,
    Duration? duration,
    Locale locale = Locales.und,
    String? soprano,
    String? alto,
    String? tenor,
    String? bass,
    String? together,
    String? guitar,
    String? lyrics,
    String? phonetics,
    String? translation,
    String? pronunciation,
    String? notes,
    String? cover,
  }) : super(
          index: index,
          title: title,
          subtitle: album ?? '',
          audios: [
            if (youtubeId != null)
              AudioData(
                durationProvider: (_) =>
                    Future.value(duration ?? Duration.zero),
                kind: AudioKind.song,
                locale: locale,
                name: title,
                uri: 'https://www.youtube.com/watch?v=$youtubeId'.uri,
              ),
            if (soprano != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.soprano,
                locale: Locales.und,
                name: 'soprano',
                uri: soprano.uri,
              ),
            if (alto != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.alto,
                locale: Locales.und,
                name: 'alto',
                uri: alto.uri,
              ),
            if (tenor != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.tenor,
                locale: Locales.und,
                name: 'tenor',
                uri: tenor.uri,
              ),
            if (bass != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.bass,
                locale: Locales.und,
                name: 'bass',
                uri: bass.uri,
              ),
            if (together != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.together,
                locale: Locales.und,
                name: 'together',
                uri: together.uri,
              ),
            if (guitar != null)
              AudioData(
                durationProvider: (audio) => provideMidiDuration(audio.uri),
                kind: AudioKind.guitar,
                locale: Locales.und,
                name: 'guitar',
                uri: guitar.uri,
              ),
            if (pronunciation != null)
              AudioData(
                durationProvider: (audio) =>
                    provideMp3Duration(audio.uri, tagger),
                kind: AudioKind.guitar,
                locale: Locales.und,
                name: 'pronunciation',
                uri: pronunciation.uri,
              ),
          ],
          texts: [
            if (lyrics != null)
              TextData(
                kind: TextKind.lyrics,
                name: 'lyrics',
                uri: lyrics.uri,
                locale: locale,
              ),
            if (phonetics != null)
              TextData(
                kind: TextKind.phonetics,
                name: 'phonetics',
                uri: phonetics.uri,
                locale: locale,
              ),
            if (translation != null)
              TextData(
                kind: TextKind.translation,
                name: 'translation',
                uri: translation.uri,
                locale: Locales.de,
              )
          ],
          images: [
            if (cover != null)
              ImageData(
                kind: ImageKind.cover,
                name: 'cover',
                uri: cover.uri,
              ),
            if (notes != null)
              ImageData(
                kind: ImageKind.notes,
                name: 'notes',
                uri: notes.uri,
              )
          ],
        );

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

  static Future<Duration> provideMp3Duration(
      Uri uri, AudioTagger tagger) async {
    final String filePath = uri.toFilePath();
    final Map map = await tagger.readAudioFileAsMap(path: filePath) ?? {};
    final length =
        map.containsKey('length') == true ? map['length'] as int : 100;
    return Duration(seconds: length);
  }
}

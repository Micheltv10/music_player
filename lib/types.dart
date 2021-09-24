import 'dart:ui';

enum ImageKind {
  cover,
  notes,
  artist,
}

enum AudioKind {
  pronunciation,
  accompaniment,
  song,
  firstVoice,
  secondVoice,
  thirdVoice,
  guitar
}

enum TextKind {
  lyrics,
  phonetics,
  translation,
}
typedef DurationProvider = Future<Duration> Function();
class AudioData {
  final AudioKind kind;
  final String name;
  final Uri uri;
  final Locale locale;
  Future<Duration> get duration => durationProvider();
  final DurationProvider durationProvider; 

  AudioData({required this.durationProvider, required this.kind, required this.locale, required this.name, required this.uri});
}

class TextData {
  final TextKind kind;
  final String name;
  final Uri uri;
  final Locale locale;

  TextData({required this.locale, required this.kind, required this.name, required this.uri});
}

class ImageData {
  final ImageKind kind;
  final String name;
  final Uri uri;

  ImageData({required this.kind, required this.name, required this.uri});
}
class SongData {
  final int index;
  final String title;
  final String subtitle;
  final List<AudioData> audios;
  final List<ImageData> images;
  final List<TextData> texts;
  Uri get songUri => audios.singleWhere((audio) => audio.kind == AudioKind.song).uri;

  SongData({required this.index, required this.subtitle, required this.audios, required this.images, required this.texts, required this.title});
}

typedef  SongComparator = int Function(SongData left, SongData right);
class SongComparators {
    static int compareAscendingByTitle(SongData left, SongData right) => left.title.compareTo(right.title);
    static int compareDescendingByTitle(SongData left, SongData right) => right.title.compareTo(left.title);
    static int compareAscendingByIndex(SongData left, SongData right) => left.index.compareTo(right.index);
    static int compareDescendingByIndex(SongData left, SongData right) => right.index.compareTo(left.index);
    static int compareNothing(SongData left, SongData right) => 0;
}

abstract class SongPredicate {
  bool test(SongData value);
}

class TitlePredicate implements SongPredicate {
  final RegExp regExp;
  TitlePredicate(this.regExp);
  @override
  bool test(SongData input) {
    return regExp.hasMatch(input.title);
  }

}
class SongLocalePredicate implements SongPredicate {
  final Locale locale;
  SongLocalePredicate(this.locale);
  @override
  bool test(SongData input) {
    return input.audios.where((audio) => audio.kind == AudioKind.song && audio.locale == locale).isNotEmpty;
  }
}
class AndPredicate implements SongPredicate {
  final Iterable<SongPredicate> predicates;
  AndPredicate(this.predicates);
  @override
  bool test(SongData value) {
    return predicates.fold(true, (previousValue, predicate) => previousValue && predicate.test(value));
  }
}
class OrPredicate implements SongPredicate {
  final Iterable<SongPredicate> predicates;
  OrPredicate(this.predicates);
  @override
  bool test(SongData value) {
    return predicates.fold(false, (previousValue, predicate) => previousValue || predicate.test(value));
  }
}
class TruePredicate implements SongPredicate {
  const TruePredicate();
  @override
  bool test(SongData value) {
    return true;
  }
  static const instance = TruePredicate(); 
}
class SongProvider {
  final Iterable<SongData> songs;
  SongProvider(this.songs);
  Iterable<SongData> filterAndSort({
    SongPredicate predicate=TruePredicate.instance, 
    SongComparator comparator=SongComparators.compareNothing,
    }) {
      return songs.where((song) => predicate.test(song)).toList()..sort(comparator);
  }
}
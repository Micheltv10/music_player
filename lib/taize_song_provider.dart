import 'package:music_player/song_provider.dart';
import 'package:music_player/tagger.dart';

import 'types.dart';

final taizeSongs = SongProvider(
          Future.value(
            [
              NetworkSongData(
                tagger: AudioTagger.instance,
                index: 1,
                title: 'Dans nos obscurités',
                album: 'Alleluia',
                locale: Locales.fr,
                youtubeId: 'pfin1W0v7Ts',
                duration: Duration(seconds: 240),
                soprano: 'https://www.taize.fr/IMG/mid/danobs_s.mid',
                alto: 'https://www.taize.fr/IMG/mid/danobs_a.mid',
                tenor: 'https://www.taize.fr/IMG/mid/danobs_t.mid',
                bass: 'https://www.taize.fr/IMG/mid/danobs_b.mid',
                together: 'https://www.taize.fr/IMG/mid/danobs_e.mid',
                guitar: 'https://www.taize.fr/IMG/mid/danobs_g.mid',
                pronunciation:
                    'https://taize.ulinater.de/french/dans_nos_obscurites.mp3',
                notes: 'https://www.taize.fr/IMG/gif/dans_nos_obscurites.gif',
                cover:
                    'https://img.discogs.com/cepNOlDOJGHeO4AtaS-BsaykXsI=/fit-in/600x598/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-8770045-1595973508-2049.jpeg.jpg',
                lyrics: 'assets://lyrics/dans_nos_obscurites.txt',
                phonetics: 'assets://lyrics/dans_nos_obscurites.phonetics',
                translation:
                    'assets://lyrics/dans_nos_obscurites.translation',
              ),
              NetworkSongData(
                tagger: AudioTagger.instance,
                index: 2,
                title: 'Wait for the Lord',
                album: 'Joy on Earth',
                locale: Locales.en,
                youtubeId: 'bt2ifr8O1pM',
                duration: Duration(seconds: 240),
                soprano: 'https://www.taize.fr/IMG/mid/wait_s.mid',
                alto: 'https://www.taize.fr/IMG/mid/wait_a.mid',
                tenor: 'https://www.taize.fr/IMG/mid/wait_t.mid',
                bass: 'https://www.taize.fr/IMG/mid/wait_b.mid',
                together: 'https://www.taize.fr/IMG/mid/wait_e.mid',
                guitar: 'https://www.taize.fr/IMG/mid/wait_g.mid',
                pronunciation:
                    'https://taize.ulinater.de/english/wait_for_the_lord.mp3',
                notes: 'https://www.taize.fr/IMG/png/wait.png',
                cover:
                    'https://img.discogs.com/4Ro2E6YC_w4ILcmL4Su389OUIkw=/fit-in/300x295/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-7911816-1451497677-4617.jpeg.jpg',
                lyrics: 'assets://lyrics/wait_for_the_lord.txt',
                phonetics: 'assets://lyrics/wait_for_the_lord.phonetics',
                translation:
                    'assets://lyrics/wait_for_the_lord.translation',
              ),
            ],
          ),
        ).songs;


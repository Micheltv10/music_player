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
        album: 'Chants de la prière à Taizé',
        locale: Locales.fr,
        youtubeId: 'pfin1W0v7Ts',
        duration: Duration(minutes: 4, seconds: 13),
        soprano: 'https://www.taize.fr/IMG/mid/danobs_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/danobs_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/danobs_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/danobs_b.mid',
        together: 'http://54.36.216.225/IMG/mid/danobs_e.mid',
        guitar: 'http://54.36.216.225/IMG/mid/danobs_g.mid',
        pronunciation:
            'https://taize.ulinater.de/french/dans_nos_obscurites.mp3',
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',
        // notes: 'https://www.taize.fr/IMG/gif/dans_nos_obscurites.gif',
        cover:
            'https://img.discogs.com/jKkS4jDz-vB9coVXp_PYb3II4Cw=/fit-in/600x595/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-8108211-1455294603-9187.jpeg.jpg',
        lyrics: [
          'Dans nos obscurités,',
          'allume le feu',
          "qui ne s'éteint jamais,",
          "qui ne s'éteint jamais.",
        ],
        phonetics: [
          'dɑ̃ noz‿ ɔpskyʁite',
          'alym lə fø',
          'ki nə setɛ̃ ʒamɛ',
          'ki nə setɛ ʒamɛ'
        ],
        translation: [
          'Im Dunkel unsrer Nacht,',
          'entzünde das Feuer,',
          'das nie mehr erlischt,',
          'das nie mehr erlischt.',
        ],
      ),
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 2,
        title: 'Wait for the Lord',
        album: 'Joy on Earth',
        locale: Locales.en,
        youtubeId: 'bt2ifr8O1pM',
        duration: Duration(minutes: 4, seconds: 23),
        soprano: 'https://www.taize.fr/IMG/mid/wait_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/wait_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/wait_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/wait_b.mid',
        together: 'https://www.taize.fr/IMG/mid/wait_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/wait_g.mid',
        pronunciation:
            'https://taize.ulinater.de/english/wait_for_the_lord.mp3',
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',
        // notes: 'https://www.taize.fr/IMG/png/wait.png',
        cover:
            'https://img.discogs.com/4Ro2E6YC_w4ILcmL4Su389OUIkw=/fit-in/300x295/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-7911816-1451497677-4617.jpeg.jpg',
        lyrics: [
          'Wait for the Lord,',
          'Whose day is near.',
          'Wait for the Lord:',
          'Keep watch, take heart!',
        ],
        phonetics: [
          'weɪt fɔː ðə lɔːd,',
          'huːz deɪ ɪz nɪə.',
          'weɪt fɔː ðə lɔːd:',
          'kiːp wɒʧ, teɪk hɑːt!',
        ],
        translation: [
          'Nah ist der Herr,',
          'es kommt sein Tag.',
          'Nah ist der Herr,',
          'habt Mut, bleibt wach.',
        ],
      ),
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 3,
        title: 'Bleibet hier',
        album: 'Laudate omnes gentes',
        locale: Locales.de,
        youtubeId: 'b7FPEylyVH8',
        duration: Duration(minutes: 4, seconds: 26),
        soprano: 'https://www.taize.fr/IMG/mid/bleihi_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/bleihi_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/bleihi_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/bleihi_b.mid',
        together: 'https://www.taize.fr/IMG/mid/bleihi_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/bleihi_g.mid',
        pronunciation: 'https://taize.ulinater.de/german/bleibet_hier.mp3',
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',

        // notes: 'https://www.taize.fr/IMG/gif/bleibet_hier.gif',
        cover:
            'https://img.discogs.com/78t3rAXrRwGdbCJQlw75y1UdLfs=/fit-in/600x594/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-13293107-1551538825-2290.jpeg.jpg',
        lyrics: [
          'Bleibet hier',
          'und wachet mit mir.',
          'Wachet und betet.',
          'Wachet und betet.',
        ],
        phonetics: [
          'Blaɪ̯bət hiːɐ̯',
          'ʊnt wachet mɪt miːɐ̯.',
          'vaxət ʊnt beːtət.',
          'vaxət ʊnt beːtət.',
        ],
      ),
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 4,
        title: 'Ubi Caritas Deus ibi est',
        album: 'Auf Dich Vertrau Ich',
        locale: Locales.la,
        youtubeId: 'yK5XHSEgWqs',
        duration: Duration(minutes: 4, seconds: 17),
        soprano: 'https://www.taize.fr/IMG/mid/ubideu_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/ubideu_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/ubideu_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/ubideu_b.mid',
        together: 'https://www.taize.fr/IMG/mid/ubideu_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/ubideu_g.mid',
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',

        // notes: 'https://www.taize.fr/IMG/png/ubideu.png',
        cover:
            'https://img.discogs.com/lO41iQZKLdTZpTv6nmvpXGdt08Y=/fit-in/600x588/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-10853980-1506858813-7951.jpeg.jpg',
        lyrics: [
          'Ubi Caritas et Amor,',
          'Ubi Caritas, Deus ibi est.',
        ],
        translation: ['Wo die Güte und die Liebe,', 'Wo die Güte, da ist Gott'],
      ),
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 131,
        title: 'Cantarei ao Senhor',
        album: 'Christe Lux Mundi',
        locale: Locales.pt,
        youtubeId: 'HBQkgtySUQM',
        duration: Duration(minutes: 3, seconds: 42),
        firstVoice: 'https://www.taize.fr/IMG/mid/cantarei_ao_s_1.mid',
        secondVoice: 'https://www.taize.fr/IMG/mid/cantarei_ao_s_2.mid',
        thirdVoice: 'https://www.taize.fr/IMG/mid/cantarei_ao_s_3.mid',
        together: 'https://www.taize.fr/IMG/mid/cantarei_ao_s_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/cantarei_ao_s_g.mid',
        pronunciation:
            'https://taize.ulinater.de/portuguese/cantarei_ao_senhor.mp3',
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',
        // notes: 'https://www.taize.fr/IMG/gif/cantarei_ao_senhor.gif',
        cover:
            'https://img.discogs.com/37X2jHoPeLfsM1y3xQJDLFOMV-I=/fit-in/600x591/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-12298902-1532603248-1045.png.jpg',
        lyrics: [
          'Cantarei ao Senhor,',
          'enquanto viver,',
          'louvarei o meu Deus',
          'enquanto existir.',
          'Nele encontro a minha alegria.',
          'Nele encontro a minha alegria.',
        ],
        phonetics: [
          'kɐ̃tɐˈɾɐj ɐu sɨˈɲɔɾ',
          'ẽˈkwɐ̃tu viˈveɾ',
          'lovɐˈɾɐj u ˈmew ˈdewʃ',
          'ẽˈkwɐ̃tu iziˈʃtiɾ',
          'ˈnɛlɨ ẽˈkõtɾu ɐ ˈmiɲɐ ɐlɨˈɡɾiɐ',
          'ˈnɛlɨ ẽˈkõtɾu ɐ ˈmiɲɐ ɐlɨˈɡɾiɐ',
        ],
        translation: [
          'Ich werde dem Herrn singen',
          'so lange ich lebe,',
          'Ich werde meinen Gott preisen',
          'so lange ich existiere.',
          'In ihm finde ich meine Freude.',
          'In ihm finde ich meine Freude.',
        ],
      ),
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 51,
        title: 'Dieu ne peut que donner son amour',
        locale: Locales.fr,
        album: 'Chants de la prière à Taizé',
        cover:
            'https://img.discogs.com/jKkS4jDz-vB9coVXp_PYb3II4Cw=/fit-in/600x595/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-8108211-1455294603-9187.jpeg.jpg',
        youtubeId: 'IcHomdR_w6k',
        duration: const Duration(minutes: 4, seconds: 1),
        notes: 'https://via.placeholder.com/1000x1000?text=No+Notes+Found',

        // notes: 'https://www.taize.fr/IMG/gif/dieu_ne_peut_que_donner.gif',
        soprano: 'https://www.taize.fr/IMG/mid/dieunp_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/dieunp_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/dieunp_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/dieunp_b.mid',
        together: 'https://www.taize.fr/IMG/mid/dieunp_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/dieunp_g.mid',
        pronunciation:
            'https://taize.ulinater.de/french/dieu_ne_peut_que_donner.mp3',
        lyrics: [
          'Dieu ne peut que donner son amour,',
          'notre Dieu est tendresse',
          '',
          'Benis le Seigneur ô mon âme,',
          'et du fond de mon être son saint nom.',
          '𝄆 Dieu est tendresse 𝄇',
          'Benis le Seigneur ô mon âme,',
          'nˈoublie aucun de ses biens faits.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Dieu ne peut que donner son amour,',
          'notre Dieu est tendresse',
          '',
          'Lui qui pardonne toutes tes offenses,',
          'qui te guérit de toute maladie.',
          '𝄆 Dieu est tendresse 𝄇',
          'Qui rachète à la fosse ta vie,',
          'Qui te couronne dˈamour et de tendresse.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Dieu ne peut que donner son amour,',
          'notre Dieu est tendresse',
          '',
          'Le Seigneur est tendresse et toute grâce,',
          'Le Seigneur deborde dˈamour.',
          '𝄆 Dieu est tendresse 𝄇',
          'Il nˈagit pas envers nous selon nos fautes,',
          'ne nous rends pas selon nos offenses.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Dieu ne peut que donner son amour,',
          'notre Dieu est tendresse',
          '',
          'Comme est la hauteur des cieux sur la terre,',
          'puissant est son amour pour qui lˈadore.',
          '𝄆 Dieu est tendresse 𝄇',
          'comme est loin lˈOrient de lˈOccident,',
          'il éloigne de nous nos péchés.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Dieu ne peut que donner son amour,',
          'notre Dieu est tendresse!',
        ],
        phonetics: [
          'djø nə pø kə dɔne sɔ̃n‿ amuʁ',
          'nɔtʁə djø ɛ tɑ̃dʁɛs',
          '',
          'bəni lə sɛɲœʁ‿ o mɔ̃n‿ am',
          'e dy fɔ̃ də mɔ̃n‿ ɛtʁə sɔ̃ sɛ̃ nɔ̃',
          '𝄆 djø ɛ tɑ̃dʁɛs 𝄇',
          'bəni lə sɛɲœʁ‿ o mɔ̃n‿ am',
          'nubli okɛ̃ də se bjɛ̃ fɛ',
          '𝄆 djø ki paʁdɔn 𝄇',
          '',
          'djø nə pø kə dɔne sɔ̃n‿ amuʁ',
          'nɔtʁə djø ɛ tɑ̃dʁɛs',
          '',
          'lɥi ki paʁdɔn tut tez‿ ɔfɑ̃s',
          'ki tə ɡeʁi də tut maladi',
          '𝄆 djø ɛ tɑ̃dʁɛs 𝄇',
          'ki ʁaʃɛt‿ a la fos ta vi',
          'ki tə kuʁɔn damuʁ‿ e də tɑ̃dʁɛs',
          '𝄆 djø ki paʁdɔn 𝄇',
          '',
          'djø nə pø kə dɔne sɔ̃n‿ amuʁ',
          'nɔtʁə djø ɛ tɑ̃dʁɛs',
          '',
          'lə sɛɲœʁ‿ ɛ tɑ̃dʁɛs‿ e tut ɡʁas',
          'lə sɛɲœʁ dəbɔʁdə damuʁ',
          '𝄆 djø ɛ tɑ̃dʁɛs 𝄇',
          'il naʒi pa ɑ̃vɛʁ nu səlɔ̃ no fot',
          'nə nu ʁɑ̃ pa səlɔ̃ noz‿ ɔfɑ̃s',
          '𝄆 djø ki paʁdɔn 𝄇',
          '',
          'djø nə pø kə dɔne sɔ̃n‿ amuʁ',
          'nɔtʁə djø ɛ tɑ̃dʁɛs',
          '',
          'kɔm‿ ɛ la otœʁ de sjø syʁ la tɛʁ',
          'pɥisɑ̃ ɛ sɔ̃n‿ amuʁ puʁ ki ladɔʁ',
          '𝄆 djø ɛ tɑ̃dʁɛs 𝄇',
          'kɔm‿ ɛ lwɛ̃ lɔʁi də lɔksid',
          'il‿ elwaɲ də nu no peʃe',
          '𝄆 djø ki paʁdɔn 𝄇',
          '',
          'djø nə pø kə dɔne sɔ̃n‿ amuʁ',
          'nɔtʁə djø ɛ tɑ̃dʁɛs',
        ],
        translation: [
          'Gott kann nur seine Liebe schenken.',
          'Unser Gott ist voll zärtlicher Zuneigung.',
          '',
          'Lobe den Herm meine Seele,',
          'und alles in mir seinen heiligen Namen.',
          '𝄆 Dieu est tendresse 𝄇',
          'Lobe den Herrn meine Seele,',
          'und vergiß nicht, was er dir Gutes getan hat.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Gott kann nur seine Liebe schenken.',
          'Unser Gott ist voll zärtlicher Zuneigung.',
          '',
          'Der dir all deine Schuld vergibt',
          'und all deine Gebrechen heilt.',
          '𝄆 Dieu est tendresse 𝄇',
          'Der dich mit seinen Gaben sättigt,',
          'und dich mit Huld und Erbarmen krönt.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Gott kann nur seine Liebe schenken.',
          'Unser Gott ist voll zärtlicher Zuneigung.',
          '',
          'Der Herr ist barmherzig und gnädig,',
          'langmütig und reich an Güte.',
          '𝄆 Dieu est tendresse 𝄇',
          'Er handelt an uns nicht nach unsern Sünden,',
          'vergilt uns nicht nach unsrer Schuld.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Gott kann nur seine Liebe schenken.',
          'Unser Gott ist voll zärtlicher Zuneigung.',
          '',
          'So hoch der Himmel über der Erde ist,',
          'so hoch ist seine Huld über uns.',
          '𝄆 Dieu est tendresse 𝄇',
          'So weit der Aufgang entfernt ist vom Untergang,',
          'so weit entfernt er die Schuld von uns.',
          '𝄆 Dieu qui pardonne 𝄇',
          '',
          'Gott kann nur seine Liebe schenken.',
          'Unser Gott ist Vergebung.',
        ],
      ),
      /*
      NetworkSongData(
        tagger: AudioTagger.instance,
        index: 0,
        title: '',
        locale: Locales.und,
        album: '',
        cover:
            '',
        youtubeId: '',
        duration: Duration(seconds: 999),
        notes: 'https://www.taize.fr/IMG/.png',
        soprano: 'https://www.taize.fr/IMG/mid/_s.mid',
        alto: 'https://www.taize.fr/IMG/mid/_a.mid',
        tenor: 'https://www.taize.fr/IMG/mid/_t.mid',
        bass: 'https://www.taize.fr/IMG/mid/_b.mid',
        together: 'https://www.taize.fr/IMG/mid/_e.mid',
        guitar: 'https://www.taize.fr/IMG/mid/_g.mid',
        pronunciation:
            'https://taize.ulinater.de/.mp3',
        lyrics: [
          '',
        ],
        phonetics: [
          '',
        ],
        translation: [
          '',
        ],
      ),
      */
    ],
  ),
).songs;

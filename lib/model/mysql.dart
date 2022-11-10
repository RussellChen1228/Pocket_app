import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocket_ktv/model/language.dart';

import 'local_library.dart';

final bool useOfflineData = false;

enum LibraryView {
  // From newest to oldest.
  sortByDate,
  // From the most popular to the least popular.
  sortByPopularity,
}

Future<List<Song>> getSongs({
  Language language = Language.minnan,
  LibraryView view = LibraryView.sortByDate,
  int wordCount = -1,
}) async {
  late String lang;
  switch (language) {
    case Language.chinese:
      lang = 'chinese';
      break;
    case Language.english:
      lang = 'english';
      break;
    case Language.japanese:
      lang = 'japanese';
      break;
    default:
      lang = 'minnan';
  }

  late final String sortby;
  if (view == LibraryView.sortByPopularity) {
    sortby = 'popularity';
  } else {
    sortby = 'date';
  }

  if (useOfflineData) {
    final songs = await getFakeData();
    return songs;
  } else {
    final response = await http.get(
      Uri.parse(
          'http://140.116.245.153:3000/get_songs?language=$lang&sort_by=$sortby&word_count=$wordCount'),
    );
    if (response.statusCode == 200) {
      final jsons = jsonDecode(utf8.decode(response.bodyBytes));
      return jsons.map<Song>((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load songs from database');
    }
  }
}

enum Target {
  songName,
  songNumber,
  artist,
}

enum SearchMode {
  exact,
  wordFuzzy,
  phoneFuzzy,
}

Future<List<Song>> search(
  String name, {
  searchMode = SearchMode.exact,
  target = Target.songName,
}) async {
  if (name.isEmpty) {
    return [];
  }

  if (useOfflineData) {
    return await getFakeData();
  } else {
    late final targetStr;
    switch (target) {
      case Target.songNumber:
        targetStr = 'songnumber';
        break;
      case Target.artist:
        targetStr = 'artist';
        break;
      default:
        targetStr = 'songname';
    }

    late final modeStr;
    switch (searchMode) {
      case SearchMode.phoneFuzzy:
        modeStr = 'phonefuzzy';
        break;
      case SearchMode.wordFuzzy:
        modeStr = 'wordfuzzy';
        break;
      default:
        modeStr = 'exact';
    }

    final response = await http.get(
      Uri.parse(
          'http://140.116.245.153:3000/search/$name?search_target=$targetStr&search_mode=$modeStr'),
    );

    if (response.statusCode == 200) {
      final jsons = jsonDecode(utf8.decode(response.bodyBytes));
      return jsons.map<Song>((e) => Song.fromJson(e)).toList();
    } else {
      print(response.statusCode); //debug
      throw Exception('Failed to search songs from database');
    }
  }
}

Future<List<Song>> getFakeData() async {
  const langs = ['台', '國', '英', '日'];
  var normalLyric =
      '羅志祥-羅生門;;是否真愛的學分　非要摔痛了才能修得成;那千奇百怪艱深的學問　就像羅生門;不信有愛的高材生　可以從不受傷順利閃人;同是天涯寂寞人　只想找個人疼;通常太仔細　計算後的愛情;往往根本不敷成本　還以為價值連城;沒有該不該　誰都會想愛;羅生門打開比賽　百戰百勝不是我的表率真心;那個吻才值得等待　成功或失敗　晉級或淘汰;羅生門打開要愛　如果某個早晨真愛會來;失眠的過程我可以忍耐;或許太習慣單身;不免少了免疫力的成份　如果有愛突然跑來敲門;或許會恍神　敢愛的人有一點愚蠢;從不怕變成受傷的靈魂　沿路就算要沉淪;只要幸福上門　儘管大家愛唱的情歌;往往永遠都充滿著怨恨　我拒絕相提並論;我不信有人非得承認;不信對愛永遠有緣無份　這個世界上有那麼多的人;總會有一個值得總會值得我笨;我不怕這一路有冷有熱　不怕感覺對了就該犧牲;愛情的面前無所謂分寸　我拼它一個認真拼它一個永恆';
  var dynamicLyric =
      '[00:06.28]燈光;[00:08.93];[00:10.11]作詞：謝震廷;[00:12.09]作曲：謝震廷;[00:15.23]編曲：謝震廷、田雅欣;[00:17.23];[00:26.43]一個人走在路上 不知道是第幾晚上;[00:29.61]已沒有人來人往 也沒有城市交響;[00:33.83]入夜後的台北 很漂亮;[00:37.09]但怎麼卻感覺 很悲傷;[00:40.32];[00:40.74]大概是又想起你說 說我像個太陽;[00:44.41]24小時開朗 為人照亮;[00:47.34]但其實你說謊 你知道;[00:50.51]若沒有你我根本就沒有辦法 發光;[00:55.20]你很健忘 沒你在旁 哪裡來的力量;[01:00.06]感傷 這一切都已經成過往;[01:03.37]如果時光回放 多渴望告訴你;[01:06.48];[01:07.32]我不想做太陽 我不想再逞強;[01:13.09]我只想為你 做一盞燈光;[01:16.48]在你需要我的時候把開關按下;[01:19.71];[01:20.50]你不必再流浪 你不必再心慌;[01:26.69]不必再去想 不必再去扛;[01:29.98]我也不必假裝你還在我的身旁;[01:35.33]多愚妄;[01:43.90];[01:46.91]一個人走在路上 漫無目的地遊蕩;[01:50.15]看著路燈的昏黃 把陰影拉好長;[01:53.83]長到我 怎麼樣 都追不上;[01:57.50]沒有你 我永遠 都追不上;[02:00.77]大概是又想起你說 說我像個太陽;[02:04.56]24小時開朗 為人照亮;[02:07.48]現在聽來誇張 你知道;[02:10.57]若沒有你我根本就沒有 辦法 發光;[02:14.75]你不健忘 你是善良 為了讓我堅強;[02:19.89]感傷 這一切都已經成過往;[02:23.35]如果時光回放 我一定告訴你;[02:26.02];[02:26.60]我不想做太陽 我不想再逞強;[02:32.98]我只想為你 做一盞燈光;[02:36.18]在你需要我的時候把開關按下;[02:39.81];[02:40.39]你不必再流浪 你不必再心慌;[02:46.09]不必再去想 不必再去扛;[02:49.40]我也不必假裝你還在我的身旁;[02:59.99];[03:19.85]我不想做太陽 不想再逞強;[03:26.27]我只想做你 心裡的燈光;[03:29.79]在你快離開的時候把開關按下;[03:33.15];[03:33.50]我不會再假裝 我不會再說謊;[03:43.12]我只想陪你一起到遠方;[03:47.26]如果說時光真的能夠回放;[03:50.15]如果說時光真的能夠回放;[03:53.68]如果說時光真的能夠回放…;';
  final songs = List<Song>.generate(
    20,
    (index) {
      return Song(
        youtubeUrl: 'upUjlErMmO4',
        name: '歌曲$index',
        artist: '歌手$index',
        lyric: (index % 2 == 0) ? dynamicLyric : normalLyric,
        language: langs[index % 4],
        songNumber: index.toString(),
      );
    },
  );
  songs.insert(
    0,
    Song(
      youtubeUrl: 'upUjlErMmO4',
      name: '浪流連',
      artist: '歌手',
      lyric: dynamicLyric,
      language: '台',
      songNumber: '123',
    ),
  );
  return await Future.delayed(const Duration(seconds: 1)).then((_) => songs);
}

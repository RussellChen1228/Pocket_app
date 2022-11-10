import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/widgets/confirm.dart';
import 'package:provider/provider.dart';

import 'add_to_playlist.dart';

// ignore: non_constant_identifier_names
var song_lyric2 =
    '羅志祥-羅生門;;是否真愛的學分　非要摔痛了才能修得成;那千奇百怪艱深的學問　就像羅生門;不信有愛的高材生　可以從不受傷順利閃人;同是天涯寂寞人　只想找個人疼;通常太仔細　計算後的愛情;往往根本不敷成本　還以為價值連城;沒有該不該　誰都會想愛;羅生門打開比賽　百戰百勝不是我的表率真心;那個吻才值得等待　成功或失敗　晉級或淘汰;羅生門打開要愛　如果某個早晨真愛會來;失眠的過程我可以忍耐;或許太習慣單身;不免少了免疫力的成份　如果有愛突然跑來敲門;或許會恍神　敢愛的人有一點愚蠢;從不怕變成受傷的靈魂　沿路就算要沉淪;只要幸福上門　儘管大家愛唱的情歌;往往永遠都充滿著怨恨　我拒絕相提並論;我不信有人非得承認;不信對愛永遠有緣無份　這個世界上有那麼多的人;總會有一個值得總會值得我笨;我不怕這一路有冷有熱　不怕感覺對了就該犧牲;愛情的面前無所謂分寸　我拼它一個認真拼它一個永恆';
var song_lyric =
    '[00:06.28]燈光#[00:08.93]#[00:10.11]作詞：謝震廷#[00:12.09]作曲：謝震廷#[00:15.23]編曲：謝震廷、田雅欣#[00:17.23]#[00:26.43]一個人走在路上 不知道是第幾晚上#[00:29.61]已沒有人來人往 也沒有城市交響#[00:33.83]入夜後的台北 很漂亮#[00:37.09]但怎麼卻感覺 很悲傷#[00:40.32]#[00:40.74]大概是又想起你說 說我像個太陽#[00:44.41]24小時開朗 為人照亮#[00:47.34]但其實你說謊 你知道#[00:50.51]若沒有你我根本就沒有辦法 發光#[00:55.20]你很健忘 沒你在旁 哪裡來的力量#[01:00.06]感傷 這一切都已經成過往#[01:03.37]如果時光回放 多渴望告訴你#[01:06.48]#[01:07.32]我不想做太陽 我不想再逞強#[01:13.09]我只想為你 做一盞燈光#[01:16.48]在你需要我的時候把開關按下#[01:19.71]#[01:20.50]你不必再流浪 你不必再心慌#[01:26.69]不必再去想 不必再去扛#[01:29.98]我也不必假裝你還在我的身旁#[01:35.33]多愚妄#[01:43.90]#[01:46.91]一個人走在路上 漫無目的地遊蕩#[01:50.15]看著路燈的昏黃 把陰影拉好長#[01:53.83]長到我 怎麼樣 都追不上#[01:57.50]沒有你 我永遠 都追不上#[02:00.77]大概是又想起你說 說我像個太陽#[02:04.56]24小時開朗 為人照亮#[02:07.48]現在聽來誇張 你知道#[02:10.57]若沒有你我根本就沒有 辦法 發光#[02:14.75]你不健忘 你是善良 為了讓我堅強#[02:19.89]感傷 這一切都已經成過往#[02:23.35]如果時光回放 我一定告訴你#[02:26.02]#[02:26.60]我不想做太陽 我不想再逞強#[02:32.98]我只想為你 做一盞燈光#[02:36.18]在你需要我的時候把開關按下#[02:39.81]#[02:40.39]你不必再流浪 你不必再心慌#[02:46.09]不必再去想 不必再去扛#[02:49.40]我也不必假裝你還在我的身旁#[02:59.99]#[03:19.85]我不想做太陽 不想再逞強#[03:26.27]我只想做你 心裡的燈光#[03:29.79]在你快離開的時候把開關按下#[03:33.15]#[03:33.50]我不會再假裝 我不會再說謊#[03:43.12]我只想陪你一起到遠方#[03:47.26]如果說時光真的能夠回放#[03:50.15]如果說時光真的能夠回放#[03:53.68]如果說時光真的能夠回放…#';
// ignore: non_constant_identifier_names
dynamic curtime;
dynamic result;

class Lyric {
  String lyric;
  Duration startTime;
  Duration endTime;
  Lyric(
    this.lyric, {
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return 'Lyric{lyric: $lyric, startTime: $startTime, endTime: $endTime}';
  }
}

/// 格式化歌词
List<Lyric> formatLyric(String lyricStr) {
  RegExp reg = RegExp(r"^\[\d{2}");

  List<Lyric> result =
      lyricStr.split(";").where((r) => reg.hasMatch(r)).map((s) {
    String time = s.substring(0, s.indexOf(']'));
    String lyric = s.substring(s.indexOf(']') + 1);
    time = s.substring(1, time.length - 1);
    int hourSeparatorIndex = time.indexOf(":");
    int minuteSeparatorIndex = time.indexOf(".");
    return Lyric(
      lyric,
      startTime: Duration(
        minutes: int.parse(
          time.substring(0, hourSeparatorIndex),
        ),
        seconds: int.parse(
            time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
        milliseconds: int.parse(time.substring(minuteSeparatorIndex + 1)),
      ),
      endTime: Duration(
        minutes: int.parse(
          time.substring(0, hourSeparatorIndex),
        ),
        seconds: int.parse(
            time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
        milliseconds: int.parse(time.substring(minuteSeparatorIndex + 1)),
      ),
    );
  }).toList();

  for (int i = 0; i < result.length - 1; i++) {
    result[i].endTime = result[i + 1].startTime;
  }
  result[result.length - 1].endTime = const Duration(hours: 1);
  return result;
}

// ignore: camel_case_types
class lyricpainter extends CustomPainter {
  // ignore: non_constant_identifier_names
  late final List<Lyric> result;

  // ignore: non_constant_identifier_names
  lyricpainter({required this.result});

  //var _repaint=false;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // 畫歌詞
    var _position = 0.0;

    final _textpainter = TextPainter(
        textDirection: TextDirection.rtl, textAlign: TextAlign.center);
    //var _offset=5;
    int k = 0;
    bool ok = false;
    int handle_begin = 0;
    //result.removeWhere((item) => item.lyric.toString() == '');  //去空格
    for (int i = 0; i < result.length; i++) {
      if (i < result.length - 1) {
        if (result[i].endTime <= curtime && result[i + 1].startTime > curtime) {
          ok = true;
        }
      }
      if ((result[i].startTime <= curtime && curtime <= result[i].endTime) ||
          ok) {
        if (i <= 2) {
          handle_begin = i;
          k = 2 - i;
        } else {
          handle_begin = 1;
        }
        for (int j = i - handle_begin; k < 7 && j < result.length; j++) {
          if (j == i) {
            _textpainter.text = TextSpan(
                style: const TextStyle(fontSize: 24.0, color: Colors.white),
                text: result[j].lyric.toString());
          } else if (j < 0 || j >= result.length) {
            _textpainter.text = const TextSpan(
                style: TextStyle(fontSize: 24.0, color: Colors.black),
                text: "");
          } else {
            _textpainter.text = TextSpan(
                style: const TextStyle(fontSize: 24.0, color: Colors.black),
                text: result[j].lyric.toString());
          }
          _textpainter.layout(
            minWidth: 0,
            maxWidth: size.width,
          );

          k = k + _textpainter.height ~/ 35;
          if (_textpainter.height < 35) {
            k += 1;
          }

          if (i < 2) {
            _textpainter.paint(
                canvas,
                Offset((size.width - _textpainter.width) / 2,
                    _position + 70 - 35 * i));
            _position += _textpainter.height;
          } else {
            _textpainter.paint(canvas,
                Offset((size.width - _textpainter.width) / 2, _position));
            _position += _textpainter.height;
          }
        }

        break;
      }
    }
  }

  @override
  bool shouldRepaint(lyricpainter oldDelegate) {
    //log('repaint? '+oldDelegate._repaint.toString());
    return false;
  }
}

/************************************************************************************* */

/// Homepage
class Player extends StatefulWidget {
  Player({this.song, Key? key}) : super(key: key);
  var song;
  @override
  _Player createState() => _Player(song: this.song);
}

class _Player extends State<Player> {
  late YoutubePlayerController _controller;
  var song;
  _Player({this.song});
  //late TextEditingController _idController;

  late YoutubeMetaData _videoMetaData;

  bool _isPlayerReady = false;
  bool _isRepeat = false;
  bool _onchange = false;
  double _videoDuration = 0;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '', //'upUjlErMmO4'
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        hideControls: true,
        hideThumbnail: true,
      ),
    )..addListener(listener);
    //_idController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
  }

  void listener() {
    if (_isPlayerReady) {
      setState(() {
        _videoMetaData = _controller.metadata;
        curtime = _controller.value.position;
      });
      final _timelist = _videoMetaData.duration.toString().split(':');
      _videoDuration = double.parse(_timelist[0]) * 3600 +
          double.parse(_timelist[1]) * 60 +
          double.parse(_timelist[2]);
    }

    if (_isPlayerReady &&
        !_onchange &&
        _controller.value.isPlaying &&
        _controller.value.isReady) {
      _time = (_controller.value.position.inSeconds).toDouble();
    }

    if (_isRepeat &&
        _isPlayerReady &&
        _controller.value.playerState.toString() == "PlayerState.ended") {
      _isPlayerReady = false;
      _time = 0;
      _controller.play();
    }

    if (!_isPlayerReady &&
        _controller.value.playerState.toString() == "PlayerState.playing") {
      _isPlayerReady = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final song = ModalRoute.of(context)!.settings.arguments as Song;

    //有時間和無時間的輸入
    final _songlist = song.lyric.split(';');
    if (song.hasDynamicLyric) {
      result = formatLyric(song.lyric);
    }

    return Scaffold(
      body: YoutubePlayerBuilder(
        onExitFullScreen: () {
          // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          topActions: <Widget>[
            const SizedBox(width: 5.0), //Youtube title
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
          onReady: () {
            _isPlayerReady = true;
            _controller.load(song.youtubeUrl); // LOAD 影片的ID 燈光_ID: upUjlErMmO4
          },
        ),
        builder: (context, player) => Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 0.90,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    alignment: Alignment.centerRight,
                    //width: 330,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 25,
                        )),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 300 / 375,
                  child: AspectRatio(aspectRatio: 300 / 165, child: player),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                          child: Text(song.name,
                              style: const TextStyle(fontSize: 22)), //顯示歌曲
                        ),
                        Padding(
                          // 分别指定四个方向的补白
                          padding:
                              const EdgeInsets.fromLTRB(35.0, .0, 35.0, 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(song.artist,
                                  style: const TextStyle(
                                      fontSize: 18, color: Color(0xFF716E6E))),
                              Text(song.songNumber.toString(),
                                  style: const TextStyle(fontSize: 18))
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              //時間軸
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 1,
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: 0.97,
                                  //heightFactor: 0.5,
                                  //height: 15,
                                  child: Slider(
                                    inactiveColor: const Color(0xFF000000),
                                    value: _time,
                                    min: 0.0,
                                    max: _videoDuration == 0
                                        ? 100.0
                                        : _videoDuration,
                                    divisions: _videoDuration == 0
                                        ? 100
                                        : _videoDuration.toInt(),
                                    label: (_time).round() % 60 < 10
                                        ? '${_time ~/ 60}:0${(_time).round() % 60}'
                                        : '${_time ~/ 60}:${(_time).round() % 60}',
                                    onChangeStart: _isPlayerReady
                                        ? (value) {
                                            setState(() {
                                              _onchange = true;
                                            });
                                          }
                                        : null,
                                    onChanged: _isPlayerReady
                                        ? (value) {
                                            setState(() {
                                              _time = value < _videoDuration
                                                  ? value
                                                  : _videoDuration;
                                            });
                                          }
                                        : null,
                                    onChangeEnd: _isPlayerReady
                                        ? (value) {
                                            setState(() {
                                              _controller.load(
                                                  _videoMetaData.videoId,
                                                  startAt: value.toInt());

                                              Timer(const Duration(seconds: 2),
                                                  () => _onchange = false);
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(.0, .0, .0, 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Consumer<DatabaseHelper>(
                                builder: (context, dbInstance, child) {
                                  return FutureBuilder<Playlist?>(
                                    future: dbInstance.getPlaylistOfSong(song),
                                    builder: (context, snapshot) {
                                      final playlist = snapshot.data;
                                      if (playlist != null) {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              barrierColor:
                                                  Colors.black.withOpacity(0.7),
                                              context: context,
                                              builder: (context) => Confirm(
                                                highlightText: '${song.name}',
                                                actionText:
                                                    '從${playlist.name}移除嗎？',
                                                onConfirm: () {
                                                  dbInstance
                                                      .removeSongFromPlaylist(
                                                    playlist: playlist,
                                                    song: song,
                                                  );

                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 1500),
                                                      () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  });

                                                  showDialog(
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.7),
                                                    context: context,
                                                    builder: (context) {
                                                      return Align(
                                                        alignment:
                                                            Alignment(0, -0.1),
                                                        child: AspectRatio(
                                                          aspectRatio:
                                                              214 / 215,
                                                          child:
                                                              FractionallySizedBox(
                                                            widthFactor: 0.6,
                                                            heightFactor: 0.6,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(17),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  // Deleted icon
                                                                  Container(
                                                                    width: 100,
                                                                    height: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade600,
                                                                          width:
                                                                              0.5),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 80,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '已從${playlist.name}移除',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.check_circle,
                                            size: 40.0,
                                            color: Color(0xFFE7AE36),
                                          ),
                                        );
                                      } else {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              barrierColor:
                                                  Colors.black.withOpacity(0.7),
                                              context: context,
                                              builder: (context) => Confirm(
                                                highlightText: '${song.name}',
                                                actionText: '新增到我的歌本',
                                                onConfirm: () {
                                                  Navigator.pop(context);
                                                  Navigator.of(context,
                                                      rootNavigator: true)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddToPlaylist(
                                                            song: song,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          // Add Icon
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 2),
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.add_rounded,
                                              color: Colors.grey.shade500,
                                              size: 35,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  _isPlayerReady = true;
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 2,
                                          color: const Color(0xFFa9a9a9))),
                                  child: _controller.value.isPlaying
                                      ? const Icon(
                                          Icons.pause,
                                          size: 40.0,
                                          color: Color(0xFFE7AE36),
                                        )
                                      : const Icon(Icons.play_arrow,
                                          size: 40.0, color: Color(0xFFE7AE36)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _isRepeat
                                      ? _isRepeat = false
                                      : _isRepeat = true;
                                  _controller.play();
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 2,
                                          color: _isRepeat
                                              ? const Color(0xFFFFD306)
                                              : const Color(0xFFa9a9a9))),
                                  child: const Icon(Icons.repeat, size: 15.0),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, .0, 20.0, .0),
                          child: AspectRatio(
                            aspectRatio: 327 / 284,
                            child: Container(
                              // 歌詞區
                              clipBehavior: Clip.hardEdge,

                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0071BC),
                                    Color(0xFF2CABE2)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 250 / 327,
                                heightFactor: 250 / 284,
                                child: song.hasDynamicLyric //判斷有沒有時間TAG
                                    ? Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration:
                                            const BoxDecoration(border: null),
                                        child: CustomPaint(
                                          //size: const Size(260, 100),
                                          painter: lyricpainter(result: result),
                                        ),
                                      )
                                    : Scrollbar(
                                        child: NotificationListener<
                                            ScrollNotification>(
                                          child: Stack(
                                            children: <Widget>[
                                              ListView.builder(
                                                  itemCount: _songlist.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                        //decoration:  BoxDecoration(border:Border.all(width:2,color: Colors.red),),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        margin: const EdgeInsets
                                                                .fromLTRB(
                                                            .0, .0, .0, 10.0),
                                                        width: 200,
                                                        child: Text(
                                                          _songlist[index],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      24.0,
                                                                  color: Colors
                                                                      .black),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ));
                                                  }),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

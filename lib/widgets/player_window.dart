import 'dart:async';
import 'dart:developer';

import 'package:pocket_ktv/model/local_library.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ktv/screens/add_to_playlist.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pocket_ktv/widgets/confirm.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

dynamic curtime;

class Player_window extends StatefulWidget {
  const Player_window({Key? key, required this.song}) : super(key: key);
  final Song song;

  @override
  _Player_window createState() => _Player_window();
}

class _Player_window extends State<Player_window> {
  late YoutubePlayerController _controller;

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

  double _positionoffset = 0;
  double _width = 0;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Align(
      alignment: Alignment(0, 1.5),
      child: AspectRatio(
        aspectRatio: 375 / 512,
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 750 / 812,
          child: Container(
            decoration: BoxDecoration(
              //border: Border.all(color: Colors.blue, width: 5),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                onReady: () {
                  _isPlayerReady = true;
                  _controller.load(widget.song.youtubeUrl);
                },
              ),
              builder: (context, player) => Column(children: [
                FractionallySizedBox(
                  widthFactor: 315 / 375,
                  child: Container(
                    height: 80,
                    //width: 330,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Consumer<DatabaseHelper>(
                                  builder: (context, dbInstance, child) {
                                    return FutureBuilder<Playlist?>(
                                      future: dbInstance
                                          .getPlaylistOfSong(widget.song),
                                      builder: (context, snapshot) {
                                        final playlist = snapshot.data;
                                        if (playlist != null) {
                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierColor: Colors.black
                                                    .withOpacity(0.7),
                                                context: context,
                                                builder: (context) => Confirm(
                                                  highlightText:
                                                      '${widget.song.name}',
                                                  actionText:
                                                      '從${playlist.name}移除嗎？',
                                                  onConfirm: () {
                                                    dbInstance
                                                        .removeSongFromPlaylist(
                                                      playlist: playlist,
                                                      song: widget.song,
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
                                                          alignment: Alignment(
                                                              0, -0.1),
                                                          child: AspectRatio(
                                                            aspectRatio:
                                                                214 / 215,
                                                            child:
                                                                FractionallySizedBox(
                                                              widthFactor: 0.6,
                                                              heightFactor: 0.6,
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(17
                                                                            .r),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.r),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    // Deleted icon
                                                                    Container(
                                                                      width:
                                                                          100.w,
                                                                      height:
                                                                          100.h,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey.shade600,
                                                                            width: 0.5),
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .grey,
                                                                        size: 80
                                                                            .r,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '已從${playlist.name}移除',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17.sp,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 40,
                                              color: Color(0xFFE7AE36),
                                            ),
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierColor: Colors.black
                                                    .withOpacity(0.7),
                                                context: context,
                                                builder: (context) => Confirm(
                                                  highlightText:
                                                      '${widget.song.name}',
                                                  actionText: '新增到我的歌本',
                                                  onConfirm: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddToPlaylist(
                                                          song: widget.song,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            // Add Icon
                                            child: Container(
                                                //margin: const EdgeInsets.all(10),
                                                width: 40,
                                                height: 70,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade500,
                                                      width: 2),
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                child: const Text(
                                                  "+",
                                                  style: TextStyle(
                                                      fontSize: 30,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      '新增到歌本',
                                      style: TextStyle(
                                          color: Color(0xff716E6E),
                                          fontSize: 14),
                                    ))
                              ]),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 25,
                              )),
                        ]),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 300 / 135,
                  child: FractionallySizedBox(
                    widthFactor: 300 / 375,
                    child: Container(
                      child: player,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 300 / 375,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.song.name,
                          style: const TextStyle(fontSize: 22)), //顯示歌曲
                    ),
                  ),
                ),
                Padding(
                  // 分别指定四个方向的补白
                  padding: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.song.artist,
                          style: const TextStyle(
                              fontSize: 18, color: Color(0xFF716E6E))),
                      Text(widget.song.songNumber.toString(),
                          style: const TextStyle(fontSize: 18))
                    ],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 345 / 375,
                  child: Container(
                    height: 10,
                    child: Drawer(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 1,
                        ),
                        child: Slider(
                          inactiveColor: const Color(0xFF000000),
                          value: _time,
                          min: 0.0,
                          max: _videoDuration == 0 ? 100.0 : _videoDuration,
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
                                    _controller.load(_videoMetaData.videoId,
                                        startAt: value.toInt());

                                    Timer(const Duration(seconds: 4),
                                        () => _onchange = false);
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () {
                      _isPlayerReady = true;
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    },
                    child: Container(
                      //alignment: Alignment.centerLeft,
                      //margin: const EdgeInsets.all(0),

                      margin: const EdgeInsets.fromLTRB(35.0, 30.0, 0.0, 0.0),
                      padding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffE58E46),
                      ),
                      child: _controller.value.isPlaying
                          ? Row(children: const [
                              Icon(
                                Icons.pause,
                                size: 25.0,
                                color: Colors.white,
                              ),
                              Text('播放中',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white))
                            ])
                          : Row(children: const [
                              Icon(Icons.play_arrow,
                                  size: 25.0, color: Colors.white),
                              Text('暫停中',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white))
                            ]),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

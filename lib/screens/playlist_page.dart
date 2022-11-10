import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pocket_ktv/model/lang_color.dart';
import 'package:pocket_ktv/model/language.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/model/socket.dart';
import 'package:pocket_ktv/model/stt_result.dart';
import 'package:pocket_ktv/screens/result_page.dart';
import 'package:pocket_ktv/screens/player_page.dart';
import 'package:pocket_ktv/screens/stt_page.dart';
import 'package:pocket_ktv/model/reduce_string.dart';
import 'package:pocket_ktv/widgets/color_loader_4.dart';
import 'package:pocket_ktv/widgets/confirm.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  PlaylistPage({required this.playlist, Key? key}) : super(key: key);

  final Playlist playlist;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // final playlist = ModalRoute.of(context)!.settings.arguments as Playlist;
    final controller = PageController(initialPage: _currentPage);
    const _songs_per_page = 5;

    void _choiceAction(String choice) {
      if (choice == Constants.modifyPlayList) {
        print('編輯歌本名稱');
        var db = DatabaseHelper.instance;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _RenamePlaylist(
              originalName: widget.playlist.name,
              onConfirm: (String playlistName) async {
                await db.modifyPlayListName(
                    playlist: widget.playlist, newPlayListName: playlistName);
                setState(() {});
              },
            ),
          ),
        );
      } else if (choice == Constants.deletePlayList) {
        print('刪除歌本');
      }
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Spacing
              SizedBox(
                height: 15.h,
              ),
              // Heading: Title and voice search bar.
              SizedBox(
                width: 300.w,
                height: 186.h,
                child: Stack(
                  children: [
                    // Title
                    Center(
                      child: Container(
                        width: 270.w,
                        height: 168.29.h,
                        // Align with page view tile.
                        // margin: EdgeInsets.symmetric(horizontal: 17.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.cyan.shade200,
                              Colors.lightBlue.shade800,
                            ],
                          ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Text(
                                widget.playlist.name,
                                style: TextStyle(
                                    fontSize: 24.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                              Expanded(
                                child: PopupMenuButton(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0))),
                                    offset: const Offset(0, 50),
                                    icon: const Icon(Icons.create_rounded),
                                    onSelected: _choiceAction,
                                    itemBuilder: (BuildContext context) {
                                      return Constants.choices
                                          .map((String choice) {
                                        return PopupMenuItem<String>(
                                          enabled: (choice ==
                                                  Constants.deletePlayList)
                                              ? false
                                              : true,
                                          value: choice,
                                          child: Text(choice),
                                        );
                                      }).toList();
                                    }),
                              )
                            ]),
                      ),
                    ),
                    // Voice search bar.
                    // 137 + 45 - 168.29
                    Align(
                      alignment: const Alignment(0, 1.1),
                      child: _VoiceSearchBar(playlist: widget.playlist),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Songs
              Expanded(
                child: Consumer<DatabaseHelper>(
                  builder: (context, dbInstance, child) {
                    return FutureBuilder<List<Song>>(
                      future: dbInstance.getSongsOfPlaylist(widget.playlist),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Song>? songs = snapshot.data;
                          final _totalPage =
                              (songs!.length / _songs_per_page).ceil();
                          return Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: controller,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemCount: _totalPage,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final start =
                                        _currentPage * _songs_per_page;
                                    late final List<Song> pageSongs;
                                    if (start + _songs_per_page >
                                        songs.length) {
                                      pageSongs = songs.sublist(start);
                                    } else {
                                      pageSongs = songs.sublist(
                                          start, start + _songs_per_page);
                                    }
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: ListTile.divideTiles(
                                        context: context,
                                        tiles: pageSongs
                                            .map((e) => _SongCard(
                                                  song: e,
                                                  playlist: widget.playlist,
                                                  onRemoved: () {
                                                    dbInstance
                                                        .removeSongFromPlaylist(
                                                      playlist: widget.playlist,
                                                      song: e,
                                                    );

                                                    showDialog(
                                                      barrierColor: Colors.black
                                                          .withOpacity(0.7),
                                                      context: context,
                                                      builder: (context) {
                                                        // Pop 2 confirm dialog.
                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    1500), () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        });

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
                                                                            width: 0.5.w),
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
                                                                      '已從${widget.playlist.name}移除',
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

                                                    // Database updated, redraw playlist.
                                                    setState(() {});
                                                  },
                                                ))
                                            .toList(),
                                      ).toList(),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 30.h,
                                child: (songs.length > 0)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Prev page.
                                          GestureDetector(
                                            onTap: () {
                                              if (controller.hasClients) {
                                                controller.previousPage(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            child: (_currentPage == 0)
                                                ? SizedBox(width: 64.w)
                                                : Row(
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_back_ios,
                                                        size: 18.r,
                                                      ),
                                                      Text(
                                                        '上一頁',
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                          Text(
                                            (_currentPage + 1).toString() +
                                                '/$_totalPage',
                                            style: TextStyle(
                                              fontSize: 19.sp,
                                            ),
                                          ),
                                          // Next page.
                                          GestureDetector(
                                            onTap: () {
                                              if (controller.hasClients) {
                                                controller.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            child: (_currentPage + 1 ==
                                                    _totalPage)
                                                ? SizedBox(width: 64.w)
                                                : Row(
                                                    children: [
                                                      Text(
                                                        '下一頁',
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 18.r,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ),
                              SizedBox(height: 5.h),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text('error'));
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenamePlaylist extends StatefulWidget {
  _RenamePlaylist({
    Key? key,
    required this.onConfirm,
    required this.originalName,
  }) : super(key: key);

  String originalName;
  void Function(String) onConfirm;

  @override
  State<_RenamePlaylist> createState() => _RenamePlaylistState();
}

class _RenamePlaylistState extends State<_RenamePlaylist> {
  final _controller = TextEditingController();

  bool _isButtonDisabled = true;
  bool _isTyping = false;

  @override
  void initState() {
    _controller.text = widget.originalName;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[700],
      body: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            height: 200.h,
            margin: EdgeInsets.only(top: 100.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '編輯歌本名稱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextField(
                  onTap: () => setState(() {
                    _isTyping = true;
                  }),
                  onChanged: (text) {
                    if (text != "") {
                      setState(() {
                        _isButtonDisabled = false;
                      });
                    } else {
                      setState(() {
                        _isButtonDisabled = true;
                      });
                    }
                  },
                  // Show keyboard automatically.
                  autofocus: true,
                  controller: _controller,
                  textAlign: TextAlign.center,
                  cursorColor: Colors.grey,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    // TODO: Align label text center.
                    alignLabelWithHint: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    // hintText: _isTyping ? "" : '輸入歌本名稱',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          widget.onConfirm(_controller.text);
                          Navigator.pop(context, '確定');
                        },
                  child: Text(
                    '確定',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: _isButtonDisabled
                      ? ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                        )
                      : ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange),
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

class Constants {
  static const String modifyPlayList = '編輯歌本名稱';
  static const String deletePlayList = '刪除歌本';

  static const List<String> choices = <String>[
    modifyPlayList,
    deletePlayList,
  ];
}

class _VoiceSearchBar extends StatelessWidget {
  const _VoiceSearchBar({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final Playlist playlist;

  void _voiceSearch(BuildContext context) async {
    // Speech2text
    SttResult? result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => SttPage(),
      ),
    );

    bool searchAgain = false;
    if (result != null) {
      // Push loading page.
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => _Loading(),
        ),
      );

      // Search database.
      final db = DatabaseHelper.instance;
      List<Song> songs;

      if (result.language == Language.minnan ||
          result.language == Language.chinese) {
        // STT
        Directory tempDir = await path_provider.getTemporaryDirectory();
        // The path is same as stt_page.dart
        final wavPath = '${tempDir.path}/Song.wav';
        final names = await SpeechToText.speech2text(wavPath);
        result.result =
            (result.language == Language.minnan) ? names.name1 : names.name2;
      }
      songs = await db.searchSongs(playlist, result.result);

      // Pop loading page.
      Navigator.of(context, rootNavigator: true).pop();

      // Show results.
      if (songs.isEmpty) {
        await showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (context) => _DialogNotFound(songName: result.result),
        );
      } else {
        await showDialog(
          barrierColor: Colors.black.withOpacity(0.7),
          context: context,
          builder: (context) => _DialogFound(
            songs: songs,
            onMicTap: () {
              Navigator.pop(context);
              searchAgain = true;
            },
          ),
        );
      }
    }

    if (searchAgain) {
      searchAgain = false;
      _voiceSearch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _voiceSearch(context);
      },
      child: Container(
        width: 180.w,
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.r),
          color: Colors.white,
          border: Border.all(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mic
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.grey[500],
              ),
              child: Padding(
                padding: EdgeInsets.all(5.r),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 30.r,
                ),
              ),
            ),
            Text(
              '搜尋${Reduce.reduce(playlist.name, 10)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    Key? key,
    required this.song,
    required this.playlist,
    required this.onRemoved,
  }) : super(key: key);

  final Song song;
  final Playlist playlist;
  final void Function() onRemoved;

  @override
  Widget build(BuildContext context) {
    // left padding (spacer)
    //  + iamge with icon (stack)
    //  + inner padding (spacer)
    //  + song information (column)
    //  + right padding (spacer)
    return InkWell(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => Player(song: song),
        ),
      ),
      child: Padding(
        // padding: EdgeInsets.fromLTRB(50.w, 5.h, 20.w, 5.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment(-1.5, 0),
              children: [
                // Image
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 55.h,
                      maxWidth: 80.w,
                    ),
                    child: Image.network(
                      'https://img.youtube.com/vi/${song.youtubeUrl}/0.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierColor: Colors.black.withOpacity(0.7),
                        context: context,
                        builder: (context) => Confirm(
                          highlightText: '${song.name}',
                          onConfirm: onRemoved,
                          actionText: '從${playlist.name}移除嗎？',
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.shade600, width: 0.5.w),
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.orange,
                        size: 30.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 20.w,
            ),
            SizedBox(
              width: (56 + 174).w,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        song.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          song.artist,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            height: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.songNumber,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              height: 1.0),
                        ),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogNotFound extends StatelessWidget {
  String songName;

  _DialogNotFound({Key? key, required this.songName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 280.h,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              Reduce.reduce(songName, 13),
              style: TextStyle(
                color: Colors.orange.shade600,
                fontSize: 23.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              '這首歌還不在歌本內喔',
              style: TextStyle(
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 27.h),
            ElevatedButton(
              child: Text(
                '馬上搜尋',
                style: TextStyle(
                  fontSize: 23.sp,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(10.w)),
                elevation: MaterialStateProperty.all(4),
                backgroundColor: MaterialStateProperty.all(Color(0xff34bacc)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r), //設定圓角
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ResultPage(songName: songName, from: "playlist"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogFound extends StatelessWidget {
  List<Song> songs;
  final void Function() onMicTap;

  _DialogFound({Key? key, required this.songs, required this.onMicTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 325.w,
        height: 365.h,
        child: Stack(
          children: [
            Container(
              width: 325.w,
              height: 330.h,
              padding: EdgeInsets.only(
                left: 30.w,
                right: 30.w,
                bottom: 35.w,
                top: 10.w,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  color: Colors.black,
                  tiles: songs.map(
                    (song) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => Player(song: song),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: SizedBox(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  // Checked icon.
                                  Container(
                                    width: 30.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade600,
                                          width: 0.5),
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Colors.orange,
                                      size: 17.r,
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  // Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          song.songNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  // Language tag.
                                  Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      color: langColor[song.language],
                                    ),
                                    child: Text(
                                      song.language,
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ).toList(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: onMicTap,
                child: SizedBox(
                  width: 70.w,
                  height: 70.h,
                  child: Image.asset('assets/images/playlist_mic_cyan.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 110.w,
          right: 110.w,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Text(
                '正在搜尋...',
                style: TextStyle(
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 482.h),
              ColorLoader4(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/lang_color.dart';
import 'package:pocket_ktv/model/language.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pocket_ktv/model/mysql.dart';
import 'package:pocket_ktv/screens/player_page.dart';
import 'package:pocket_ktv/widgets/color_loader_4.dart';
import 'package:pocket_ktv/widgets/confirm.dart';
import 'package:pocket_ktv/model/reduce_string.dart';
import 'package:pocket_ktv/model/socket.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_to_playlist.dart';

class ResultPage extends StatelessWidget {
  ResultPage({
    Key? key,
    this.songName = '',
    this.sttLanguage,
    required this.from,
  }) : super(key: key);

  String songName;
  final String from;
  final Language? sttLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 72.h, left: 44.w, right: 44.w),
        child: Align(
          alignment: Alignment.topCenter,
          child: FutureBuilder(
              future: getSongs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final songs = snapshot.data as List<Song>;

                  if (songs.isEmpty) {
                    var h = 0.73;
                    String newSongName = Reduce.reduce(songName, 13);
                    return SearchExternalWidget(
                      highlightText: newSongName,
                      from: from,
                      h: h,
                      onConfirm: () {
                        _launchURL();
                      },
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '搜尋結果：',
                              style: TextStyle(
                                fontSize: 24.sp,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                songName,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  color: Colors.red,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        buildListView(songs),
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  print('Remote database query error: ${snapshot.error}');
                  return Center(
                    child: Text('Error searching database for song: $songName'),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '正在搜尋...',
                          style: TextStyle(
                            fontSize: 24.sp,
                          ),
                        ),
                        // SizedBox(height: 480.h),
                        ColorLoader4(),
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }

  Future<List<Song>> getSongs() async {
    // Chinese or Minnan.
    if (sttLanguage == Language.minnan || sttLanguage == Language.chinese) {
      Directory tempDir = await path_provider.getTemporaryDirectory();
      // The path is same as record_page.
      final wavPath = '${tempDir.path}/Song.wav';
      final names = await SpeechToText.speech2text(wavPath);
      songName = sttLanguage == Language.minnan ? names.name1 : names.name2;
      print(songName); //debug
      final songs = await search(songName, searchMode: SearchMode.phoneFuzzy);
      return songs;
    } else {
      final songs = await search(songName);
      return songs;
    }
  }

  bool _isChinese(String s) {
    const String chineseUnicode = "[\u4e00-\u9fa5]";
    if (s.isEmpty) return false;
    return RegExp(chineseUnicode).hasMatch(s);
  }

  Widget buildListView(List<Song> songs) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 10.h,
        ),
        itemCount: songs.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => Player(song: songs.elementAt(index)),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 288 / 90,
              child: Card(
                color: const Color.fromARGB(255, 222, 218, 218),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(13.w),
                      child: Consumer<DatabaseHelper>(
                        builder: (context, dbInstance, child) {
                          return FutureBuilder<Playlist?>(
                            future: dbInstance.getPlaylistOfSong(songs[index]),
                            builder: (context, snapshot) {
                              final playlist = snapshot.data;
                              final song = songs[index];
                              if (playlist != null) {
                                return ElevatedButton(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.orange,
                                    size: 40.r,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      shape: MaterialStateProperty.all(
                                          const CircleBorder(
                                              side: BorderSide(
                                        style: BorderStyle.none,
                                      )) //設定圓角
                                          )),
                                  onPressed: () {
                                    showDialog(
                                      barrierColor:
                                          Colors.black.withOpacity(0.7),
                                      context: context,
                                      builder: (context) {
                                        return Confirm(
                                          highlightText: '${song.name}',
                                          actionText: '從${playlist.name}移除嗎？',
                                          onConfirm: () {
                                            dbInstance.removeSongFromPlaylist(
                                              playlist: playlist,
                                              song: song,
                                            );

                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 1500), () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            });

                                            showDialog(
                                              barrierColor:
                                                  Colors.black.withOpacity(0.7),
                                              context: context,
                                              builder: (context) {
                                                return Align(
                                                  alignment: Alignment(0, -0.1),
                                                  child: AspectRatio(
                                                    aspectRatio: 214 / 215,
                                                    child: FractionallySizedBox(
                                                      widthFactor: 0.6,
                                                      heightFactor: 0.6,
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            17.r),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.r),
                                                          color: Colors.grey,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            // Deleted icon
                                                            Container(
                                                              width: 100.w,
                                                              height: 100.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    width:
                                                                        0.5.w),
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                color:
                                                                    Colors.grey,
                                                                size: 80.r,
                                                              ),
                                                            ),
                                                            Text(
                                                              '已從${playlist.name}移除',
                                                              style: TextStyle(
                                                                fontSize: 24.sp,
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
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return ElevatedButton(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                    size: 40.r,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      shape: MaterialStateProperty.all(
                                          const CircleBorder(
                                              side: BorderSide(
                                        style: BorderStyle.none,
                                      )) //設定圓角
                                          )),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Confirm(
                                        highlightText: songs[index].name,
                                        actionText: '新增到我的歌本',
                                        onConfirm: () {
                                          Navigator.pop(context);
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddToPlaylist(
                                                song: songs[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                songs[index].name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(songs[index].artist,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  )),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(songs[index].songNumber,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  )),
                            ),
                          ]),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.r)),
                          color: langColor[songs[index].language],
                        ),
                        child: Text(
                          songs[index].language,
                          textScaleFactor: 1.0,
                          style: TextStyle(
                            fontSize: 26.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchURL() async {
    final String _url = Uri.encodeFull(
        "https://www.youtube.com/results?search_query=" + songName);
    if (!await launch(_url)) throw "Could not launch $_url";
  }
}

class SearchExternalWidget extends StatelessWidget {
  const SearchExternalWidget({
    Key? key,
    required this.from,
    required this.h,
    required this.highlightText,
    required this.onConfirm,
  }) : super(key: key);

  final String from;
  final double h;
  final String highlightText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: AspectRatio(
        aspectRatio: 220 / 215,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: h,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey,
            ),
            child: Column(
              children: [
                TextArea(highlightText: highlightText),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
                    ElevatedButton(
                      child: Text(
                        '不用',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(6),
                        fixedSize: MaterialStateProperty.all(Size(85.w, 38.h)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xffe58e46)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    // Confirm
                    ElevatedButton(
                      child: Text(
                        '好',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(6),
                        fixedSize: MaterialStateProperty.all(Size(85.w, 38.h)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xff34bacc)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      onPressed: onConfirm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextArea extends StatelessWidget {
  const TextArea({
    Key? key,
    required this.highlightText,
  }) : super(key: key);

  final String highlightText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 20.h, 3.w, 15.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              highlightText,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 7.04.h),
          Text(
            "這首歌目前不在弘音系統",
            style: TextStyle(
              // height: 1.0,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "歌庫內，但可為您至",
            style: TextStyle(
              height: 1.0,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "YouTube平台搜尋！",
            style: TextStyle(
              height: 1.0,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

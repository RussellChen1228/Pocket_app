import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/language.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/screens/add_to_playlist.dart';
import 'package:pocket_ktv/widgets/confirm.dart';
import 'package:provider/provider.dart';
import 'package:pocket_ktv/widgets/player_window.dart';
import '../model/mysql.dart';
import 'package:pocket_ktv/screens/player_page.dart';

double getAdaptiveTextSize(int size, context) {
  final fontScale = MediaQuery.of(context).textScaleFactor;
  return size / fontScale;
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final Color _selectedColor = const Color(0xffe58e46);
  final Color _unselectedColor = const Color(0xff34bacc);
  int languageIndex = 1;

  final Color _typeSelectedColor = Colors.orange;
  final Color _typeUnselectedColor = Colors.black;

  int typeIndex = 1;
  int wordCount = -1;
  List<String> wordList = [
    "一字部",
    "二字部",
    "三字部",
    "四字部",
    "五字部",
    "六字部",
    "七字部",
    "八字部",
    "九字部",
    "十字部",
    "十字以上"
  ];

  Language lang = Language.minnan;
  LibraryView libView = LibraryView.sortByDate;

  String selectedValue = "字數點歌";

  ScrollController controller = ScrollController(); // 宣告滑動控制器

  @override
  void initState() {
    super.initState();
    controller.addListener(() {}); // 宣告事件傾聽器
  }

  @override
  void dispose() {
    // 為了避免 memory leak
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            SizedBox(
              height: 90.h,
              child: ListView(
                padding: EdgeInsets.all(10.w),
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                      width: 94.w,
                      child: ElevatedButton(
                        child: Text(
                          "台語",
                          style: TextStyle(
                              fontSize: getAdaptiveTextSize(24, context).sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          // 陰影值
                          backgroundColor: MaterialStateProperty.all(
                              languageIndex == 1
                                  ? _selectedColor
                                  : _unselectedColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15.r) //設定圓角
                                  )),
                        ),
                        onPressed: () {
                          setState(() {
                            languageIndex = 1;
                            lang = Language.minnan;
                            libView = LibraryView.sortByDate;
                            typeIndex = 1;
                            wordCount = -1;
                          });
                        },
                      )),
                  SizedBox(width: 11.w),
                  SizedBox(
                      width: 94.w,
                      child: ElevatedButton(
                        child: Text(
                          "國語",
                          style: TextStyle(
                              fontSize: getAdaptiveTextSize(24, context).sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          // 陰影值
                          backgroundColor: MaterialStateProperty.all(
                              languageIndex == 2
                                  ? _selectedColor
                                  : _unselectedColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15.r) //設定圓角
                                  )),
                        ),
                        onPressed: () {
                          setState(() {
                            languageIndex = 2;
                            lang = Language.chinese;
                            libView = LibraryView.sortByDate;
                            typeIndex = 1;
                            wordCount = -1;
                          });
                        },
                      )),
                  SizedBox(width: 11.w),
                  SizedBox(
                      width: 94.w,
                      child: ElevatedButton(
                        child: Text(
                          "英語",
                          style: TextStyle(
                              fontSize: getAdaptiveTextSize(24, context).sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          // 陰影值
                          backgroundColor: MaterialStateProperty.all(
                              languageIndex == 3
                                  ? _selectedColor
                                  : _unselectedColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15.r) //設定圓角
                                  )),
                        ),
                        onPressed: () {
                          setState(() {
                            languageIndex = 3;
                            lang = Language.english;
                            libView = LibraryView.sortByDate;
                            typeIndex = 1;
                            wordCount = -1;
                          });
                        },
                      )),
                  SizedBox(width: 11.w),
                  SizedBox(
                      width: 94.w,
                      child: ElevatedButton(
                        child: Text(
                          "日語",
                          style: TextStyle(
                              fontSize: getAdaptiveTextSize(24, context).sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          // 陰影值
                          backgroundColor: MaterialStateProperty.all(
                              languageIndex == 4
                                  ? _selectedColor
                                  : _unselectedColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15.r) //設定圓角
                                  )),
                        ),
                        onPressed: () {
                          setState(() {
                            languageIndex = 4;
                            lang = Language.japanese;
                            libView = LibraryView.sortByDate;
                            typeIndex = 1;
                            wordCount = -1;
                          });
                        },
                      )),
                  SizedBox(width: 11.w),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        typeIndex = 1;
                        libView = LibraryView.sortByDate;
                        wordCount = -1;
                      });
                    },
                    child: Text('每月新歌',
                        style: TextStyle(
                            color: typeIndex == 1
                                ? _typeSelectedColor
                                : _typeUnselectedColor,
                            fontWeight: typeIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: getAdaptiveTextSize(22, context).sp)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        typeIndex = 2;
                        wordCount = -1;
                        libView = LibraryView.sortByPopularity;
                      });
                    },
                    child: Text('熱門排行',
                        style: TextStyle(
                            color: typeIndex == 2
                                ? _typeSelectedColor
                                : _typeUnselectedColor,
                            fontWeight: typeIndex == 2
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: getAdaptiveTextSize(22, context).sp)),
                  ),
                  DropdownButton<String?>(
                    value: "字數點歌",
                    style: TextStyle(
                      fontSize: getAdaptiveTextSize(22, context).sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value!;
                        int wordCountTmp = 1;
                        for (value in wordList) {
                          if (value == selectedValue) {
                            wordCount = wordCountTmp;
                          } else {
                            wordCountTmp++;
                          }
                        }
                      });
                    },
                    onTap: () {
                      setState(() {
                        typeIndex = 3;
                      });
                    },
                    items: [
                      "字數點歌",
                      "一字部",
                      "二字部",
                      "三字部",
                      "四字部",
                      "五字部",
                      "六字部",
                      "七字部",
                      "八字部",
                      "九字部",
                      "十字部",
                      "十字以上"
                    ]
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: getAdaptiveTextSize(18, context).sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            value: e,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                      child: FutureBuilder(
                    future: getSongs(
                        language: lang, view: libView, wordCount: wordCount),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        List<Song>? songs = snapshot.data;
                        return SizedBox(
                          width: 340.w,
                          child: ListView.builder(
                              key: PageStorageKey(lang.toString() +
                                  libView.toString() +
                                  wordCount.toString()),
                              // 根據條件存入滑動控制器的值
                              controller: controller,
                              itemCount: songs!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Consumer<DatabaseHelper>(
                                  builder: (context, dbInstance, child) {
                                    return FutureBuilder(
                                      future: dbInstance.getPlaylistOfSong(
                                          songs.elementAt(index)),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        final playlist = snapshot.data;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(
                                              MaterialPageRoute(
                                                builder: (context) => Player(
                                                    song:
                                                        songs.elementAt(index)),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            color: Colors.grey[350],
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 100.w,
                                                  child: ElevatedButton(
                                                    child: (playlist == null)
                                                        ? Text(
                                                            "+",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    getAdaptiveTextSize(
                                                                            30,
                                                                            context)
                                                                        .sp,
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : Icon(
                                                            Icons.check_rounded,
                                                            color:
                                                                Colors.orange,
                                                            size: 30.sp,
                                                          ),
                                                    style: ButtonStyle(
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(10), // 陰影值
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                        shape: MaterialStateProperty.all(
                                                            const CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                          style:
                                                              BorderStyle.none,
                                                        )) //設定圓角
                                                            )),
                                                    onPressed: () {
                                                      showDialog(
                                                        barrierColor: Colors
                                                            .black
                                                            .withOpacity(0.7),
                                                        context: context,
                                                        builder: (context) {
                                                          if (playlist ==
                                                              null) {
                                                            return Confirm(
                                                              highlightText:
                                                                  songs
                                                                      .elementAt(
                                                                          index)
                                                                      .name,
                                                              actionText:
                                                                  '新增到我的歌本',
                                                              onConfirm: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            AddToPlaylist(
                                                                      song: songs
                                                                          .elementAt(
                                                                              index),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            return Confirm(
                                                              highlightText:
                                                                  songs
                                                                      .elementAt(
                                                                          index)
                                                                      .name,
                                                              actionText:
                                                                  '從${playlist.name}移除嗎？',
                                                              onConfirm: () {
                                                                dbInstance
                                                                    .removeSongFromPlaylist(
                                                                  playlist:
                                                                      playlist,
                                                                  song: songs
                                                                      .elementAt(
                                                                          index),
                                                                );

                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            1500),
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                });

                                                                showDialog(
                                                                  barrierColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.7),
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Align(
                                                                      alignment:
                                                                          const Alignment(
                                                                              0,
                                                                              -0.1),
                                                                      child:
                                                                          AspectRatio(
                                                                        aspectRatio:
                                                                            214 /
                                                                                215,
                                                                        child:
                                                                            FractionallySizedBox(
                                                                          widthFactor:
                                                                              0.6,
                                                                          heightFactor:
                                                                              0.6,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(17.sp),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10.r),
                                                                              color: Colors.grey,
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                // Deleted icon
                                                                                Container(
                                                                                  width: 100.w,
                                                                                  height: 100.h,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: Colors.grey.shade600, width: 0.5),
                                                                                    shape: BoxShape.circle,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  child: Icon(
                                                                                    Icons.add,
                                                                                    color: Colors.grey,
                                                                                    size: 80.sp,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  '已從${playlist.name}移除',
                                                                                  style: TextStyle(
                                                                                    fontSize: 17.sp,
                                                                                    fontWeight: FontWeight.w600,
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
                                                          }
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        child: Text(
                                                          songs
                                                              .elementAt(index)
                                                              .name,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  getAdaptiveTextSize(
                                                                          16,
                                                                          context)
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 100.w,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  songs
                                                                      .elementAt(
                                                                          index)
                                                                      .artist,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: getAdaptiveTextSize(
                                                                            14,
                                                                            context)
                                                                        .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                Text(
                                                                  songs
                                                                      .elementAt(
                                                                          index)
                                                                      .songNumber,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: getAdaptiveTextSize(
                                                                            14,
                                                                            context)
                                                                        .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child:
                                                                FractionallySizedBox(
                                                              widthFactor: 0.95,
                                                              child:
                                                                  ElevatedButton(
                                                                child: Text(
                                                                  (playlist ==
                                                                          null)
                                                                      ? "▶    試 聽"
                                                                      : playlist
                                                                          .name,
                                                                  style: TextStyle(
                                                                      fontSize: getAdaptiveTextSize(
                                                                              18,
                                                                              context)
                                                                          .sp,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                style:
                                                                    ButtonStyle(
                                                                        padding:
                                                                            MaterialStateProperty
                                                                                .all(
                                                                          EdgeInsets.symmetric(
                                                                              vertical: 5.h,
                                                                              horizontal: 11.w),
                                                                        ),
                                                                        elevation: MaterialStateProperty.all((playlist ==
                                                                                null)
                                                                            ? 5
                                                                            : 0),
                                                                        // 陰影值
                                                                        backgroundColor: MaterialStateProperty.all((playlist ==
                                                                                null)
                                                                            ? const Color(
                                                                                0xff34bacc)
                                                                            : Colors
                                                                                .grey.shade400),
                                                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20.r)))),
                                                                onPressed:
                                                                    (playlist ==
                                                                            null)
                                                                        ? () {
                                                                            showDialog(
                                                                              barrierColor: Colors.black.withOpacity(0.7),
                                                                              context: context,
                                                                              builder: (context) => Player_window(song: songs.elementAt(index)),
                                                                            );
                                                                          }
                                                                        : null,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 7.w),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                          "有點問題 請重新整理",
                          style: TextStyle(
                            fontSize: getAdaptiveTextSize(18, context).sp,
                          ),
                        ));
                      } else {
                        return Center(
                            child: Text(
                          "等等",
                          style: TextStyle(
                            fontSize: getAdaptiveTextSize(18, context).sp,
                          ),
                        ));
                      }
                    },
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

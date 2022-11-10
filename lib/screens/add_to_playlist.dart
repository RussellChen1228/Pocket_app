import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/widgets/playlist_card.dart';
import 'package:pocket_ktv/model/reduce_string.dart';

class AddToPlaylist extends StatefulWidget {
  const AddToPlaylist({
    Key? key,
    required this.song,
  }) : super(key: key);

  final Song song;

  @override
  State<AddToPlaylist> createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  var db = DatabaseHelper.instance;
  final List<int> newPlaylist = [];

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top
            FractionallySizedBox(
              heightFactor: 380 / 812,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: AssetImage('assets/images/add_to_playlist_bg.png'),
                  ),
                ),
                // Song info
                child: _SongInfo(
                  song_name: song.name,
                  artist: song.artist,
                  song_number: song.songNumber,
                ),
              ),
            ),
            // Playlist display.
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 480 / 812,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      heightFactor: 0.85,
                      child: FutureBuilder<List<Playlist>>(
                        future: db.getAllPlaylist(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Playlist>? playlists = snapshot.data;
                            return GridView.builder(
                              primary: false,
                              itemCount: playlists!.length + 1,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 50.w,
                                childAspectRatio: 1.7,
                              ),
                              itemBuilder: (context, index) {
                                if (index < playlists.length) {
                                  return GestureDetector(
                                      child: PlaylistCard(
                                        name: playlists.elementAt(index).name,
                                        isNew: newPlaylist.contains(index),
                                      ),
                                      onTap: () {
                                        final playlist =
                                            playlists.elementAt(index);
                                        db.addSongToPlaylist(
                                          playlist: playlist,
                                          song: song,
                                        );

                                        // Display dialog showing song added.
                                        setState(() {
                                          showDialog(
                                            barrierDismissible: false,
                                            // Because we dismiss automatically.
                                            barrierColor:
                                                Colors.black.withOpacity(0.7),
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              });
                                              return _Dialog(
                                                song_name: song.name,
                                                playlist_name: playlist.name,
                                              );
                                            },
                                          );
                                        });
                                      });
                                } else {
                                  return GestureDetector(
                                    child: AddPlaylistCard(name: '+新增歌單'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CreatePlaylist(
                                            onConfirm: (String playlistName) {
                                              setState(() {
                                                db.addPlaylist(
                                                    Playlist(playlistName));
                                                final newPlaylistIndex =
                                                    playlists.length;
                                                newPlaylist.add(newPlaylistIndex);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('error'));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(-0.6, -0.28),
              child: Text(
                '新增到我的歌本',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Close
            Align(
              alignment: Alignment(0.9, -0.9),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  size: 30.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongInfo extends StatelessWidget {
  const _SongInfo({
    Key? key,
    required this.song_name,
    required this.artist,
    required this.song_number,
  }) : super(key: key);

  final String song_name;
  final String artist;
  final String song_number;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 280 / 375,
        child: AspectRatio(
          aspectRatio: 280 / 90,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Song name
                Text(
                  song_name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      artist,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(
                      width: 29.65.w,
                    ),
                    Text(
                      song_number.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreatePlaylist extends StatefulWidget {
  CreatePlaylist({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  void Function(String) onConfirm;

  @override
  State<CreatePlaylist> createState() => CreatePlaylistState();
}

class CreatePlaylistState extends State<CreatePlaylist> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isButtonDisabled = true;
  bool _isTyping = false;
  String hintText = "輸入新歌本名稱";
  
  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isTyping = true;
          hintText = "";
        });
      }
      else {
        setState(() {
          _isTyping = false;
          hintText = "輸入新歌本名稱";
        });
      }
    });
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
                  '為您的新歌本命名',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextField(
                  focusNode: _focusNode,
                  onSubmitted: (text) {
                    if (!_isButtonDisabled) {
                      widget.onConfirm(text);
                      Navigator.pop(context, '確定');
                    }
                  },
                  onChanged: (text) {
                    if (text != "") {
                      setState(() {
                        _isButtonDisabled = false;
                      });
                    }
                    else {
                      setState(() {
                        _isButtonDisabled = true;
                      });
                    }
                  },
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
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isButtonDisabled ? null : () {
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

class _Dialog extends StatelessWidget {
  const _Dialog(
      {Key? key, required this.song_name, required this.playlist_name})
      : super(key: key);
  final String song_name;
  final String playlist_name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.1),
      child: FractionallySizedBox(
        heightFactor: 0.4,
        widthFactor: 0.5,
        child: AspectRatio(
          aspectRatio: 214 / 215,
          child: Container(
            // padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey,
            ),
            child: Column(
              children: [
                // icon
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade600, width: 1.w),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 90.r,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Text(
                  '「${Reduce.reduce(song_name, 13)}」',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '已加入${Reduce.reduce(playlist_name, 10)}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
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

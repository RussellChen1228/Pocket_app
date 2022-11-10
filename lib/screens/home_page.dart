import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/widgets/playlist_card.dart';
import 'package:pocket_ktv/screens/add_to_playlist.dart';
import 'package:pocket_ktv/screens/playlist_page.dart';
import 'package:pocket_ktv/screens/search_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = DatabaseHelper.instance;
  final List<int> newPlaylist = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 37.w),
        child: Column(
          children: [
            SizedBox(height: 59.h),
            Container(
              height: 210.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar_background.png'),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 79.r,
                  foregroundImage: const AssetImage('assets/images/avatar.jpg'),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              '早安，阿珠',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 19.h),
            SearchBar(),
            SizedBox(height: 45.h),
            const _PlaylistDivider(),
            SizedBox(height: 19.h),
            Expanded(
              child: Consumer<DatabaseHelper>(
                builder: (context, dbInstance, child) {
                  return FutureBuilder<List<Playlist>>(
                    future: dbInstance.getAllPlaylist(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Playlist>? playlists = snapshot.data;
                        return GridView.builder(
                          primary: false,
                          itemCount: playlists!.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 138 / 86,
                          ),
                          itemBuilder: (context, index) {
                            if (index < playlists.length) {
                              return GestureDetector(
                                child: PlaylistCard(
                                  name: playlists.elementAt(index).name,
                                  isNew: newPlaylist.contains(index),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PlaylistPage(
                                        playlist: playlists.elementAt(index),
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    newPlaylist.clear();
                                  });
                                },
                              );
                            } else {
                              return GestureDetector(
                                child: const AddPlaylistCard(name: '+新增歌單'),
                                onTap: () {
                                  setState(() {
                                    showDialog(
                                      barrierColor: Colors.grey[700],
                                      context: context,
                                      builder: (context) => CreatePlaylist(
                                        onConfirm: (String playlistName) {
                                          setState(() {
                                            dbInstance.addPlaylist(
                                                Playlist(playlistName));
                                            final newPlaylistIndex =
                                                playlists.length;
                                            newPlaylist.add(newPlaylistIndex);
                                          });
                                        },
                                      ),
                                    );
                                  });
                                },
                              );
                            }
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('error'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dialog extends StatefulWidget {
  _Dialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  void Function(String) onConfirm;

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 250.h,
        width: 500.w,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              '為您的新歌本命名',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Material(
              child: TextField(
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
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  // TODO: Align label text center.
                  alignLabelWithHint: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: '輸入新歌本名稱',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            TextButton(
              onPressed: () {
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
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistDivider extends StatelessWidget {
  const _PlaylistDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              color: Colors.grey[300],
              width: 80.w,
              padding: EdgeInsets.all(3.r),
              child: Center(
                child: Text(
                  '我的歌本',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          color: Colors.grey[300],
          height: 3.h,
        ),
      ],
    );
  }
}

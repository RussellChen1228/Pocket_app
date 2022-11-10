import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/local_library.dart';
import 'package:pocket_ktv/screens/home_page.dart';
import 'package:pocket_ktv/screens/library_page.dart';
import 'package:pocket_ktv/screens/search_page.dart';
import 'package:provider/provider.dart';

void main() async {
  // Force portrait mode.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // HACK: Init db (create table) before homepage is rendered
  // prevent UI crashing after installing the app.
  //
  // Maybe I misuse Provider (should use FutureProvider) or sqflite?
  // A further investigation and permanent fix is required.
  await DatabaseHelper.instance.database;
  // Create default playlist.
  final playlists = await DatabaseHelper.instance.getAllPlaylist();
  if (playlists.isEmpty) {
    await DatabaseHelper.instance.addPlaylist(Playlist('台語歌本'));
    await DatabaseHelper.instance.addPlaylist(Playlist('國語歌本'));
    await DatabaseHelper.instance.addPlaylist(Playlist('日語歌本'));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DatabaseHelper>(
      create: (context) => DatabaseHelper.instance,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
                data: data.copyWith(textScaleFactor: 1),
                child: child as Widget);
          },
          home: const MainPage(),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _selectedIndex = 0;

  final _navigatorKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  
  static const _tabs = [
    const HomePage(),
    const LibraryPage(),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      // Be aware of the not operation.
      onWillPop: () async =>
          !await _navigatorKeys[_selectedIndex].currentState!.maybePop(),
      child: Scaffold(
        body: Navigator(
          key: _navigatorKeys[_selectedIndex],
          // Generate initial route.
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(builder: (context) => _tabs[_selectedIndex]);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey.shade800,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 50.w,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/images/home_gray.png'),
              ),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/images/library_gray.png'),
              ),
              label: 'library',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/images/search_gray.png'),
              ),
              label: 'search',
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final tablePlaylist = 'playlist';
final colPlaylistId = 'id';
final colPlaylistName = 'name';

final tableSong = 'song';
final colSongId = 'id';
final colSongName = 'name';
final colSongArtist = 'artist';
final colSongNumber = 'number';
final colSongYtUrl = 'yt_url';
final colSongLyric = 'lyric';
final colSongPlaylistId = 'playlist_id';
final colSongLanguage = 'language';

// A singleton database helper.
//
// ```
// var db = Database.instance;
// ```
class DatabaseHelper extends ChangeNotifier {
  // Actual database file stored in the device.
  static final _name = 'pocket_ktv.db';

  // Increment this version when you need to change the schema.
  static final _version = 1;

  // Make a singleton class.
  DatabaseHelper._privateConstructor();

  static final instance = DatabaseHelper._privateConstructor();

  // Only allow a single connection to the database.
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, _name);
    return await openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create playlist table.
    await db.execute('''
      CREATE TABLE $tablePlaylist (
        $colPlaylistId INTEGER PRIMARY KEY,
        $colPlaylistName TEXT NOT NULL
      )
    ''');

    // Create song table.
    await db.execute('''
      CREATE TABLE $tableSong (
        $colSongId INTEGER PRIMARY KEY,
        $colSongName TEXT NOT NULL,
        $colSongArtist TEXT NOT NULL,
        $colSongNumber INTEGER NOT NULL,
        $colSongYtUrl TEXT NOT NULL,
        $colSongLyric TEXT NOT NULL,
        $colSongPlaylistId INTEGER NOT NULL,
        $colSongLanguage TEXT NOT NULL
      )
    ''');
  }

  Future<List<Playlist>> getAllPlaylist() async {
    var db = await database;

    var maps = await db!.query(
      tablePlaylist,
      columns: [colPlaylistId, colPlaylistName],
    );

    return maps.map((e) => Playlist.fromMap(e)).toList();
  }

  Future<Playlist> addPlaylist(Playlist playlist) async {
    var db = await database;

    playlist.id = await db!.insert(tablePlaylist, playlist.toMap());
    return playlist;
  }

  Future<List<Song>> getSongsOfPlaylist(Playlist playlist) async {
    var db = await database;

    var maps = await db!.query(
      tableSong,
      columns: [
        colSongId,
        colSongName,
        colSongArtist,
        colSongNumber,
        colSongYtUrl,
        colSongLyric,
        colSongLanguage,
      ],
      where: '$colSongPlaylistId = ?',
      whereArgs: [playlist.id],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future<Song> addSongToPlaylist(
      {required Playlist playlist, required Song song}) async {
    var db = await database;

    final map = song.toMap();
    map[colSongPlaylistId] = playlist.id;
    song.id = await db!.insert(tableSong, map);

    notifyListeners();
    return song;
  }

  Future<int> removeSongFromPlaylist(
      {required Playlist playlist, required Song song}) async {
    var db = await database;
    final val = await db!.delete(
      tableSong,
      where: '$colSongNumber = ?',
      whereArgs: [song.songNumber],
    );

    notifyListeners();
    return val;
  }

  Future<void> modifyPlayListName(
      {required Playlist playlist, required String newPlayListName}) async {
    var db = await database;
    playlist.name = newPlayListName;
    await db?.update(tablePlaylist, playlist.toMap(),
        where: '$colPlaylistId = ?', whereArgs: [playlist.id]);
    notifyListeners();
  }

  Future<Playlist?> getPlaylistOfSong(Song song) async {
    // Or use nested query:
    // SELECT * FROM playlist WHERE id = (SELECT playlist_id FROM song WHERE name = '傷心證明書';
    var db = await database;
    var maps = await db!.query(
      tableSong,
      columns: [colSongPlaylistId],
      where: '$colSongName = ? AND $colSongNumber = ?',
      whereArgs: [song.name, song.songNumber],
    );

    if (maps.isEmpty) {
      return null;
    } else {
      final playlistId = maps.elementAt(0)[colSongPlaylistId];
      var maps2 = await db.query(
        tablePlaylist,
        columns: [colPlaylistName],
        where: '$colPlaylistId = ?',
        whereArgs: [playlistId],
      );
      if (maps2.isEmpty) {
        throw Exception('Playlist name and id mismatch.');
      }
      return Playlist.fromMap(maps2.elementAt(0));
    }
  }

  Future<List<Song>> searchSongs(Playlist playlist, String songName) async {
    final songs = await getSongsOfPlaylist(playlist);
    final fuzzySearch = (Song song) {
      // TODO: impl local db fuzzy search.
      return song.name.toLowerCase() == songName.toLowerCase();
    };
    //debug
    for (final song in songs) {
      print(song.name);
    }
    await Future.delayed(Duration(seconds: 2)); //debug
    return songs.where(fuzzySearch).toList();
  }
}

class Playlist {
  int? id;
  late String name;

  Playlist(this.name);

  Playlist.fromMap(Map<String, dynamic> map) {
    id = map[colPlaylistId];
    name = map[colPlaylistName];
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      colPlaylistName: name,
    };

    map[colPlaylistId] = id;

    return map;
  }
}

class Song {
  int? id;
  late final String name;
  late final String artist;
  late final String songNumber;
  late final String youtubeUrl;
  late final String lyric;
  late final String language;

  Song({
    required this.name,
    required this.artist,
    required this.songNumber,
    required this.youtubeUrl,
    required this.lyric,
    required this.language,
  });

  Song.fromMap(Map<String, dynamic> map) {
    id = map[colSongId];
    name = map[colSongName];
    artist = map[colSongArtist];
    songNumber = map[colSongNumber].toString();
    youtubeUrl = map[colSongYtUrl];
    lyric = map[colSongLyric];
    language = map[colSongLanguage];
  }

  Song.fromJson(Map<String, dynamic> json) {
    name = json['song_name'];
    artist = json['artist'];
    songNumber = json['song_number'].toString();
    language = json['language'];
    youtubeUrl = json['url'];

    if (json['lyric_dynamic'] == null) {
      lyric = json['lyric'];
    } else {
      lyric = json['lyric_dynamic'];
    }
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      colSongName: name,
      colSongArtist: artist,
      colSongNumber: songNumber,
      colSongYtUrl: youtubeUrl,
      colSongLyric: lyric,
      colSongLanguage: language,
    };

    map[colSongId] = id;

    return map;
  }

  bool get hasDynamicLyric {
    return lyric.contains('[00:');
  }
}

class Match {
  late Song song;
  late double score;

  Match({required this.song, required this.score});

  Match.fromJson(Map<String, dynamic> json) {
    song = Song.fromJson(json);
    score = json['score'].toDouble();
  }
}

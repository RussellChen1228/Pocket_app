import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:pocket_ktv/model/possible_names.dart';

class SpeechToText {
  //@@@ + SET名(EX:S07) + (8-length(set名))個空白字元
  //若透過Android手機傳送，則設為"A"；若透過網頁傳送，則設為"W"
  static const String label = "A";
  static const String modelname = "Minnan\u0000\u0000";
  static const serviceId = "0007"; // Kaldi service id for karaoke.

  //由SERVER端提供之token
  static const String token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJpZCI6NzgsInVzZXJfaWQiOiIwIiwic2VydmljZV9pZCI6IjMiLCJzY29wZXMiOiI5OTk5OTk5OTkiLCJzdWIiOiIiLCJpYXQiOjE1NDEwNjUwNzEsIm5iZiI6MTU0MTA2NTA3MSwiZXhwIjoxNjk4NzQ1MDcxLCJpc3MiOiJKV1QiLCJhdWQiOiJ3bW1rcy5jc2llLmVkdS50dyIsInZlciI6MC4xfQ.K4bNyZ0vlT8lpU4Vm9YhvDbjrfu_xuPx8ygoKsmovRxCCUbj4OBX4PzYLZxeyVF-Bvdi2-wphGVEjz8PsU6YGRSh5SDUoHjjukFesUr8itMmGfZr4BsmEf9bheDm65zzbmbk7EBA9pn1TRimRmNG3XsfuDZvceg6_k6vMWfhQBA";

  static Future<PossibleNames> speech2text(String path) async {
    final payload = await _packagePayload(path);
    final completer = Completer<PossibleNames>();

    final socket = await Socket.connect("140.116.245.149", 2887);
    print('Connected to stt server.');

    socket.add(payload);
    socket.flush();

    socket.listen(
      (databyte) {
        var dataString = utf8.decode(databyte);
        print('Data from socket: $dataString');
        Map response = jsonDecode(dataString.replaceAll("'", '"'));
        final chiTxt = response['0'];
        final taiTxt = response['1'];
        final possibleNames = PossibleNames(name1: taiTxt, name2: chiTxt);
        completer.complete(possibleNames);
      },
      onError: (error) {
        completer.completeError(error);
        print("socket無法連接: $error");
      },
      onDone: () {
        print('connection closed');
      }
    );

    return completer.future;
  }

  static Future<List<int>> _packagePayload(String path) async {
    String outmsg = token + "@@@" + modelname + label + serviceId;

    //將outmsg轉成byte[]
    List<int> outmsgByte = utf8.encode(outmsg);
    //將語音檔案轉成byte[]，使用下方convert(String path) function
    List<int> waveByte = await _convert(path);
    //將outmsg以及語音檔案兩個陣列串接，使用下方 byteconcate(byte[] a, byte[] b) function
    List<int> outbyte = _byteconcate(outmsgByte, waveByte);

    //用於計算outmsg和語音檔案串接後的byte數
    var g = Uint32List(4);
    // limit environment sdk: 2.12=>2.14
    g[0] = (outbyte.length & 0xff000000) >>> 24;
    g[1] = (outbyte.length & 0x00ff0000) >>> 16;
    g[2] = (outbyte.length & 0x0000ff00) >>> 8;
    g[3] = (outbyte.length & 0x000000ff);

    return _byteconcate(g, outbyte);
  }

//用於串接兩個byte[]
  static List<int> _byteconcate(List<int> a, List<int> b) {
    List<int> result = Int32List(a.length + b.length);

    /// Java的System.arrayCopy(source, sourceOffset, target, targetOffset, length)
    /// = target.setRange(targetOffset, targetOffset + length, source, sourceOffset);
    result.setRange(
        0, a.length, a, 0); // =System.arraycopy(a, 0, result, 0, a.length);
    result.setRange(a.length, a.length + b.length, b,
        0); // =System.arraycopy(b, 0, result, a.length, b.length);
    return result;
  }

//用於將檔案轉換成byte，輸入為檔案路徑，輸出為byte[]
  static Future<List<int>> _convert(path) async {
    var file = File(path);
    var bytes = await file.readAsBytes();
    return bytes;
  }
}

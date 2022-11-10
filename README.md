# Pocket KTV
An app that keep all your favorite KTV song in your packet including MV, 
song number, lyrics.

## Release Android APK
- Generate APK (the output APK will be at `[project]/build/app/outputs/apk/release/`).

```shell
# cd to project dir
$ flutter build apk --split-per-abi
```
- Install APK on Android device via connection.

```shell
# Connect your device.
# cd to project dir
$ flutter install
```
- Or you can download APK on you phone and install it. 
  (**Make sure you download the right APK for your phone's architecture**)
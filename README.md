# Full Screen Video Player

Full screen video player, with convenient management tools

![](https://github.com/Leeeeerich/full_screen_video_player/blob/master/arts/management_interface.png)

You can scroll video using horizontal drag on screen:
![](https://github.com/Leeeeerich/full_screen_video_player/blob/master/arts/management_tools_scroll.gif)
![](https://github.com/Leeeeerich/full_screen_video_player/blob/master/arts/without_management_tools_scroll.gif)

### Getting Started

## How use:

Create FullScreenVideoPlayer and receive map with you movies:

{
    "Movie name": "link",
    "Movie name 2" "link",
    ...
}

and don't forgot receive selected video: "Movie name 2":

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FullScreenVideoPlayer({"movie": "https://cutt.ly/sykO1g8"}, "movie",),
    );
  }
}

You can change progress, buffering, background and texts colors.
You can change text sizes title video and label video.

## How supported formats? It library using [video_player](https://pub.dev/packages/video_player#supported-formats).

## Platforms:
Android
iOS - not tested, in future
web - not tested, in future

# Android
Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Third-party libraries used:
[flutter_svg](https://pub.dev/packages/flutter_svg)
[fluttertoast](https://pub.dev/packages/fluttertoast)
[flutter_spinkit](https://pub.dev/packages/flutter_spinkit)

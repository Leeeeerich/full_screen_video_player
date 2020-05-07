import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullscreenvideoplayer/src/ui_utils.dart';
import 'package:fullscreenvideoplayer/src/video_progress_with_label.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  /// Map (Name of video, url on video)
  final Map<String, String> urls;

  /// Key of video selected
  final String keyOfVideoSelected;

  /// Video progress color
  final Color videoProgressColor;

  /// Color buffered video
  final Color bufferedProgressColor;

  /// Background color video progress indicator
  final Color backgroundProgressColor;

  /// Text color
  final Color labelVideoProgressTextColor;

  /// Video name text color
  final Color titleTextColor;

  /// Buttons icons color
  final Color buttonsColor;

  /// Text size video progress indicator label
  final double labelFontSize;

  /// Video name text size
  final double titleTextSize;

  /// Duration fade in and fade out management tools animation
  final Duration fadeInFadeOutManagementToolsDuration;

  /// Duration of showing management tools
  final Duration showingManagementToolsDuration;

  FullScreenVideoPlayer(this.urls, this.keyOfVideoSelected,
      {this.videoProgressColor = const Color.fromARGB(255, 0, 100, 0),
      this.bufferedProgressColor = const Color.fromARGB(30, 0, 255, 0),
      this.backgroundProgressColor = const Color.fromARGB(35, 255, 255, 255),
      this.labelVideoProgressTextColor = const Color.fromARGB(123, 255, 255, 255),
      this.titleTextColor = const Color.fromARGB(123, 255, 255, 255),
      this.buttonsColor = const Color.fromARGB(123, 255, 255, 255),
      this.labelFontSize = 36,
      this.titleTextSize = 18,
      this.fadeInFadeOutManagementToolsDuration =
          const Duration(milliseconds: 300),
      this.showingManagementToolsDuration = const Duration(seconds: 5),
      Key key})
      : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  static const double ICONS_MANAGEMENT_TOOLS_SIZE = 150.0;

  VideoPlayerController _controller;
  String _titleVideoName = "";
  Future<void> _initializeVideoPlayerFuture;
  int step;
  var isContinuePlaying = false;
  GlobalKey _globalKey = GlobalKey();

  Timer _showingManagementToolsTimer;

  bool _visibilityLabel = false;
  bool _isVisibleTools = false;

  @override
  void initState() {
    _playVideoFromNetwork(
        widget.keyOfVideoSelected, widget.urls[widget.keyOfVideoSelected]);
    _initializeVideoPlayerFuture = _controller.initialize();

    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _showingManagementToolsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _getManagementTools(_isVisibleTools, _getPlayerFrame());
          } else {
            return Center(
                child: SpinKitCubeGrid(size: 51.0, color: Colors.blue));
          }
        },
      ),
    );
  }

  _playVideoFromNetwork(String videoName, String url) {
    if (_controller != null) {
      _controller.dispose();
    }
    _titleVideoName = videoName;
    _controller = VideoPlayerController.network(url);
  }

  _setOrUpdateShowingManageToolsTimer() {
    _showingManagementToolsTimer = _getResetTimer();
  }

  Timer _getResetTimer() {
    if (_showingManagementToolsTimer != null) {
      _showingManagementToolsTimer.cancel();
    }
    return Timer(widget.showingManagementToolsDuration, () {
      _hideManagementTools();
    });
  }

  _showManagementTools() {
    setState(() {
      _visibilityLabel = true;
      _isVisibleTools = true;
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
    _setOrUpdateShowingManageToolsTimer();
  }

  _hideManagementTools() {
    setState(() {
      SystemChrome.setEnabledSystemUIOverlays([]);
      _visibilityLabel = false;
      _isVisibleTools = false;
    });
    _showingManagementToolsTimer = null;
  }

  Widget _getPlayerFrame() => Container(
      key: _globalKey,
      decoration: BoxDecoration(color: Colors.black),
      alignment: Alignment.center,
      child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller)));

  Widget _getManagementTools(bool isVisibleTools, Widget child) {
    return Stack(children: <Widget>[
      child,
      _getGestureDetector(
        Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(isVisibleTools ? 123 : 0, 0, 0, 0)),
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IgnorePointer(
                      ignoring: true,
                      child: AnimatedOpacity(
                          opacity: isVisibleTools ? 1 : 0,
                          duration: widget.fadeInFadeOutManagementToolsDuration,
                          child: _getTitleOfVideo())),
                  _getButtonsOfManagements(),
                  _getVideoProgress()
                ])),
      ),
    ]);
  }

  Widget _getTitleOfVideo() => Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        padding: EdgeInsets.fromLTRB(6, 2, 2, 2),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: getColorFromHex("#B34A4444"),
        ),
        child: Text(
          _titleVideoName,
          style: TextStyle(
            fontSize: widget.titleTextSize,
            color: getColorFromHex("#E2E2E2"),
          ),
        ),
      );

  Widget _getButtonsOfManagements() => Expanded(
      child: IgnorePointer(
          ignoring: !_isVisibleTools,
          child: AnimatedOpacity(
              opacity: _isVisibleTools ? 1 : 0,
              duration: widget.fadeInFadeOutManagementToolsDuration,
              child: Row(
                  key: UniqueKey(),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        iconSize: ICONS_MANAGEMENT_TOOLS_SIZE,
                        onPressed: () {
                          _setOrUpdateShowingManageToolsTimer();
                        },
                        icon: Container(
                            height: ICONS_MANAGEMENT_TOOLS_SIZE,
                            width: ICONS_MANAGEMENT_TOOLS_SIZE,
                            child: SvgPicture.asset("assets/icons/ic_prev.svg",
                                color: widget.buttonsColor))),
                    IconButton(
                        iconSize: ICONS_MANAGEMENT_TOOLS_SIZE,
                        onPressed: () {
                          _setOrUpdateShowingManageToolsTimer();
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                          setState(() {});
                        },
                        icon: Container(
                            height: ICONS_MANAGEMENT_TOOLS_SIZE,
                            width: ICONS_MANAGEMENT_TOOLS_SIZE,
                            child: SvgPicture.asset(
                                _controller.value.isPlaying
                                    ? "assets/icons/ic_pause.svg"
                                    : "assets/icons/ic_play.svg",
                                color: widget.buttonsColor))),
                    IconButton(
                        iconSize: ICONS_MANAGEMENT_TOOLS_SIZE,
                        onPressed: () {
                          _setOrUpdateShowingManageToolsTimer();
                        },
                        icon: Container(
                            height: ICONS_MANAGEMENT_TOOLS_SIZE,
                            width: ICONS_MANAGEMENT_TOOLS_SIZE,
                            child: SvgPicture.asset("assets/icons/ic_next.svg",
                                color: widget.buttonsColor)))
                  ]))));

  GestureDetector _getGestureDetector(Widget child) {
    return GestureDetector(
      child: child,
      onTap: () {
        _showManagementTools();
      },
      onHorizontalDragStart: (start) {
        RenderBox box = _globalKey.currentContext.findRenderObject();
        step = _controller.value.duration.inMilliseconds ~/ box.size.width;

        if (_controller.value.isPlaying) {
          isContinuePlaying = true;
          _controller.pause();
        }
        if (_isVisibleTools) {
          _showingManagementToolsTimer.cancel();
        }
        setState(() {
          _visibilityLabel = true;
        });
      },
      onHorizontalDragUpdate: (scrollPosition) {
        setState(() {
          _visibilityLabel = true;
        });
        var position = _controller.value.position.inMilliseconds;
        var newPosition = position + (step * scrollPosition.delta.dx);
        _controller.seekTo(Duration(milliseconds: newPosition.toInt()));
      },
      onHorizontalDragEnd: (end) {
        if (isContinuePlaying) {
          _controller.play();
          isContinuePlaying = false;
        }
        if (_isVisibleTools) {
          _setOrUpdateShowingManageToolsTimer();
        }
        setState(() {
          _visibilityLabel = _isVisibleTools;
        });
      },
    );
  }

  Widget _getVideoProgress() {
    return IgnorePointer(
        ignoring: !(_isVisibleTools || _visibilityLabel),
        child: AnimatedOpacity(
            opacity: _isVisibleTools || _visibilityLabel ? 1 : 0,
            duration: widget.fadeInFadeOutManagementToolsDuration,
            child: Container(
                alignment: Alignment.bottomCenter,
                child: VideoProgressLabelIndicator(
                    _controller,
                    widget.videoProgressColor,
                    widget.bufferedProgressColor,
                    widget.backgroundProgressColor,
                    widget.labelVideoProgressTextColor,
                    widget.labelFontSize))));
  }
}

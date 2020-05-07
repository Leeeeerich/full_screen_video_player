import 'package:flutter/material.dart';
import 'package:fullscreenvideoplayer/src/ui_utils.dart';
import 'package:video_player/video_player.dart';

class VideoProgressLabelIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final Color videoProgressColor;
  final Color bufferedProgressColor;
  final Color backgroundProgressColor;
  final Color labelFontColor;

  final double labelFontSize;

  VideoProgressLabelIndicator(
      this.controller,
      this.videoProgressColor,
      this.bufferedProgressColor,
      this.backgroundProgressColor,
      this.labelFontColor,
      this.labelFontSize,
      {Key key});

  @override
  _VideoProgressLabelIndicator createState() => _VideoProgressLabelIndicator();
}

class _VideoProgressLabelIndicator extends State<VideoProgressLabelIndicator> {

  VoidCallback listener;

  _VideoProgressLabelIndicator() {
    listener = () {
      if (!mounted) {
        return;
      } else {
        setState(() {});
      }
    };
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    controller.addListener(listener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;

    progressIndicator = Stack(
      children: <Widget>[
        SizedBox(
            height: widget.labelFontSize * 1.25,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                  playedColor: widget.videoProgressColor,
                  bufferedColor: widget.bufferedProgressColor,
                  backgroundColor: widget.backgroundProgressColor),
            )),
        _label()
      ],
    );

    return progressIndicator;
  }

  Widget _label() {
    return IgnorePointer(
        child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      child: Text(
        controller.value.position != null
            ? printDuration(controller.value.position) +
                '/' +
                printDuration(controller.value.duration)
            : "00:00/00:00",
        style: TextStyle(
          fontSize: widget.labelFontSize,
          color: widget.labelFontColor,
        ),
      ),
    ));
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }
}

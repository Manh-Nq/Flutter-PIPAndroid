import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tub_app_overlays/pip_flutter.dart';
import 'package:video_player/video_player.dart';

class VideoOverlays extends StatefulWidget {
  const VideoOverlays({Key? key}) : super(key: key);

  @override
  State<VideoOverlays> createState() => _VideoOverlaysState();
}

class _VideoOverlaysState extends State<VideoOverlays> {
  Color color = const Color(0xFFFFFFFF);
  late VideoPlayerController _controller;
  String pos = "";
  bool isInited = false;

  @override
  void initState() {
    super.initState();
    PipFlutter.overlayListener.listen(
      (event) async {
        if (event.toString().contains("{")) {
          var result = fromJson(event);
          // print("URL: ${result[0]}---POSITION: ${result[1]} ");
          _controller = VideoPlayerController.asset(result[0])
            ..addListener(
              () async {
                var curPos =
                    _controller.value.position.inMilliseconds.toString();
                setState(() {
                  pos = curPos;
                });
                await PipFlutter.pushArguments(
                    _controller.value.position.inMilliseconds);
              },
            )
            ..initialize().then(
              (value) {
                setState(
                  () {
                    pos = result[1].toString();
                    _controller.seekTo(Duration(milliseconds: result[1]));
                    isInited = true;
                  },
                );
              },
            );
        } else if (event == "dispose") {
          _controller.dispose();
          isInited = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isInited
            ? body(_controller)
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget body(VideoPlayerController controller) {
    IconData icon = controller.value.isPlaying ? Icons.pause : Icons.play_arrow;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  print("ontab play/pause");
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                },
                child: Icon(
                  color: Colors.red,
                  icon,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () async {
              await PipFlutter.close();
            },
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 50,
            ),
          ),
        ),
        Positioned(
            top: 16,
            left: 16,
            child: Text(
              pos,
              style: TextStyle(fontSize: 20, color: Colors.white),
            )),
      ],
    );
  }

  @override
  void deactivate() {
    print("deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("dispose");
    _controller.dispose();
    super.dispose();
  }
}

extension Calculate on int {
  int dpToPx(double density) {
    return (this * density).toInt();
  }
}

List<dynamic> fromJson(Map<dynamic, dynamic> json) {
  var url = json['url'];
  var position = json['position'];

  return [url, position];
}

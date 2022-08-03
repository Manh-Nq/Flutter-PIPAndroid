
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
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/video_test01.mp4')
      ..addListener(() {
        // print("ManhNQ  -- addListener");
        PipFlutter.putArguments("addListener from VideoOverlays");
      })
      ..initialize().then((value) {
        setState(() {});
      });

    PipFlutter.overlayListener.listen((event) {
      if(event is ListenOverlay){
        print("VideoOverlays $event");
      }
      print("[VideoOverlays]- $event");
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData icon =
    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow;
    return Scaffold(
      body: InkWell(
        onTap: (){
          setState(() {
            try {
              print("play------");
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            } catch (error) {
              print(error);
            }
          });
        },
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
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
                    if(_controller.value.isPlaying){
                      _controller.pause();
                    }else{
                      _controller.play();
                    }
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(icon),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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

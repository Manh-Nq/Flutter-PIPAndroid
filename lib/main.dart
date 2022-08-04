import 'package:flutter/material.dart';
import 'package:tub_app_overlays/pip_flutter.dart';
import 'package:tub_app_overlays/video_overlay.dart';
import 'package:video_player/video_player.dart';

import 'elements.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void showPIPScreen() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoOverlays(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AppHome());
  }
}

class AppHome extends StatefulWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  late VideoPlayerController _controller;
  var currentPosition = "00:00:00";
  String url = 'assets/videos/video_test03.mp4';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset(url)
      ..addListener(() async {
        setState(() {
          currentPosition =
              _controller.value.position.inMilliseconds.toString();
        });
      })
      ..initialize().then((value) {
        setState(() {});
      });

    PipFlutter.overlayListener.listen((event) async {
      if (event != "close") {
        _controller.seekTo(Duration(milliseconds: event));
      } else {
        print("[AppHome] - Close");
        await PipFlutter.close();
        //p
        await PipFlutter.pushArguments("close");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var density = MediaQuery.of(context).devicePixelRatio;
    return videoScreen(
        controller: _controller,
        curr: currentPosition,
        close: () async {
          await PipFlutter.close();
        },
        showOverlays: () async {
          _controller.pause();
          var isActive = await PipFlutter.isActive();
          if (!isActive) {
            await PipFlutter.show(
                enableDrag: true,
                overlayTitle: "com.example.tub_app_overlays",
                overlayContent: 'Overlay Enabled',
                flag: OverlayFlag.defaultFlag,
                alignment: OverlayAlignment.centerLeft,
                visibility: NotificationVisibility.visibilityPrivate,
                positionGravity: PositionGravity.auto,
                width: 300.dpToPx(density),
                height: (300 * 9 ~/ 16).dpToPx(density));

            await PipFlutter.pushArguments({
              "url": url,
              "position": _controller.value.position.inMilliseconds,
            });
          }
        });
  }
}

Widget videoScreen({
  required VideoPlayerController controller,
  required String curr,
  required VoidCallback close,
  required VoidCallback showOverlays,
}) {
  return SafeArea(
    child: Material(
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              GestureDetector(
                  onTap: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  }, // Image tapped
                  child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller))),
              Text(
                curr,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    showOverlays();
                  },
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.settings_overscan_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: InkWell(
                  onTap: () {
                    close();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          Expanded(flex: 1, child: listVideos(fakeItems()))
        ],
      ),
    ),
  );
}

Widget mainContainer(BuildContext context) {
  var density = MediaQuery.of(context).devicePixelRatio;
  return Container(
    color: Colors.white,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () async {
              await PipFlutter.show(
                  enableDrag: true,
                  overlayTitle: "com.example.tub_app_overlays",
                  overlayContent: 'Overlay Enabled',
                  flag: OverlayFlag.defaultFlag,
                  alignment: OverlayAlignment.centerLeft,
                  visibility: NotificationVisibility.visibilityPrivate,
                  positionGravity: PositionGravity.auto,
                  width: 300.dpToPx(density),
                  height: (300 * 9 ~/ 16).dpToPx(density));
            },
            child: Text("show")),
        TextButton(
            onPressed: () async {
              await PipFlutter.close();
            },
            child: Text("close")),
        TextButton(
            onPressed: () async {
              await PipFlutter.pushArguments("this is Data from appHome");
            },
            child: Text("share")),
        TextButton(
            onPressed: () async {
              var rs = await PipFlutter.requestP();
              print("${rs}");
            },
            child: Text("request permission")),
        TextButton(
            onPressed: () async {
              var rs = await PipFlutter.isActive();
              print("$rs");
            },
            child: Text("check service active")),
      ],
    ),
  );
}

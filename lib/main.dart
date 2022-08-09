import 'package:flutter/material.dart';
import 'package:tub_app_overlays/lifecycle_event_handler.dart';
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
  var currentPosition = "0";
  LifecycleEventHandler? listener;
  var active = false;
  String url = 'assets/videos/video_test03.mp4';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset(url)
      ..addListener(
        () async {
          setState(
            () {
              currentPosition =
                  _controller.value.position.inMilliseconds.toString();
            },
          );
        },
      )
      ..initialize().then(
        (value) {
          setState(
            () {},
          );
        },
      );

    PipFlutter.overlayListener.listen((event) async {
      if (event != "close" && event != ""  && event != "dispose") {
        _controller.seekTo(Duration(milliseconds: event));
      } else if(event == "close" ){
        await PipFlutter.close();
      }
      active = await PipFlutter.isActive();

      setState(() {});
    });
    listener = LifecycleEventHandler(callback: (state) async {
      print("-------$state");
    }, onDestroy: () {
      print("-------onDestroy");
    });
    WidgetsBinding.instance.addObserver(listener as WidgetsBindingObserver);
  }

  @override
  Widget build(BuildContext context) {
    var density = MediaQuery.of(context).devicePixelRatio;
    return videoScreen(
      controller: _controller,
      curr: currentPosition,
      isActive: active,
      close: () async {
        await PipFlutter.close();
        setState(() {
          active = false;
        });
      },
      showOverlays: () async {
        _controller.pause();
        await PipFlutter.showPopup(
          url,
          _controller.value.position.inMilliseconds,
          overlayTitle: "Tub App",
          overlayContent: 'Overlay Video',
          width: 300.dpToPx(density),
          height: (300 * 9 ~/ 16).dpToPx(density),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("dispose app -----------------------------------------");
    WidgetsBinding.instance.removeObserver(listener as WidgetsBindingObserver);
    PipFlutter.disposeOverlayListener();
  }

  @override
  void deactivate() {
    print("deactivate app -----------------------------------------");
    super.deactivate();
  }
}

Widget videoScreen({
  required VideoPlayerController controller,
  required String curr,
  required bool isActive,
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
              if (isActive)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text("overlays is running"),
                    ),
                  ),
                ),
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
            ],
          ),
          Expanded(flex: 1, child: listVideos(fakeItems(), close))
        ],
      ),
    ),
  );
}

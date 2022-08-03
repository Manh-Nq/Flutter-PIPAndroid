import 'package:flutter/material.dart';
import 'package:tub_app_overlays/pip_flutter.dart';

import 'overlay.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void showPIPScreen() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayScreen(),
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PipFlutter.overlayListener.listen((event) {
      print("[AppHome] - $event");
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    width: 300,
                    height: 200);
              },
              child: Text("show")),
          TextButton(
              onPressed: () async {
                await PipFlutter.close();
              },
              child: Text("close")),
          TextButton(
              onPressed: () async {
                await PipFlutter.putArguments("this is Data from appHome");
              },
              child: Text("share")),
          TextButton(
              onPressed: () async {
                var rs = await PipFlutter.requestP();
                print("${rs}");
              },
              child: Text("request permission")),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tub_app_overlays/pip_flutter.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({Key? key}) : super(key: key);

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    PipFlutter.overlayListener.listen((event) {
      print("[OverlayScreen] - $event");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:Container(
        color: Colors.red,
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  print("click button share ");
                  await PipFlutter.putArguments("this is data from Overlays");
                },
                child: const Text("Share data"))
          ],
        ),
      ),
    );
  }
}

import 'dart:ffi';

import 'package:flutter/material.dart';

typedef FutureVoidCallback = Future<void> Function(String);

class LifecycleEventHandler extends WidgetsBindingObserver {
  final FutureVoidCallback callback;
  final VoidCallback onDestroy;

  LifecycleEventHandler({required this.callback, required this.onDestroy});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        await callback("inactive");
        break;
        
      case AppLifecycleState.paused:
        await callback("paused");
        break;

      case AppLifecycleState.resumed:
        await callback("resumed");
        break;

      case AppLifecycleState.detached:
        await callback("detached");
        break;
    }
  }
  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    onDestroy();
    return super.didPopRoute();
  }
}

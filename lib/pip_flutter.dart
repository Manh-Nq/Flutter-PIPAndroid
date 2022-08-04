import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

/// default size when the overlay match the parent size
/// basically it will take the full screen width and height
const int matchParent = -1;

class PipFlutter {
  PipFlutter._();

  static final StreamController _controller = StreamController.broadcast();
  static const MethodChannel _channel =
      MethodChannel("com.example.tub_app_overlays/overlayChannel");

  static const BasicMessageChannel _overlayMessageChannel = BasicMessageChannel(
      "com.example.tub_app_overlays/overlay_messenger", JSONMessageCodec());

  static void disposeOverlayListener() {
    _controller.close();
  }

  static Future<bool?> show({
    int height = matchParent,
    int width = matchParent,
    OverlayAlignment alignment = OverlayAlignment.center,
    NotificationVisibility visibility = NotificationVisibility.visibilitySecret,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    String overlayTitle = "overlay activated",
    String? overlayContent,
    bool enableDrag = false,
    PositionGravity positionGravity = PositionGravity.none,
  }) async {
    await _channel.invokeMethod(
      'show',
      {
        "height": height,
        "width": width,
        "alignment": alignment.name,
        "flag": flag.name,
        "overlayTitle": overlayTitle,
        "overlayContent": overlayContent,
        "enableDrag": enableDrag,
        "notificationVisibility": visibility.name,
        "positionGravity": positionGravity.name,
      },
    );
  }

  static Future<void> close() async {
    await _channel.invokeMethod('close');
  }

  static Future<void> pushArguments(dynamic arguments) async {
    return await _overlayMessageChannel.send(arguments);
  }

  static Future<bool> isActive() async {
    return await _channel.invokeMethod("isActive");
  }

  static Future<bool> requestP() async {
    return await _channel.invokeMethod('requestP');
  }

  static Stream<dynamic> get overlayListener {
    _overlayMessageChannel.setMessageHandler((message) async {
      _controller.add(message);
    });

    return _controller.stream;
  }
}

/// Placement of overlay within the screen.
enum OverlayAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight
}

/// Type of dragging behavior for the overlay.
enum PositionGravity {
  /// The `PositionGravity.none` will allow the overlay to postioned anywhere on the screen.
  none,

  /// The `PositionGravity.right` will allow the overlay to stick on the right side of the screen.
  right,

  /// The `PositionGravity.left` will allow the overlay to stick on the left side of the screen.
  left,

  /// The `PositionGravity.auto` will allow the overlay to stick either on the left or right side of the screen depending on the overlay position.
  auto,
}

enum OverlayFlag {
  /// Window flag: this window can never receive touch events.
  /// Usefull if you want to display click-through overlay
  clickThrough,

  /// Window flag: this window won't ever get key input focus
  /// so the user can not send key or other button events to it.
  defaultFlag,

  /// Window flag: allow any pointer events outside of the window to be sent to the windows behind it.
  /// Usefull when you want to use fields that show keyboards.
  focusPointer,
}

/// The level of detail displayed in notifications on the lock screen.
enum NotificationVisibility {
  /// Show this notification in its entirety on all lockscreens.
  visibilityPublic,

  /// Do not reveal any part of this notification on a secure lockscreen.
  visibilitySecret,

  /// Show this notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.
  visibilityPrivate
}

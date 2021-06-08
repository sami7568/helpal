import 'dart:async';

import 'package:flutter/material.dart';

class HelpalOverylay {
  showOverlay(BuildContext context, Positioned positionedWidget,
      Duration duration) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (context) => positionedWidget);
    overlayState.insert(overlayEntry);

    await Future.delayed(duration);

    overlayEntry.remove();
  }
}

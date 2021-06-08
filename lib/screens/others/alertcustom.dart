/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 * 
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/* import 'alert_style.dart';
import 'animation_transition.dart';
import 'constants.dart';
import 'dialog_button.dart'; */

/// Main class to create alerts.
///
/// You must call the "show()" method to view the alert class you have defined.
class AlertAz {
  final String id;
  final BuildContext context;
  final AlertType type;
  final AlertStyle style;
  final Image image;
  final String title;
  final String desc;
  final Widget content;
  final List<DialogButton> buttons;
  final Function closeFunction;
  final Icon closeIcon;
  final bool onWillPopActive;
  final AlertAnimation alertAnimation;

  /// Alert constructor
  ///
  /// [context], [title] are required.
  AlertAz({
    @required this.context,
    this.id,
    this.type,
    this.style = const AlertStyle(),
    this.image,
    @required this.title,
    this.desc,
    this.content,
    this.buttons,
    this.closeFunction,
    this.closeIcon,
    this.onWillPopActive = false,
    this.alertAnimation,
  });

  /// Displays defined alert window
  Future<bool> show() async {
    return await showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return _buildDialog();
        },
        barrierDismissible: style.isOverlayTapDismiss,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: style.overlayColor,
        useRootNavigator: true,
        transitionDuration: style.animationDuration,
        transitionBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            alertAnimation == null
                ? _showAnimation(animation, secondaryAnimation, child)
                : alertAnimation(
                    context, animation, secondaryAnimation, child));
  }

  // Will be added in next version.
  Future<void> dismiss() async {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Alert dialog content widget
  Widget _buildDialog() {
    final Widget _child = ConstrainedBox(
      constraints: style.constraints ??
          BoxConstraints.expand(
              width: double.infinity, height: double.infinity),
      child: Align(
        alignment: style.alertAlignment,
        child: SingleChildScrollView(
          child: AlertDialog(
              key: Key(id),
              backgroundColor: style.backgroundColor ??
                  Theme.of(context).dialogBackgroundColor,
              shape: style.alertBorder ?? _defaultShape(),
              insetPadding: style.alertPadding,
              elevation: style.alertElevation,
              titlePadding: const EdgeInsets.all(0.0),
              title: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 150,
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(top: 5, right: 5),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: _getImage().image, fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: _getCloseButton(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          title,
                          style: style.titleStyle,
                          textAlign: style.titleTextAlign,
                        ),
                        SizedBox(
                          height: desc == null ? 5 : 10,
                        ),
                        desc == null
                            ? Container()
                            : Text(
                                desc,
                                style: style.descStyle,
                                textAlign: style.descTextAlign,
                              ),
                        content == null ? Container() : content,
                      ],
                    ),
                  ],
                ),
              ),
              contentPadding: style.buttonAreaPadding,
              content: style.buttonsDirection == ButtonsDirection.row
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _getButtons(),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _getButtons(),
                    )),
        ),
      ),
    );
    return onWillPopActive
        ? WillPopScope(onWillPop: () async => false, child: _child)
        : _child;
  }

// Returns the close button on the top right
  Widget _getCloseButton() {
    return style.isCloseButton
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: GestureDetector(
              onTap: () {
                if (closeFunction == null) {
                  Navigator.of(context, rootNavigator: true).pop();
                } else {
                  closeFunction();
                }
              },
              child: Container(
                alignment: FractionalOffset.topRight,
                child: this.closeIcon != null
                    ? Container(child: this.closeIcon)
                    : Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              '$kImagePath/close.png',
                              package: 'rflutter_alert',
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          )
        : Container();
  }

  // Returns defined buttons. Default: Cancel Button
  List<Widget> _getButtons() {
    List<Widget> expandedButtons = [];
    if (style.isButtonVisible) {
      if (buttons != null) {
        buttons.forEach(
          (button) {
            var buttonWidget = Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: button,
            );
            if ((button.width != null && buttons.length == 1) ||
                style.buttonsDirection == ButtonsDirection.column) {
              expandedButtons.add(buttonWidget);
            } else {
              expandedButtons.add(Expanded(
                child: buttonWidget,
              ));
            }
          },
        );
      } else {
        Widget cancelButton = DialogButton(
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
        );
        if (style.buttonsDirection == ButtonsDirection.row) {
          cancelButton = Expanded(
            child: cancelButton,
          );
        }
        expandedButtons.add(cancelButton);
      }
    }
    return expandedButtons;
  }

  // Returns alert default border style
  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(
        color: Colors.blueGrey,
      ),
    );
  }

  // Returns alert image for icon
  Image _getImage() {
    Image response = image ?? Image.asset("assets/images/bubble.png");
    switch (type) {
      case AlertType.success:
        response = Image.asset(
          '$kImagePath/icon_success.png',
          package: 'rflutter_alert',
        );
        break;
      case AlertType.error:
        response = Image.asset(
          '$kImagePath/icon_error.png',
          package: 'rflutter_alert',
        );
        break;
      case AlertType.info:
        response = Image.asset(
          '$kImagePath/icon_info.png',
          package: 'rflutter_alert',
        );
        break;
      case AlertType.warning:
        response = Image.asset(
          '$kImagePath/icon_warning.png',
          package: 'rflutter_alert',
        );
        break;
      case AlertType.none:
        response = Image.asset("assets/images/bubble.png");
        break;
    }
    return response;
  }

  // Shows alert with selected animation
  _showAnimation(animation, secondaryAnimation, child) {
    switch (style.animationType) {
      case AnimationType.fromRight:
        return AnimationTransition.fromRight(
            animation, secondaryAnimation, child);
        break;
      case AnimationType.fromLeft:
        return AnimationTransition.fromLeft(
            animation, secondaryAnimation, child);
        break;
      case AnimationType.fromBottom:
        return AnimationTransition.fromBottom(
            animation, secondaryAnimation, child);
        break;
      case AnimationType.grow:
        return AnimationTransition.grow(animation, secondaryAnimation, child);
        break;
      case AnimationType.shrink:
        return AnimationTransition.shrink(animation, secondaryAnimation, child);
        break;
      case AnimationType.fromTop:
        return AnimationTransition.fromTop(
            animation, secondaryAnimation, child);
        break;
    }
  }
}

/// Predefined functions for transition animations
///
/// Exp: AnimationTransition.fromRight(animation, secondaryAnimation, child);
class AnimationTransition {
  /// Slide animation, from right to left (SlideTransition)
  static fromRight(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from left to right (SlideTransition)
  static fromLeft(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from top to bottom (SlideTransition)
  static fromTop(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Slide animation, from top to bottom (SlideTransition)
  static fromBottom(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Scale animation, from in to out (ScaleTransition)
  static grow(Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.00,
            0.50,
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }

  /// Scale animation, from out to in (ScaleTransition)
  static shrink(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.2,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.50,
            1.00,
            curve: Curves.linear,
          ),
        ),
      ),
      child: child,
    );
  }
}

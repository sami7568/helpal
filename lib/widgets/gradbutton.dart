import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';

class GradButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Function onPressed;
  final Color backgroundColor;
  final bool enabled;

  const GradButton({
    Key key,
    @required this.child,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
    this.backgroundColor = Appdetails.appGreenColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: enabled ? backgroundColor : Colors.grey,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: enabled ? onPressed : () => print("Button Disabled"),
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

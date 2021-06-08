import 'package:flutter/material.dart';

class ShadowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fontColor;
  final Color shadowColor;
  final double shadowBlur;
  final FontWeight fontWeight;

  ShadowText(
      {this.text = '',
      this.fontColor = Colors.white,
      this.fontSize = 15,
      this.fontWeight = FontWeight.normal,
      this.shadowColor = Colors.grey,
      this.shadowBlur = 3});

  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: TextStyle(
          color: this.fontColor,
          fontSize: this.fontSize,
          fontWeight: this.fontWeight,
          shadows: [
            Shadow(
              blurRadius: this.shadowBlur,
              color: this.shadowColor,
              offset: Offset(0, 0),
            ),
          ],
        ));
  }
}

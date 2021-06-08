import 'package:flutter/material.dart';

class MyAnim extends StatefulWidget {
  final double sizeNormal;
  final double sizeSmall;
  final int speedMiliseconds;
  final Curve curve;
  final Color color;
  final Widget centerWidget;

  const MyAnim(
      {Key key,
      this.sizeNormal,
      this.speedMiliseconds,
      this.curve,
      this.sizeSmall,
      this.color,
      this.centerWidget})
      : super(key: key);

  @override
  _MyAnimState createState() => _MyAnimState();
}

class _MyAnimState extends State<MyAnim> {
  double size = 40;

  @override
  void initState() {
    super.initState();
    startAnim();
  }

  @override
  void dispose() {
    super.dispose();
  }

  startAnim() {
    size = widget.sizeSmall;
    setState(() {});
    Future.delayed(Duration(milliseconds: 100), () {
      size = widget.sizeNormal;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.sizeNormal,
      width: widget.sizeNormal,
      alignment: Alignment.center,
      child: AnimatedContainer(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.sizeNormal),
          color: widget.color,
        ),
        alignment: Alignment.center,
        duration: Duration(milliseconds: widget.speedMiliseconds),
        curve: widget.curve,
        onEnd: () => onAnimEnd(),
        height: size,
        width: size,
        child: widget.centerWidget,
      ),
    );
  }

  onAnimEnd() {
    print("repeating again");
    if (size == widget.sizeNormal) {
      size = widget.sizeSmall;
    } else {
      size = widget.sizeNormal;
    }
    setState(() {});
  }
}

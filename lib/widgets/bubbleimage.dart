import 'package:flutter/material.dart';

class BubbleImage extends StatelessWidget {
  final String _label;
  final double _fontsize;
  final double _top;
  final double _left;
  final double _size;

  BubbleImage(this._label, this._fontsize, this._top, this._left, this._size);

  @override
  Widget build(BuildContext context) {
    return _bubble();
  }

  Widget _bubble() {
    AssetImage assetImage = AssetImage('assets/images/bubble.png');
    Image image = Image(
      image: assetImage,
      height: _size,
    );
    Text _labeltext = Text(
      _label,
      style: TextStyle(color: Colors.white, fontSize: _fontsize),
    );
    return Container(
      child: Align(
        alignment: Alignment.topLeft,
        child: Stack(
          children: <Widget>[
            image,
            Positioned(
              child: _labeltext,
              top: _top,
              left: _left,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';

class CusTextField extends StatelessWidget {
  final Icon icon;
  final ImageIcon imgIcon;
  final Color imgIconColor;
  final Color iconColor;
  final String hint;
  final FormFieldValidator<String> validator;
  final Function onChanged;
  final Function onFocused;
  final Function onDeFocused;
  final bool obsecure;
  final TextInputType keyboardType;
  final String initialValueString;
  final bool showLabel;
  final String labelText;
  final TextEditingController controller;
  final double screenHeight;
  final bool enabled;
  final BorderSide borders;
  final TextCapitalization capitalization;

  CusTextField(
      {this.icon,
      this.hint,
      this.validator,
      this.onChanged,
      this.obsecure = false,
      this.keyboardType = TextInputType.name,
      this.initialValueString,
      this.showLabel = false,
      this.labelText = 'label',
      this.controller,
      this.screenHeight = 0,
      this.enabled = true,
      this.imgIcon,
      this.iconColor = Appdetails.appGreenColor,
      this.borders,
      this.onFocused,
      this.onDeFocused,
      this.imgIconColor = Colors.transparent,
      this.capitalization = TextCapitalization.none});
  @override
  Widget build(BuildContext context) {
    var height = this.screenHeight / 100 * 8;
    var heightWithLabel = this.screenHeight / 100 * 8;
    //Checking if height of screen is not assigned
    if (height == 0) height = 60;
    if (heightWithLabel == 0) heightWithLabel = 70;
    //font size
    var fontSizeLabel = this.screenHeight / 100 * 1.5;
    var fontSizeField = this.screenHeight / 100 * 1.8;
    //checking if screen size not assigned turn to default values
    if (fontSizeField == 0) fontSizeField = 15;
    if (fontSizeLabel == 0) fontSizeLabel = 13;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: showLabel,
            child: Text(
              '  ' + labelText,
              style: TextStyle(fontSize: fontSizeLabel, color: Colors.black38),
            ),
          ),
          SizedBox(height: showLabel ? 4 : 0),
          TextFormField(
            textCapitalization: capitalization,
            onTap: onFocused,
            onEditingComplete: onDeFocused,
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            obscureText: obsecure,
            initialValue: initialValueString,
            style: this.enabled
                ? TextStyle(fontSize: fontSizeField)
                : TextStyle(fontSize: fontSizeField, color: Colors.grey),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  fontSize: fontSizeField),
              hintText: hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: borders != null
                      ? borders
                      : BorderSide(style: BorderStyle.none)),
              prefixIcon: Padding(
                child: IconTheme(
                    data: IconThemeData(color: iconColor),
                    child: icon == null ? imgIcon : icon),
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 3.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

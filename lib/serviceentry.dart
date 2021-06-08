import 'package:flutter/material.dart';

class EntryModule extends StatefulWidget {
  final Function(List<String> kidsList) onChange;

  const EntryModule({Key key, this.onChange}) : super(key: key);

  @override
  _EntryModuleState createState() => _EntryModuleState();
}

class _EntryModuleState extends State<EntryModule> {
  BuildContext mycontext;

  @override
  Widget build(BuildContext context) {
    mycontext = context;

    return Material(
        child: Center(
      child: getServicesField(),
    ));
  }

  List<String> kidsList = List();
  TextEditingController serviceTitle = TextEditingController();
  //TextEditingController servicePrice = TextEditingController();
  String error = "";

  getServicesField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(40),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  color: Colors.white,
                  child: ServiceTextField(
                    controller: serviceTitle,
                    hint: 'Child Name',
                    icon: Icon(Icons.list),
                    iconColor: Colors.grey[400],
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                MaterialButton(
                  child: Text(
                    "Add Child",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (serviceTitle.text.length > 0) {
                      setState(() {
                        kidsList.add(serviceTitle.text);
                        serviceTitle.text = '';
                        error = "";
                        if (widget.onChange != null)
                          widget.onChange.call(kidsList);
                      });
                    } else {
                      print("Please enter missing details");
                      error = "Please enter child name";
                      setState(() {});
                    }
                  },
                  color: Colors.greenAccent,
                  textColor: Colors.grey[800],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: kidsList.length != 0
                      ? Text(
                          "Your Childerends",
                        )
                      : SizedBox(height: 0),
                ),
                SizedBox(height: 10),
                Container(
                  height: getheight(),
                  child: kidsList.length == 0
                      ? SizedBox(
                          height: 0,
                        )
                      : MediaQuery.removePadding(
                          context: mycontext,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: kidsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              String serviceT = kidsList.elementAt(index);

                              return Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                serviceT,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.grey[500],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              kidsList.remove(serviceT);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double getheight() {
    double lnt = double.parse(kidsList.length.toString());
    return lnt * 45;
  }
}

class ServiceTextField extends StatelessWidget {
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

  ServiceTextField(
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
      this.iconColor = Colors.grey,
      this.borders,
      this.onFocused,
      this.onDeFocused,
      this.imgIconColor = Colors.transparent});
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

    return Material(
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
            onTap: onFocused,
            onEditingComplete: onDeFocused,
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            obscureText: obsecure,
            initialValue: initialValueString,
            style: TextStyle(fontSize: fontSizeField),
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

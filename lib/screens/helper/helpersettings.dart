import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:helpalapp/functions/servercalls.dart';
import 'package:helpalapp/screens/helpee/helpeedrawer.dart';
import 'package:helpalapp/screens/helpee/helpeesettingsaccount.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helper/helperaccountsettings.dart';
import 'package:helpalapp/screens/helper/helpernavbar.dart';
import 'package:helpalapp/widgets/displaypicture.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperSettings extends StatefulWidget {
  @override
  _HelperSettingsState createState() => _HelperSettingsState();
}

class _HelperSettingsState extends State<HelperSettings>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool keepmesignedin = false;
  String username = "Loading...";
  String phonenumber = "Loading...";

  final AuthService _auth = AuthService();

  Future darkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('kmsi') == null) await prefs.setBool('kmsi', false);
    setState(() {
      keepmesignedin = prefs.getBool('kmsi');
    });
  }

  Future setKeepMeSignedin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('kmsi', value);
    print('KMSI Changed to = $value');
  }

  @override
  void initState() {
    super.initState();
    darkMode();
    getDetails();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  createChangeStatusDialog() {}

  Widget _myListView(ListView listView) {
    return MediaQuery.removePadding(
        context: context, removeTop: true, child: listView);
  }

  @override
  Widget build(BuildContext context) {
    //double screenHeight = (MediaQuery.of(context).size.height);
    //double screenWidth = (MediaQuery.of(context).size.width);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: HelpeeDrawer(),
      endDrawer: HelpeeDrawer(),
      extendBodyBehindAppBar: false,
      appBar: getAppbar(),
      bottomNavigationBar: HelperBottomNavbar().getnewnavbar(context, 2),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            /* getProfileHeader(),
            SizedBox(
              height: 20,
            ),
            Divider(
              thickness: 1,
              color: Colors.grey[200],
            ), */
            Expanded(
              child: Container(
                child: _myListView(
                  new ListView(
                    children: getListItem(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAppbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Appdetails.appGreenColor,
        ),
        onPressed: () {
          _scaffoldKey.currentState.openDrawer();
        },
      ),
      actions: [
        Container(
          height: 20,
          width: 20,
          margin: EdgeInsets.only(right: 20),
          child: InkWell(
            child: Image(
              image: Image.asset("assets/images/icons/wallet.png").image,
              color: Appdetails.appGreenColor,
            ),
            onTap: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }

  void callbackFunction(String callFrom) {
    //check called from
    print('You clicked on $callFrom');
    if (callFrom.contains('dark')) {
      createChangeStatusDialog();
    }
    if (callFrom.contains('account')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HelperSettingsAccount()));
    }
  }

  List<Widget> getListItem() {
    Map<String, IconData> listitem = {
      'Account Settings': Icons.supervisor_account,
      'empty1': Icons.arrow_right,
      'Select Language': Icons.map,
      'empty2': Icons.arrow_right,
      'Dark Mode': Icons.lightbulb_outline,
      'empty3': Icons.arrow_right,
      'empty5': Icons.arrow_right,
      'Terms And Conditions': Icons.help_outline,
      'empty4': Icons.arrow_right,
      'Logout': Icons.exit_to_app,
    };
    Map<String, IconData> listSubitem = {
      'Change details': Icons.supervisor_account,
      'empty1': Icons.arrow_right,
      'Coming soon': Icons.map,
      'empty2': Icons.arrow_right,
      'Change theme to dark or light': Icons.lightbulb_outline,
      'empty3': Icons.arrow_right,
      'empty5': Icons.arrow_right,
      'Read how to use Helpal': Icons.help_outline,
      'empty4': Icons.arrow_right,
      '': Icons.exit_to_app,
    };
    List<Widget> listofwidgets = new List();
    int index = 0;
    listitem.forEach((key, value) {
      var callback = key.replaceAll(' ', '').toLowerCase();
      var item = ListTile(
        leading: Icon(
          value,
          color: Appdetails.appGreenColor,
          size: 35,
        ),
        trailing: key.contains('Dark')
            ? new CupertinoSwitch(
                activeColor: Appdetails.appGreenColor,
                value: keepmesignedin,
                onChanged: (newValue) {
                  setState(() {
                    keepmesignedin = newValue;
                    setKeepMeSignedin(newValue);
                  });
                })
            : new Text(''),
        title: Text(
          key,
          style: TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          listSubitem.keys.elementAt(index),
        ),
        onTap: () {
          // Update the state of the app.
          callbackFunction(callback);
        },
      );
      if (key.contains('empty')) {
        listofwidgets.add(new SizedBox(
          height: 5,
          child: Divider(
            color: Appdetails.grey2,
          ),
        ));
      } else {
        listofwidgets.add(new Container(
          child: item,
        ));
      }
      index++;
    });
    return listofwidgets;
  }

  // ignore: missing_return
  Future<String> getDetails() async {
    print('Getting username in Settings');
    final uname = await _auth.getLocalString(Appdetails.nameKey);
    final number = await _auth.getLocalString(Appdetails.phoneKey);
    setState(() {
      username = uname;
      phonenumber = number;
    });
  }

  Widget getProfileHeader() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
          ),
          DisplayPicture(
            sizeOfDp: 35,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Text(
                  '$username',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 28),
                ),
                onTap: () {
                  //onpressed
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelpeeSettingsAccount()));
                },
              ),
              SizedBox(
                height: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    child: InkWell(
                      child: Text(
                        phonenumber,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            fontSize: 18),
                      ),
                      onTap: () {
                        //onpressed
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpeeSettingsAccount()));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          Container(
            height: 50,
            width: 50,
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.edit,
              color: Colors.grey[600],
              size: 25,
            ),
          )
        ],
      ),
    );
  }
}

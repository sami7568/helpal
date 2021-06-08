import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:helpalapp/functions/appdetails.dart';

class OrderPage extends StatefulWidget {
  final String orderId;

  const OrderPage({Key key, this.orderId}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState(this.orderId);
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  //Info that will come with this instance
  final String orderId;
  _OrderPageState(this.orderId);

  //AnimationController _controller;
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //final AuthService _auth = AuthService();
  final ref = FirebaseDatabase.instance;

  TextEditingController messageController = TextEditingController();

  ScrollController messagesScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    //_controller = AnimationController(vsync: this);
    //DBUpdater().initDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    //_controller.dispose();
  }

  BorderRadius helperBubble() {
    return BorderRadius.only(
        topRight: Radius.circular(100),
        bottomRight: Radius.circular(100),
        bottomLeft: Radius.circular(100));
  }

  BorderRadius helpeeBubble() {
    return BorderRadius.only(
        topLeft: Radius.circular(100),
        bottomRight: Radius.circular(100),
        bottomLeft: Radius.circular(100));
  }

  sendMessage() async {
    String newMsgs = '';
    print('Sending new Message=$newMsgs');
    if (Appdetails.lastMessageHistory.length > 0) {
      newMsgs = Appdetails.lastMessageHistory + '[split]';
    }
    newMsgs = newMsgs + '[hlpr]' + messageController.text;
    messageController.text = '';
    print('Sending new Message=$newMsgs');
    await ref
        .reference()
        .child('orderschat')
        .child(orderId)
        .child('messages')
        .set(newMsgs);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);
    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight / 100 * 15),
              height: screenHeight / 100 * 45,
              child: Flexible(
                child: FirebaseAnimatedList(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    query: ref.reference().child('orders').child(orderId),
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      String value = snapshot.value;
                      if (value.contains('&&')) value = value.split('&&')[0];
                      if (snapshot.key == 'helper' ||
                          snapshot.key == 'helpee') {
                        return new SizedBox(
                          height: 0,
                        );
                      } else {
                        return new ListTile(
                          trailing: snapshot.key == 'location'
                              ? MaterialButton(
                                  onPressed: null,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 100,
                                    height: 40,
                                    color: Appdetails.appGreenColor,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'View On Map',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                )
                              : snapshot.key == 'contact'
                                  ? MaterialButton(
                                      onPressed: null,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 40,
                                        color: Appdetails.appGreenColor,
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          'Call Helpee',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                    )
                                  : Text(''),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.key.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                child: snapshot.key == 'voice'
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.play_arrow,
                                            size: 40,
                                            color: Appdetails.appGreenColor,
                                          ),
                                          Icon(
                                            Icons.stop,
                                            size: 35,
                                            color: Colors.red,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '00:00:00',
                                            style: TextStyle(fontSize: 20),
                                          )
                                        ],
                                      )
                                    : snapshot.key == 'date'
                                        ? Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(value))
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          )
                                        : Text(
                                            value,
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                              )
                            ],
                          ),
                        );
                      }
                    }),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  width: screenWidth,
                  height: screenHeight / 100 * 40,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Appdetails.appGreenColor,
                        ),
                        width: screenWidth,
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          'Chat With Helpee',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Flexible(
                        child: FirebaseAnimatedList(
                            controller: messagesScroll,
                            //padding: EdgeInsets.symmetric(horizontal: 20),
                            query: ref
                                .reference()
                                .child('orderschat')
                                .child(orderId),
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot,
                                Animation<double> animation,
                                int index) {
                              Appdetails.lastMessageHistory = snapshot.value;
                              print('LENGTH OF MESSAGES=' +
                                  snapshot.value.toString().length.toString());
                              if (snapshot.value.toString().length > 0) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  messagesScroll.animateTo(
                                    messagesScroll.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 10),
                                    curve: Curves.easeOut,
                                  );
                                });
                                List<String> msgs =
                                    snapshot.value.toString().split('[split]');
                                List<Widget> listofWid = new List();
                                msgs.forEach((element) {
                                  print('MSG=' + element);
                                  bool isHelpee = element.startsWith('[hlpe]');
                                  listofWid.add(
                                    new Container(
                                      width: screenWidth,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isHelpee
                                              ? Color.fromARGB(
                                                  100, 166, 221, 229)
                                              : Color.fromARGB(
                                                  100, 166, 229, 170),
                                          borderRadius: isHelpee
                                              ? helperBubble()
                                              : helpeeBubble(),
                                        ),
                                        padding: EdgeInsets.all(30),
                                        child: Text(
                                          element.substring(6),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                          textDirection: isHelpee
                                              ? TextDirection.ltr
                                              : TextDirection.rtl,
                                        ),
                                      ),
                                    ),
                                  );
                                });

                                return new Column(
                                  children: listofWid,
                                );
                              } else {
                                return new Container();
                              }
                            }),
                      ),
                      Container(
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(100),
                                      bottomRight: Radius.circular(100)),
                                  color: Colors.grey[300],
                                ),
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                      hintText: 'Send a message',
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () => sendMessage(),
                              child: Container(
                                margin: EdgeInsets.only(right: 30),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Appdetails.appGreenColor,
                                    borderRadius: BorderRadius.circular(100)),
                                width: 50,
                                height: 50,
                                child: Icon(Icons.send, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

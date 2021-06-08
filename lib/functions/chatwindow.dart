import 'package:bubble/bubble.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:helpalapp/functions/appdetails.dart';

class ChatWindow extends StatefulWidget {
  final String orderId;
  final bool isHelper;

  const ChatWindow({Key key, this.orderId, this.isHelper = false})
      : super(key: key);

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  //Chat window
  bool chatwindowShowing = false;
  final ref = FirebaseDatabase.instance;

  TextEditingController messageController = TextEditingController();

  ScrollController messagesScroll = ScrollController();

  /*  BoxDecoration helperBubble() => BoxDecoration(
        boxShadow: [
          BoxShadow(color: fieldsBgColor(), blurRadius: 5, offset: Offset.zero)
        ],
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      );
  BoxDecoration helpeeBubble() => BoxDecoration(
        boxShadow: [
          BoxShadow(color: fieldsBgColor(), blurRadius: 5, offset: Offset.zero)
        ],
        color: Appdetails.appBlueColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ); */
  ImageProvider _userlogo() {
    AssetImage assetImage = AssetImage('assets/images/avatar.png');
    Image image = Image(
      image: Appdetails.myDp == null ? assetImage : Appdetails.myDp.image,
      height: 70,
    );
    return image.image;
  }

  chatQuery() => ref.reference().child('orderschat').child(widget.orderId);

  sendMessage() async {
    String newMsgs = '';
    String split = "[hlpe]";
    if (widget.isHelper) split = "[hlpr]";

    print('Sending new Message=$newMsgs');
    if (Appdetails.lastMessageHistory.length > 0) {
      newMsgs = Appdetails.lastMessageHistory + '[split]';
    }
    newMsgs = newMsgs + split + messageController.text;
    messageController.text = '';
    print('Sending new Message=$newMsgs');
    await ref
        .reference()
        .child('orderschat')
        .child(widget.orderId)
        .child('messages')
        .set(newMsgs);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: Appdetails.appBlueColor.withAlpha(60),
      child: Column(
        children: [
          //Small line in header
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 5,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 60,
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Text(
                  "Chat with Helper",
                  style: TextStyle(color: Colors.grey[700], fontSize: 24),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),

          Flexible(
            child: Container(
              child: FirebaseAnimatedList(
                  controller: messagesScroll,
                  //padding: EdgeInsets.symmetric(horizontal: 20),
                  query: chatQuery(),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    //saving old chat
                    String msgsStr = snapshot.value;
                    Appdetails.lastMessageHistory = snapshot.value;
                    //getting messages lentgh
                    int msgsLength = snapshot.value.toString().length;

                    if (msgsLength > 0) {
                      //scroll to last message
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        messagesScroll.animateTo(
                          messagesScroll.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 10),
                          curve: Curves.easeOut,
                        );
                      });
                      //getting list of messages by splitting
                      List<String> msgs = msgsStr.split('[split]');
                      //list of chat bubbles
                      List<Widget> listofWid = new List();
                      //getting each msg from list and puting into bubble
                      msgs.forEach((msg) {
                        //getting is helper's chat or helpee's
                        bool isHelper = msg.startsWith('[hlpr]');
                        //updating list of bubbles
                        listofWid.add(
                          //creating chat bubble
                          new Container(
                            width: size.width,
                            alignment: isHelper
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: isHelper
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                Container(
                                  child: isHelper
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              right: 5, bottom: 8),
                                          child: CircleAvatar(
                                            backgroundImage: _userlogo(),
                                            maxRadius: 20,
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                ),
                                Bubble(
                                  padding:
                                      BubbleEdges.symmetric(horizontal: 20),
                                  margin: BubbleEdges.symmetric(vertical: 5),
                                  radius: Radius.circular(10),
                                  nipRadius: 0,
                                  nipOffset: 4,
                                  nipHeight: 8,
                                  nip: isHelper
                                      ? BubbleNip.leftBottom
                                      : BubbleNip.rightBottom,
                                  color: isHelper
                                      ? Colors.white
                                      : Appdetails.appBlueColor,
                                  child: Text(
                                    msg.substring(6),
                                    style: TextStyle(
                                      fontSize: 23,
                                      color: isHelper
                                          ? Colors.grey[600]
                                          : Colors.white,
                                    ),
                                    textDirection: isHelper
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                  ),
                                )
                                /* Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: isHelper
                                      ? helperBubble()
                                      : helpeeBubble(),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: Text(
                                    msg.substring(6),
                                    style: TextStyle(
                                      fontSize: 23,
                                      color: isHelper
                                          ? Colors.grey[600]
                                          : Colors.white,
                                    ),
                                    textDirection: isHelper
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                  ),
                                ), */
                              ],
                            ),
                          ),
                        );
                      });
                      //converting bubbles list into ui
                      return new Column(
                        children: listofWid,
                      );
                    } else {
                      return new Container();
                    }
                  }),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5, left: 5, top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Send a message',
                        hintStyle: TextStyle(
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => sendMessage(),
                  child: Container(
                    margin: EdgeInsets.only(right: 2, top: 2, bottom: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Appdetails.appBlueColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    width: 45,
                    height: 45,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}

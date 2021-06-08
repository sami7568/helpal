import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeStatusBox {
  showDialog(BuildContext context) {
    return new CupertinoAlertDialog(
      title: Text('Change Status'),
      content: Text('Want to Change Status'),
      actions: [
        CupertinoDialogAction(
          child: Text('Offline'),
        ),
        CupertinoDialogAction(
          child: Text('Online'),
        )
      ],
    );
  }
}
/*

Column(
              children: [
                InkWell(
                  child: ShadowText(
                    text: 'Go Offline',
                    fontColor: Colors.white,
                    shadowColor: Colors.black38,
                    shadowBlur: 5,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    //Make status offline
                  },
                ),
                InkWell(
                  child: ShadowText(
                    text: 'Go Online',
                    fontColor: Colors.white,
                    shadowColor: Colors.black38,
                    shadowBlur: 5,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    //Make status offline
                  },
                ),
              ],
            ),
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/drycleanerlisttile.dart';
import 'package:helpalapp/screens/helpee/drycleanerquantitytile.dart';
import 'package:helpalapp/screens/others/dialogs.dart';
import 'package:helpalapp/widgets/ShadowText.dart';
import 'package:overlay_container/overlay_container.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NewOrderDryCleanerAddItem extends StatefulWidget {
  @override
  _NewOrderDryCleanerAddItemState createState() =>
      _NewOrderDryCleanerAddItemState();
}

class _NewOrderDryCleanerAddItemState extends State<NewOrderDryCleanerAddItem> {
  //Context
  BuildContext mycontext;
  //scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //order variables
  List<DrycleanerListTile> basketList = List();

  refreshState() {
    setState(() {});
  }

  showTilePopupStatefull(String title, double wash, double iron,
      double washiron, double dryclean, Function refreshCallback) {
    showDialog(
      context: context,
      builder: (context) {
        //Settings variables
        TextStyle headings = TextStyle(fontSize: 22, color: Appdetails.grey6);
        int quantity = 1;
        bool isWash = false;
        bool isIron = false;
        bool isDryclean = false;
        List<File> imagesList = new List();
        //End variables
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.only(top: 10, left: 10, right: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: Container(
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              //Content of dialog
              content: Container(
                width: MediaQuery.of(mycontext).size.width / 100 * 80,
                height: MediaQuery.of(mycontext).size.height / 100 * 40,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Text(
                              "Quantity",
                              style: headings,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 40,
                          width: 60,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: headings),
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        quantity++;
                                        setState(() {});
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 25,
                                        child: Icon(Icons.keyboard_arrow_up),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (quantity > 1)
                                          setState(() => quantity--);
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 25,
                                        child: Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 70,
                        maxHeight: 120,
                      ),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          itemCount: quantity,
                          itemBuilder: (BuildContext context, int index) {
                            return DryCleanerQuantityTile(
                              onImagePicked: (imgFile) {
                                imagesList.add(imgFile);
                                print("image added to list");
                              },
                              title: title,
                            );
                          },
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        wash > 0
                            ? Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Checkbox(
                                          activeColor: Appdetails.appBlueColor,
                                          value: isWash,
                                          onChanged: (newval) {
                                            isWash = newval;

                                            setState(() {});
                                          }),
                                      Text("Wash", style: headings)
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(height: 0),
                        iron > 0
                            ? Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Checkbox(
                                          activeColor: Appdetails.appBlueColor,
                                          value: isIron,
                                          onChanged: (newval) {
                                            isIron = newval;
                                            //calculate iron

                                            setState(() {});
                                          }),
                                      Text("Iron", style: headings)
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(height: 0),
                        dryclean > 0
                            ? Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Checkbox(
                                          activeColor: Appdetails.appBlueColor,
                                          value: isDryclean,
                                          onChanged: (newval) {
                                            isDryclean = newval;

                                            setState(() {});
                                          }),
                                      Text("DryClean", style: headings)
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(height: 0),
                      ],
                    ),
                  ],
                ),
              ),
              buttonPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    //calculate
                    double total = 0;
                    //both price
                    if (isWash && isIron) {
                      total = washiron;
                    }
                    //only wash
                    else if (isWash && !isIron) {
                      total = wash;
                    }
                    //only iron
                    else if (!isWash && isIron) {
                      total = iron;
                    } else if (!isWash && !isIron && !isDryclean) {
                      DialogsHelpal.showMsgBox(
                          "Warning",
                          "You haven't selected any option",
                          AlertType.warning,
                          context,
                          Appdetails.appBlueColor);
                      return;
                    }
                    //drycleaning
                    if (isDryclean) {
                      total = total + dryclean;
                    }
                    if (imagesList.length < quantity) {
                      DialogsHelpal.showMsgBox(
                          "Warning",
                          "Please add pictures of each item!",
                          AlertType.warning,
                          context,
                          Appdetails.appBlueColor);
                      return;
                    }
                    //add to basket function

                    for (int i = 0; i < quantity; i++) {
                      var lt = DrycleanerListTile(
                        title: title,
                        imgFile: imagesList[i],
                        price: total,
                      );
                      basketList.add(lt);
                    }
                    refreshCallback.call();

                    Navigator.pop(context);
                    Navigator.pop(mycontext, basketList);
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Appdetails.appBlueColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Add to Basket",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget laundryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: MediaQuery.removePadding(
        context: mycontext,
        removeTop: true,
        child: ListView.builder(
          itemCount: Appdetails.gentsList.length,
          itemBuilder: (BuildContext context, int index) {
            String serviceT = Appdetails.gentsList.elementAt(index);
            double washp = Appdetails.washPrices.elementAt(index);
            double press = Appdetails.ironPrices.elementAt(index);
            double both = Appdetails.bothPrices.elementAt(index);
            double dry = Appdetails.drycleanPrices.elementAt(index);
            var priceStyle = TextStyle(fontSize: 18, color: Colors.grey[500]);
            var empty = SizedBox(height: 0, width: 0);

            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Appdetails.appBlueColor.withAlpha(20),
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.only(bottom: 5),
              child: InkWell(
                onTap: () {
                  showTilePopupStatefull(
                      serviceT, washp, press, both, dry, refreshState);
                },
                child: Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                serviceT.capitalize(),
                                style: TextStyle(
                                    fontSize: 25, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  washp > 0
                                      ? Text("Wash:$washp PKR",
                                          style: priceStyle)
                                      : empty,
                                  press > 0
                                      ? Text("Press:$press PKR",
                                          style: priceStyle)
                                      : empty,
                                  both > 0
                                      ? Text("Wash & Press:$both PKR",
                                          style: priceStyle)
                                      : empty,
                                  dry > 0
                                      ? Text("Dry Clean:$dry PKR",
                                          style: priceStyle)
                                      : empty,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        child: Icon(
                          Icons.add,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mycontext = context;
    Size size = MediaQuery.of(context).size;

    return myrecents(size, context);
  }

  Widget myrecents(Size size, BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Center(
          child: Container(
            child: ShadowText(
              text: "Services List".toUpperCase(),
              fontColor: Colors.grey[700],
              fontSize: 25,
              shadowColor: Colors.black.withAlpha(0),
              shadowBlur: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
            ),
            onPressed: () {
              //back button
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: Appdetails.gentsList.length > 0 ? laundryList() : notAvailable(),
      ),
    );
  }

  Widget notAvailable() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.not_interested,
              size: 50,
              color: Appdetails.appBlueColor,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "There is nothing to show",
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}

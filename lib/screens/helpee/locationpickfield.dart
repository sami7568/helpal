import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpalapp/functions/appdetails.dart';
import 'package:helpalapp/screens/helpee/picklocation.dart';

class LocationPickField extends StatefulWidget {
  final String placeHolder;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final Function(String address, String latlng) onPicked;

  const LocationPickField(
      {Key key,
      this.placeHolder = "Select Location",
      this.backgroundColor = Appdetails.appBlueColorWithAlpha,
      this.iconColor = Appdetails.appBlueColor,
      this.icon = Icons.location_on,
      this.onPicked})
      : super(key: key);

  @override
  _LocationPickFieldState createState() => _LocationPickFieldState();
}

class _LocationPickFieldState extends State<LocationPickField> {
  //Controll field
  bool isSelected = false;
  String address = "";
  LatLng latlng;

  @override
  void initState() {
    address = widget.placeHolder;
    super.initState();
  }

  onLocationPicked() {
    address = Appdetails.lastAddress;
    String _latlng = Appdetails.lastLatlng;
    double lat = double.parse(_latlng.split(",")[0].trim());
    double lng = double.parse(_latlng.split(",")[1].trim());
    latlng = new LatLng(lat, lng);
    print("Address Picked = $address \n And Latlng is= $_latlng");
    setState(() {});
    //calling widget update
    widget.onPicked(address,
        latlng.latitude.toString() + "," + latlng.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.backgroundColor,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickLocation(
                callback: onLocationPicked,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: address.startsWith("Select")
                            ? Colors.grey[600]
                            : widget.iconColor,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          address,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

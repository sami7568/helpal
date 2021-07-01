import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:helpalapp/widgets/gradbutton.dart';
import 'package:helpalapp/functions/appdetails.dart';

class PickLocation extends StatefulWidget {
  final Function callback;

  const PickLocation({Key key, this.callback}) : super(key: key);

  static final kInitialPosition = LatLng(34.185184, 73.3599774);
  @override
  _PickLocationState createState() => _PickLocationState(callback);
}

class _PickLocationState extends State<PickLocation>
    with SingleTickerProviderStateMixin {
  final Function callback;

  PickResult selectedPlace;
  AnimationController _controller;

  _PickLocationState(this.callback);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _workerIcon() {
    AssetImage assetImage = AssetImage('assets/images/marker_pin_helper.png');
    Image image = Image(
      image: assetImage,
      height: 50,
    );
    return image;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: screenWidth,
              height: screenHeight - (30),
              child: PlacePicker(
                onPlacePicked: (result) {
                  selectedPlace = result;
                  Navigator.of(context).pop();
                  setState(() {});
                },
                pinBuilder: (context, state) {
                  if (state == PinState.Idle) {
                    return Icon(Icons.place);
                  } else {
                    return Icon(Icons.place_outlined);
                  }
                },
                apiKey: Appdetails.mapsApiKey,
                initialPosition: PickLocation.kInitialPosition,
                useCurrentLocation: true,
                selectInitialPosition: true,
                selectedPlaceWidgetBuilder:
                    (_, selectedPlace, state, isSearchBarFocused) {
                  return isSearchBarFocused
                      ? Container()
                      : FloatingCard(
                          bottomPosition: 10.0,
                          leftPosition: screenWidth / 100 * 20,
                          rightPosition: screenWidth / 100 * 20,
                          width: screenWidth,
                          borderRadius: BorderRadius.circular(12.0),
                          child: state == SearchingState.Searching
                              ? Center(child: CircularProgressIndicator())
                              : Container(
                                  child: Column(
                                    children: [
                                      Text(selectedPlace.formattedAddress),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GradButton(
                                        child: Text(
                                          'Select',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                        onPressed: () async {
                                          String lastAddress =
                                              selectedPlace.formattedAddress;
                                          LatLng ltng = new LatLng(
                                              selectedPlace
                                                  .geometry.location.lat,
                                              selectedPlace
                                                  .geometry.location.lng);
                                          print(
                                              "do something with [$lastAddress] data");
                                          String lastLatLng =
                                              ltng.latitude.toString() +
                                                  ',' +
                                                  ltng.longitude.toString();
                                          Appdetails.lastAddress = lastAddress;
                                          Appdetails.lastLatlng = lastLatLng;
                                          if (callback != null) callback();

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

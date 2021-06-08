import 'package:latlong/latlong.dart';

class DistanceCalculator {
  final Distance distance = Distance();

  Future<double> getDistance(
      double lat1, double lng1, double lat2, double lng2) async {
    double totalDistanceInKm = distance.as(
        LengthUnit.Kilometer, new LatLng(lat1, lng1), new LatLng(lat2, lng2));

    return totalDistanceInKm;
  }

  Future<double> getDistanceMeters(
      double lat1, double lng1, double lat2, double lng2) async {
    double totalDistanceInKm = distance.as(
        LengthUnit.Meter, new LatLng(lat1, lng1), new LatLng(lat2, lng2));

    return totalDistanceInKm;
  }
}

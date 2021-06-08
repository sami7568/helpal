import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class HelpalBilling {
  static Future<double> getPlumberElectricianBill(
      timeStart, timeEnd, LatLng start, LatLng end) async {
    final Distance distance = new Distance();

    //Plumbers and Electrician Variables
    //All prices are in pkr
    double initialPrice = 1500;
    double perHour = 31;
    double perKilometer = 0.8;
    //Calculation
    final int km = distance.as(LengthUnit.Kilometer, start, end);
    final minutes = DateTime.fromMillisecondsSinceEpoch(timeStart)
        .difference(DateTime.fromMillisecondsSinceEpoch(timeEnd))
        .inHours;
    double distancePrice = km.toDouble() * perKilometer;
    double timePrice = minutes.toDouble() * perHour;
    double totalBill = initialPrice + distancePrice + timePrice;
    return totalBill;
  }

  static Future<double> getDeliveryRiderCabBill(
      timeStart, timeEnd, LatLng start, LatLng end) async {
    final Distance distance = new Distance();

    //Plumbers and Electrician Variables
    //All prices are in pkr
    double initialPrice = 1500;
    double perHour = 31;
    double perKilometer = 0.8;
    //Calculation
    final int km = distance.as(LengthUnit.Kilometer, start, end);
    final minutes = DateTime.fromMillisecondsSinceEpoch(timeStart)
        .difference(DateTime.fromMillisecondsSinceEpoch(timeEnd))
        .inHours;
    double distancePrice = km.toDouble() * perKilometer;
    double timePrice = minutes.toDouble() * perHour;
    double totalBill = initialPrice + distancePrice + timePrice;
    return totalBill;
  }
}

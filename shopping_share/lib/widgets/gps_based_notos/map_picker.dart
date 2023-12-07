import 'dart:html';

import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MapPicker extends StatefulWidget {
  final String shoppingListId;
  const MapPicker(this.shoppingListId);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final int _distanceFilter = 10;
  final int _distanceToNotify =
      100; // will notify when user is 100 meters away of the location
  late Future<LatLong> currentPosition;

  @override
  void initState() {
    super.initState();
    currentPosition = _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLong>(
      future: currentPosition,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return OpenStreetMapSearchAndPick(
            center: snapshot.data!,
            buttonColor: Colors.blue,
            buttonText: 'Wybierz lokalizację sklepu',
            onPicked: (pickedData) {
              startBackgroundNotificationService(
                  pickedData.address,
                  pickedData.latLong.latitude,
                  pickedData.latLong.longitude,
                  widget.shoppingListId);
            },
          );
        }
      },
    );
  }

  Future<LatLong> _getCurrentPosition() async {
    LatLong latLong;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latLong = LatLong(position.latitude, position.longitude);

    return latLong;
  }

  // run the same service for the user that got the shopping list shared
  Future<void> startBackgroundNotificationService(Map<String, dynamic> address,
      double latitude, double longitude, String shoppingListId) async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: _distanceFilter))
        .listen((Position position) {
      double distanceInMeters = Geolocator.distanceBetween(
          latitude, longitude, position.latitude, position.longitude);
      if (distanceInMeters < _distanceToNotify) {
        showNotification(
            address, shoppingListId); // Reminder to do the groceries
      }
    });
  }

  // TODO: destroy the service if shopping list is removed

  Future<void> showNotification(
      Map<String, dynamic> address, String shoppingListId) async {
    var AndroidPlatformChannelSpecifics = AndroidNotificationDetails(
      shoppingListId,
      shoppingListId,
      importance: Importance.max,
      priority: Priority.high,
    );

    await FlutterLocalNotificationsPlugin().show(
        0,
        'Nie zapomnij zrobić zakupów',
        'Jesteś blisko sklepu pod adresem: ${address['name']}',
        NotificationDetails(android: AndroidPlatformChannelSpecifics),
        payload: shoppingListId);
  }
}

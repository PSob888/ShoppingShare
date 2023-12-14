import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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

  // temp vars for onStart method
  late double latitude;
  late double longitude;
  late Map<String, dynamic> address;

  @override
  void initState() {
    super.initState();
    currentPosition = _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Picker'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: FutureBuilder<LatLong>(
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
                buttonText: 'Pick a location',
                onPicked: (pickedData) {
                  latitude = pickedData.latLong.latitude;
                  longitude = pickedData.latLong.longitude;
                  address = pickedData.address;

                  startBackgroundNotificationService(
                      address, latitude, longitude, widget.shoppingListId);
                  Navigator.pop(context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<LatLong> _getCurrentPosition() async {
    LatLong latLong;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latLong = LatLong(position.latitude, position.longitude);

    return latLong;
  }

  // call this also for the user that have recieved the shopping list via share function
  Future<void> startBackgroundNotificationService(Map<String, dynamic> address,
      double latitude, double longitude, String shoppingListId) async {
    final service = FlutterBackgroundService();
    await service.configure(
        androidConfiguration:
            AndroidConfiguration(onStart: onStart, isForegroundMode: false),
        iosConfiguration: IosConfiguration(
            onForeground: onStart, onBackground: onIosBackground));
    service.startService();
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    final Map<String, String> shoppingListEventMap = {};
    final eventKey = 'stopService_$widget.shoppingListId';
    shoppingListEventMap[widget.shoppingListId] = eventKey;

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
            address, widget.shoppingListId); // Reminder to do the groceries
      }
    });
    print('Service gps started');

    // call this when the shopping list is deleted
    service.on(eventKey).listen((event) {
      service.stopSelf();
    });
    print('Stop endpoint registered');
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  Future<void> showNotification(
      Map<String, dynamic> address, String shoppingListId) async {
    var AndroidPlatformChannelSpecifics = AndroidNotificationDetails(
      "${shoppingListId}channel",
      "${shoppingListId}channel",
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

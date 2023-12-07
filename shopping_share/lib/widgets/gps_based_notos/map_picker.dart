import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  const MapPicker();

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
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
              // TODO: add background notification service based on gps
              print(pickedData.latLong.latitude);
              print(pickedData.latLong.longitude);
              print(pickedData.address);
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
}

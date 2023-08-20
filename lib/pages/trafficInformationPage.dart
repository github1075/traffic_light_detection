import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: TrafficInformationPage(),
  ));
}

class TrafficInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Information'),
      ),
      body: GoogleMapWidget(),
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController mapController;

  final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(22.471038, 91.788466), // Your desired initial position
    zoom: 15,
  );

  final Marker marker = Marker(
    markerId: MarkerId('currentPosition'),
    position: LatLng(22.471038, 91.788466), // Your desired marker position
    infoWindow: InfoWindow(title: 'Marker Title'), // Optional info window
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      markers: {marker},
    );
  }
}

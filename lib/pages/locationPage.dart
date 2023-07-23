import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController? mapController;
  final List<Marker> _markers= <Marker>[
    Marker(
        markerId:MarkerId('1'),
        position: LatLng(0.0,0.0),
      infoWindow: InfoWindow(
        title: 'my current location'
      )
    )

  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  Future<Position> getUserCurrentLocation() async{
    await Geolocator.requestPermission().then((value){

    }).onError((error, stackTrace){
      print("error"+error.toString());
    });
    return await Geolocator.getCurrentPosition();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers:Set<Marker>.of(_markers) ,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () async {
          try {

           getUserCurrentLocation().then((value){
             print("my current location");
             print(value.latitude.toString()+" "+value.longitude.toString());
             _markers.add(
               Marker(
                 markerId: MarkerId('1'),
                 position: LatLng(value.latitude,value.longitude),
                 infoWindow: InfoWindow(
                   title: 'my current position'
                 )
               )
             );
             
           });
          } catch (e) {
            print(e.toString());
          }
        },
      ),
    );
  }
}

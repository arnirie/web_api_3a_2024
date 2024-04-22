import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  MapsScreen({super.key});

  static final initialPosition = LatLng(15.987762855155182, 120.57310242604986);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;

  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('01'),
      position: MapsScreen.initialPosition,
      infoWindow: InfoWindow(title: 'My Location'),
      // icon: BitmapDescriptor.
    )
  };

  void saveToLocation(LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('$position'),
        position: position,
      ),
    );
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
    setState(() {});
  }

  Future<bool> checkServicePermission() async {
    //checking location service
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services is disabled. Please enable it in the settings.')),
      );
      return false;
    }
    //check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      //ask for permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is denied. Please accept the location permission of the app to continue.'),
          ),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change in the settings to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  void getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((position) {
      print('${position.longitude}  ${position.latitude}');
      saveToLocation(LatLng(position.latitude, position.longitude));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: MapsScreen.initialPosition,
            zoom: 10,
            // tilt: 40,
          ),
          markers: markers,
          onTap: (position) {
            print(position);
            saveToLocation(position);
          },
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
    );
  }
}

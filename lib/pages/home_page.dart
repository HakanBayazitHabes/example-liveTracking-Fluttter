import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition _cameraPosition = new CameraPosition(
    target: LatLng(39.5334, 33.8597),
  );
  Location? _location;
  LocationData? _currentLocation;
  double latitude = 39.0;
  double longitude = 39.0;
  Map<String, Marker> _markers = {};
  Uint8List? markerImage;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Future<void> _init() async {
    _location = Location();

    // Konum izinlerini kontrol et ve gerekirse kullanıcıdan izin iste
    bool serviceEnabled = await _location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location!.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Konum izinlerini kontrol et ve gerekirse kullanıcıdan izin iste
    PermissionStatus? permissionGranted = await _location?.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location!.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // _currentLocation = await _location?.getLocation();
    // print(
    //     "Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}");

    // _updateCameraPosition(
    //     LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));

    // setState(() {
    //   _cameraPosition = CameraPosition(
    //     target:
    //         LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    //     zoom: 15.0,
    //   );
    // });
  }

  _updateCameraPosition(LatLng target) {
    _cameraPosition = CameraPosition(target: target, zoom: 15.0);
    if (!_googleMapController.isCompleted) {
      _googleMapController.future.then((controller) {
        controller
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
      });
    }
  }

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    getUserCurrentLocation().then((value) {
      latitude = value.latitude;
      longitude = value.longitude;
    });
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getMap(),
    );
  }

  Widget _getMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              print("Map created, initializing...");
              print(" Latidutee: $latitude,Longitude: $longitude");
              _customInfoWindowController.googleMapController = controller;
            }

            addMarker("Test", LatLng(39.5334, 33.8597));
            addMarker("d", LatLng(39.8334, 34.8597));
            addMarker("a", LatLng(39.7334, 31.8597));
            addMarker("s", LatLng(39.6334, 32.8597));
          },
          onTap: (position) {
            _customInfoWindowController.hideInfoWindow!();
          },
          onCameraMove: (position) {
            _customInfoWindowController.onCameraMove!();
          },
          markers: Set<Marker>.of(_markers.values),
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 200,
          width: 247,
          offset: 50,
        ),
      ],
    );
  }

  addMarker(String id, LatLng location) async {
    final Uint8List markerIcon =
        await getBytesFromAssets('assets/images/recycle_icon.png', 70);

    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
          Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/otomat.png",
                      ),
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.high,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    "Otomatik geri dönüşüm makinası",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text("Dorot Rashonim 1, Kudüs",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Kullanılabilirlik: ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Aktif",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "30",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "puanlar",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Image.asset(
                        "assets/images/star.png",
                        width: 30.193416595458984,
                        height: 28,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          location,
        );
      },
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );

    _markers[id] = marker;
    setState(() {});
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.getCurrentPosition()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error: $error");
    });
    var geoCurrentLocation = await Geolocator.getCurrentPosition();

    _cameraPosition = CameraPosition(
      target: LatLng(geoCurrentLocation.latitude, geoCurrentLocation.longitude),
      zoom: 7,
    );

    // final GoogleMapController controller = await _googleMapController.future;
    // latitude = geoCurrentLocation.latitude;
    // longitude = geoCurrentLocation.longitude;
    // controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    GoogleMapController? controller =
        await _customInfoWindowController.googleMapController;
    latitude = geoCurrentLocation.latitude;
    longitude = geoCurrentLocation.longitude;
    controller?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    setState(() {});
    return geoCurrentLocation;
  }
}

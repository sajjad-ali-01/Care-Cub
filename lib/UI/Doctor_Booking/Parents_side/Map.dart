import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  final String address;
  final String clinicName;

  const MapScreen({Key? key, required this.address, required this.clinicName}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController mapController;
  final List<MapObject> mapObjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchLocation();
  }

  Future<void> _searchLocation() async {
    setState(() => isLoading = true);

    try {
      final (session, resultFuture) = await YandexSearch.searchByText(
        searchText: widget.address,
        geometry: Geometry.fromBoundingBox(BoundingBox(
          northEast: const Point(latitude: 90, longitude: 180),
          southWest: const Point(latitude: -90, longitude: -180),
        )),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: true,
        ),
      );

      final result = await resultFuture;

      if (result.items != null && result.items!.isNotEmpty) {
        final firstItem = result.items!.first;
        if (firstItem.geometry.isNotEmpty && firstItem.geometry.first.point != null) {
          final point = firstItem.geometry.first.point!;

          mapObjects.clear();
          mapObjects.add(PlacemarkMapObject(
            mapId: const MapObjectId('clinic_location'),
            point: point,
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/images/clinic_icon.png'),
                scale: 0.7,
              ),
            ),
            text: PlacemarkText(
              text: widget.clinicName,
              style: const PlacemarkTextStyle(
                size: 12,
                color: Colors.black,
                outlineColor: Colors.white,
              ),
            ),
          ));

          await mapController.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: point, zoom: 15),
            ),
            animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found for ${widget.address}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinicName),
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              mapController = controller;
              await _searchLocation();
            },
            mapObjects: mapObjects,
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
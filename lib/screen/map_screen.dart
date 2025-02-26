import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fatconnect/database/fat/fat_controller.dart';

class FatMapScreen extends StatefulWidget {
  const FatMapScreen({super.key});

  @override
  State<FatMapScreen> createState() => _FatMapScreenState();
}

class _FatMapScreenState extends State<FatMapScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(3.8480, 11.5021);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadFats();
  }

  void _loadFats() {
    final controller = context.read<FatController>();
    setState(() {
      _markers = Set<Marker>.from(
        controller.fats.map((fat) => Marker(
          markerId: MarkerId(fat.id),
          position: LatLng(fat.latitude, fat.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            fat.isActive ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed
          ),
          infoWindow: InfoWindow(
            title: fat.name,
            snippet: 'Location: ${fat.location}, Ports: ${fat.portCount}'
          ),
        )),
      );
    });
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FatController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapToolbarEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12.0,
                ),
                markers: Set<Marker>.from(
                  controller.fats.map((fat) => Marker(
                    markerId: MarkerId(fat.id),
                    position: LatLng(fat.latitude, fat.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      fat.isActive ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed
                    ),
                    infoWindow: InfoWindow(
                      title: fat.name,
                      snippet: 'Location: ${fat.location}, Ports: ${fat.portCount}'
                    ),
                  )),
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add),
                      mini: true,
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove),
                      mini: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 
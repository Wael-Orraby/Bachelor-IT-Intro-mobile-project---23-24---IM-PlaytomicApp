import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class ClubLocationsPage extends StatefulWidget {
  const ClubLocationsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClubLocationsPageState createState() => _ClubLocationsPageState();
}

class _ClubLocationsPageState extends State<ClubLocationsPage> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clublocaties'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(51.2194, 4.4025), // Antwerpen-coördinaten
          zoom: 12.0,
        ),
        markers: _markers,
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }

  // Functie om de kaart te initialiseren en clublocatiemarkers toe te voegen
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    // Voeg markers toe voor clublocaties
    _addMarkers();
  }

  // Functie om markers toe te voegen voor clublocaties
  void _addMarkers() {
    // Voorbeeldmarkers toevoegen (vervang dit met echte clublocaties)
    _markers.add(
      const Marker(
        markerId: MarkerId('club1'),
        position: LatLng(51.2153, 4.4139),
        infoWindow: InfoWindow(
          title: 'Club 1',
          snippet: 'Beschrijving van Club 1',
        ),
      ),
    );
    _markers.add(
      const Marker(
        markerId: MarkerId('club2'),
        position: LatLng(51.2308, 4.4163),
        infoWindow: InfoWindow(
          title: 'Club 2',
          snippet: 'Beschrijving van Club 2',
        ),
      ),
    );
    // Voeg hier meer clublocatiemarkers toe indien nodig
    setState(() {}); // Forceer een heropbouw om de markers weer te geven
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Marker> _markers = []; // List to store markers
  late LatLng _lastSearchedLocation;

  final MapController _mapController = MapController(); // Controller to control the map

  // Function to add a marker to the map
  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(Marker(
        point: position,
        width: 40.0, // Width of the marker
        height: 40.0, // Height of the marker
        child: const Icon(
          Icons.pin_drop,
          color: Colors.red,
          size: 40.0,
        ),
      ));
    });
  }

  // Function to handle search and place the marker
  void _searchLocation() async {
    String searchQuery = _searchController.text;

    if (searchQuery.isNotEmpty) {
      // Use the geocoding package to get the coordinates of the place name
      try {
        // Get the list of locations based on the place name entered
        List<Location> locations = await locationFromAddress(searchQuery);

        // If a location is found
        if (locations.isNotEmpty) {
          // Get the latitude and longitude of the first match
          LatLng newLocation = LatLng(locations[0].latitude, locations[0].longitude);

          // Set the last searched location
          _lastSearchedLocation = newLocation;

          // Add the marker
          _addMarker(newLocation);

          // Move the map to the new marker
          _mapController.move(newLocation, 12.0);
        } else {
          // Handle case where no location is found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No location found')),
          );
        }
      } catch (e) {
        // Handle any error that occurs while searching
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Function to save the last searched location
  void _saveLocation() {
    // ignore: unnecessary_null_comparison
    if (_lastSearchedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location saved: $_lastSearchedLocation')),
      );
      // You can save the location to a database, preferences, etc. here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap with Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter place name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(51.509865, -0.118092), // Default to London
                initialZoom: 13.0, // Zoom level
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _saveLocation,
              child: const Text('Save Location'),
            ),
          ),
        ],
      ),
    );
  }
}

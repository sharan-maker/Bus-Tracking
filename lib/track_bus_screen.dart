import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TrackBusScreen extends StatefulWidget {
  final int busId;
  const TrackBusScreen({super.key, required this.busId});

  @override
  State<TrackBusScreen> createState() => _TrackBusScreenState();
}

class _TrackBusScreenState extends State<TrackBusScreen> {
  Map? location;
  bool isLoading = true;
  Timer? timer;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchLocation();
    timer = Timer.periodic(Duration(seconds: 10), (_) => fetchLocation());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLocation() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/location/bus/${widget.busId}'),
      );
      final data = jsonDecode(response.body);
      setState(() {
        location = data['location'];
        isLoading = false;
      });

      // Move map to bus location
      if (location != null) {
        mapController.move(
          LatLng(
            double.parse(location!['latitude'].toString()),
            double.parse(location!['longitude'].toString()),
          ),
          15,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Bus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchLocation)
        ],
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : location == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey),
                  Text('Bus location not available',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ))
          : Column(
              children: [
                // Status bar
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 8),
                      Text('Bus is Live! Speed: ${location!['speed']} km/h',
                        style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('Updated: ${location!['updated_at'].toString().substring(11, 19)}',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),

                // Map
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        double.parse(location!['latitude'].toString()),
                        double.parse(location!['longitude'].toString()),
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      // OpenStreetMap tiles
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.bus_tracking_app',
                      ),
                      // Bus marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              double.parse(location!['latitude'].toString()),
                              double.parse(location!['longitude'].toString()),
                            ),
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.directions_bus,
                                    color: Colors.white, size: 24),
                                ),
                                Icon(Icons.arrow_drop_down,
                                  color: Colors.blue, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Info bar at bottom
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoChip(Icons.location_on, 'Lat: ${location!['latitude']}'),
                      _infoChip(Icons.location_on, 'Lng: ${location!['longitude']}'),
                      _infoChip(Icons.speed, '${location!['speed']} km/h'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blue),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
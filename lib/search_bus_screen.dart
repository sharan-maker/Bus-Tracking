import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchBusScreen extends StatefulWidget {
  const SearchBusScreen({super.key});

  @override
  State<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends State<SearchBusScreen> {
  final searchController = TextEditingController();
  bool isLoading = false;
  List routes = [];
  String message = '';

  Future<void> searchBus() async {
    setState(() {
      isLoading = true;
      message = '';
      routes = [];
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/bus/search?location=${searchController.text}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          routes = data['routes'];
          if (routes.isEmpty) {
            message = 'No buses found for this location';
          }
        });
      }
    } catch (e) {
      setState(() => message = 'Error connecting to server');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Bus'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter destination',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : searchBus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                    ? SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Results
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),

            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  final bus = route['buses'];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.directions_bus, color: Colors.white),
                      ),
                      title: Text(route['route_name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${route['start_location']}'),
                          Text('To: ${route['end_location']}'),
                          if (bus != null)
                            Text('Bus: ${bus['bus_number']}',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
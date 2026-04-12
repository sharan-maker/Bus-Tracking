import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlternateRoutesScreen extends StatefulWidget {
  const AlternateRoutesScreen({super.key});

  @override
  State<AlternateRoutesScreen> createState() => _AlternateRoutesScreenState();
}

class _AlternateRoutesScreenState extends State<AlternateRoutesScreen> {
  bool isLoading = false;
  Map? alternateRoute;
  String message = '';
  int selectedRouteId = 1;

  Future<void> checkAlternateRoute() async {
    setState(() {
      isLoading = true;
      message = '';
      alternateRoute = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/bus/alternate/$selectedRouteId'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['alternate_route'] != null) {
          setState(() => alternateRoute = data['alternate_route']);
        } else {
          setState(() => message = data['message'] ?? 'No alternate route available');
        }
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
        title: Text('Alternate Routes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check if your bus route has an alternate when unavailable',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Route selector
            Text('Select Your Route:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedRouteId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.route),
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text('Route 1 - College to City Center')),
                DropdownMenuItem(value: 2, child: Text('Route 2 - College Main Gate to City')),
                DropdownMenuItem(value: 3, child: Text('Route 3 - Alt Route')),
              ],
              onChanged: (value) => setState(() => selectedRouteId = value!),
            ),
            const SizedBox(height: 16),

            // Check button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : checkAlternateRoute,
                icon: isLoading
                  ? SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(Icons.search),
                label: Text('Check Alternate Route',
                  style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (message.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 8),
                    Text(message,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center),
                  ],
                ),
              ),

            if (alternateRoute != null) ...[
              Text('⚠️ Your bus is unavailable!',
                style: TextStyle(color: Colors.red,
                  fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_bus, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Take This Bus Instead!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green)),
                        ],
                      ),
                      Divider(),
                      if (alternateRoute!['routes'] != null) ...[
                        _infoRow('Route Name',
                          alternateRoute!['routes']['route_name'] ?? 'N/A'),
                        _infoRow('From',
                          alternateRoute!['routes']['start_location'] ?? 'N/A'),
                        _infoRow('To',
                          alternateRoute!['routes']['end_location'] ?? 'N/A'),
                      ],
                      _infoRow('Reason', alternateRoute!['reason'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
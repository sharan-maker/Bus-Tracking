import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  final String token;
  const AdminScreen({super.key, required this.token});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // For marking bus unavailable
  final busIdController = TextEditingController();
  final reasonController = TextEditingController();

  // For adding bus
  final busNumberController = TextEditingController();
  final capacityController = TextEditingController();

  // For alternate route
  final originalRouteController = TextEditingController();
  final alternateRouteController = TextEditingController();
  final altReasonController = TextEditingController();

  bool isLoading = false;
  String message = '';
  bool isSuccess = false;

  Future<void> markBusUnavailable() async {
    setState(() { isLoading = true; message = ''; });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/bus/unavailable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'bus_id': int.parse(busIdController.text),
          'reason': reasonController.text,
        }),
      );
      final data = jsonDecode(response.body);
      setState(() {
        isSuccess = response.statusCode == 200;
        message = data['message'] ?? data['error'];
      });
    } catch (e) {
      setState(() { isSuccess = false; message = 'Error: $e'; });
    }
    setState(() => isLoading = false);
  }

  Future<void> addBus() async {
    setState(() { isLoading = true; message = ''; });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/bus/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'bus_number': busNumberController.text,
          'capacity': int.parse(capacityController.text),
        }),
      );
      final data = jsonDecode(response.body);
      setState(() {
        isSuccess = response.statusCode == 201;
        message = data['message'] ?? data['error'];
      });
    } catch (e) {
      setState(() { isSuccess = false; message = 'Error: $e'; });
    }
    setState(() => isLoading = false);
  }

  Future<void> setAlternateRoute() async {
    setState(() { isLoading = true; message = ''; });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/bus/alternate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'original_route_id': int.parse(originalRouteController.text),
          'alternate_route_id': int.parse(alternateRouteController.text),
          'reason': altReasonController.text,
        }),
      );
      final data = jsonDecode(response.body);
      setState(() {
        isSuccess = response.statusCode == 201;
        message = data['message'] ?? data['error'];
      });
    } catch (e) {
      setState(() { isSuccess = false; message = 'Error: $e'; });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Control Panel'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Message display
            if (message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSuccess ? Colors.green : Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text(message,
                      style: TextStyle(
                        color: isSuccess ? Colors.green : Colors.red))),
                  ],
                ),
              ),

            // SECTION 1: Add New Bus
            _sectionTitle('🚌 Add New Bus', Colors.blue),
            const SizedBox(height: 8),
            TextField(
              controller: busNumberController,
              decoration: _inputDecoration('Bus Number (e.g. BUS-005)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Capacity (e.g. 50)'),
            ),
            const SizedBox(height: 8),
            _actionButton('Add Bus', Colors.blue, addBus),

            const SizedBox(height: 24),
            Divider(),
            const SizedBox(height: 16),

            // SECTION 2: Mark Bus Unavailable
            _sectionTitle('⚠️ Mark Bus Unavailable', Colors.red),
            const SizedBox(height: 8),
            TextField(
              controller: busIdController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Bus ID (e.g. 1)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: _inputDecoration('Reason (e.g. Gone for IV trip)'),
            ),
            const SizedBox(height: 8),
            _actionButton('Mark Unavailable', Colors.red, markBusUnavailable),

            const SizedBox(height: 24),
            Divider(),
            const SizedBox(height: 16),

            // SECTION 3: Set Alternate Route
            _sectionTitle('🔄 Set Alternate Route', Colors.orange),
            const SizedBox(height: 8),
            TextField(
              controller: originalRouteController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Original Route ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: alternateRouteController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Alternate Route ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: altReasonController,
              decoration: _inputDecoration('Reason'),
            ),
            const SizedBox(height: 8),
            _actionButton('Set Alternate Route', Colors.orange, setAlternateRoute),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(title,
      style: TextStyle(fontSize: 18,
        fontWeight: FontWeight.bold, color: color));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
          ? SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
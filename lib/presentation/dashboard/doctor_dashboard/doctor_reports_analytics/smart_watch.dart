import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';


class SmartWatchPage extends StatefulWidget {
  final String patientId; // Add a parameter to hold the patient ID

  const SmartWatchPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _SmartWatchPageState createState() => _SmartWatchPageState();
}

class _SmartWatchPageState extends State<SmartWatchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true; // Set to true to show loading initially
  bool hasError = false; // Simulated error state
  Map<String, dynamic>? patientData; // To hold patient details

  @override
  void initState() {
    super.initState();
    fetchPatientData(); // Fetch data when the page initializes
  }

  Future<void> fetchPatientData() async {
    try {
      // Call the API using the common function
      final response = await get('patient-wise-watch-response/${widget.patientId}');

      // Decode the response body
      final decodedResponse = jsonDecode(response);

      // Check if there is an error in the response
      if (decodedResponse['errorCode'] == 200) {
        setState(() {
          patientData = decodedResponse['details'][0]; // Store the patient details
          patientData!['watch_description'] = cleanWatchDescription(patientData!['watch_description']);
          isLoading = false; // Set loading to false
        });
      } else {
        setState(() {
          hasError = true; // Set error state if API call fails
          isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      // Handle any exceptions here
      setState(() {
        hasError = true; // Set error state if exception occurs
        isLoading = false; // Set loading to false
      });
    }
  }

  String cleanWatchDescription(String description) {
    // Remove <p> tags and &nbsp; using regex
    return description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Tabulation and Graphics
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(), // Your custom drawer
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Center(
            child: const Text(
              'Smart Watch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.dehaze_outlined, color: Colors.blue),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // First Tab: Patient List (Tabulation)
            isLoading
                ? Center(child: CircularProgressIndicator()) // Show a loading indicator
                : hasError
                ? Center(child: Text('Error fetching patient details. Please try again later.')) // Show error message
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display fetched patient details
                  Text(
                    'Patient Name: ${patientData?['patientId']['patient_name'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Watch Description: ${patientData?['watch_description'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Watch ID: ${patientData?['watch_id'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Watch Status: ${patientData?['status'] == true ? 'Active' : 'Inactive'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Second Tab: Smart Watch Message
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Please buy our Smart Watch to get smart data",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';


class PatientReportsPage extends StatefulWidget {

  final String patientId;

  const PatientReportsPage({Key? key, required this.patientId}) : super(key: key);
  @override
  _PatientReportsPageState createState() => _PatientReportsPageState();
}

class _PatientReportsPageState extends State<PatientReportsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? patientDetails;

  @override
  void initState() {
    super.initState();
    fetchPatientDetails(); // Call the API when the page is loaded
  }

  Future<void> fetchPatientDetails() async {
    try {
      final response = await get('patient-report/${widget.patientId}');
      final decodedResponse = jsonDecode(response);

      if (decodedResponse['errorCode'] == 200) {
        setState(() {
          patientDetails = decodedResponse['details'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
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
          bottom: TabBar(
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Tabulation"), // Tab for patient list
              Tab(text: "Graphics"),   // Tab for pie chart
            ],
          ),
          title: Center(
            child: const Text(
              'Patient Reports',
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
                ? Center(child: Text('Error fetching patient details.')) // Show error message
                : patientDetails == null
                ? Center(child: Text('No patient details found.')) // No patient details found
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor's Name
                  Text(
                    'Doctor: ${patientDetails!['doctor_id']['name']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Hospital Category
                  Text(
                    'Hospital: ${patientDetails!['hospital_id']['hospital_name']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Patient Details
                  Text(
                    'Patient Name: ${patientDetails!['patient_name']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'City: ${patientDetails!['city']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Age: ${patientDetails!['age']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gender: ${patientDetails!['gender']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Weight: ${patientDetails!['weight']} kg',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Second Tab: Placeholder for patient pie chart
            Center(child: Text("Please buy our Smart watch to get smart data")),
          ],
        ),
      ),
    );
  }
}

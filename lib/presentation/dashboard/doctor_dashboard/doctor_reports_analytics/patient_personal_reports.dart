import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';

class PatientPersonalReportsPage extends StatefulWidget {
  final String patientId;

  const PatientPersonalReportsPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _PatientPersonalReportsPageState createState() => _PatientPersonalReportsPageState();
}

class _PatientPersonalReportsPageState extends State<PatientPersonalReportsPage> {
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      // Your custom drawer
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: const Text(
            'Reports',
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
      body: isLoading
          ? Center(
          child: CircularProgressIndicator()) // Show a loading indicator
          : hasError
          ? Center(
          child: Text('Error fetching patient details.')) // Show error message
          : patientDetails == null
          ? Center(
          child: Text('No patient details found.')) // No patient details found
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor's Name
            Text(
              'Doctor: ${patientDetails!['doctor_id']['name'] ?? "N/A"}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 16),
            // Hospital Category
            Text(
              'Hospital: ${patientDetails!['hospital_id']['hospital_name'] ??
                  "N/A"}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            // Patient Details
            Text(
              'Patient Name: ${patientDetails!['patient_name'] ?? "N/A"}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'City: ${patientDetails!['city'] ?? "N/A"}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Age: ${patientDetails!['age'] ?? "N/A"}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gender: ${patientDetails!['gender'] ?? "N/A"}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Weight: ${patientDetails!['weight'] ?? "N/A"} kg',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),

            // Treatment Details
            Text(
              'Treatment Details:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 8),
            if (patientDetails?['treatment_details'] == null)
              Center(child: Text('Treatment data unavailable.'))
            else
              ...[
                Text(
                  'Symptoms: ${patientDetails!['treatment_details']['symptoms'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Breathlessness: ${patientDetails!['treatment_details']['breathlessQuickly'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Diet: ${patientDetails!['treatment_details']['diet'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Medications: ${patientDetails!['treatment_details']['medDrug'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sleep Quality: ${patientDetails!['treatment_details']['sleepQuality'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nature of Pulse: ${patientDetails!['treatment_details']['natureofPulse'] ??
                      "N/A"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
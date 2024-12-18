import 'dart:convert';
import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_reports_analytics/patient_personal_reports.dart';

import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_reports_analytics/smart_watch.dart';
import 'package:flutter/material.dart';

import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import 'Pie_chart/patient_piechart.dart';

class PatientListPage extends StatefulWidget {
  final String doctorId;

  PatientListPage({required this.doctorId});

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? doctorDetails;
  bool isLoading = true;
  bool hasError = false;
  int patientCount = 0;  // Declare patientCount to hold the API data
  int totalWatchCount = 0; // Variable to hold the total watch count

  @override
  void initState() {
    super.initState();
    fetchPatientList(); // Call the function to fetch patients on page load
    fetchTotalWatchCount(); // Fetch total watch count on page load
  }
  Future<void> fetchTotalWatchCount() async {
    try {
      final response = await get('doctor-wise-watch-count/${widget.doctorId}');
      final data = jsonDecode(response); // Decode the response JSON

      if (data['errorCode'] == 200) {
        setState(() {
          totalWatchCount = data['totalWatchDataCount']; // Store total watch count
        });
      }
    } catch (error) {
      // Handle any errors during the request
      print('Error fetching watch count: $error');
    }
  }

  Future<void> fetchPatientList() async {
    try {
      // Fetch patient list based on doctorId
      final response = await get('doctor-wise-patient-list/${widget.doctorId}');
      final data = jsonDecode(response); // Decode the response JSON

      if (data['errorCode'] == 200) {
        setState(() {
          doctorDetails = data['details']; // Assign doctor details to the map
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true; // Handle non-200 error code
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true; // Handle any errors during the request
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
              'Patient List',
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
            // First Tab: Patient List
            isLoading
                ? Center(child: CircularProgressIndicator()) // Show a loading indicator
                : hasError
                ? Center(child: Text('Error fetching patients.')) // Show error message
                : doctorDetails == null
                ? Center(child: Text('No doctor details found.')) // No doctor details found
                : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // Doctor's Name
                Text(
                  'Doctor: ${doctorDetails!['name']}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 16),
                // Hospital Category
                Text(
                  'Hospital Category: ${doctorDetails!['hospital_category'][0]['name']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                // Hospital Name
                Text(
                  'Hospital: ${doctorDetails!['hospital_category'][0]['hospital_list'][0]['hospital_name']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),

                SizedBox(height: 16),
                // Total Watch Count
                Text(
                  'Total Watch: $totalWatchCount', // Display total watch count
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                // Patient List
                // Patient List
                Text(
                  'Patients:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: doctorDetails!['hospital_category'][0]['hospital_list'][0]['patient_details'].length,
                  itemBuilder: (context, index) {
                    final patient = doctorDetails!['hospital_category'][0]['hospital_list'][0]['patient_details'][index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end, // Pushes the button to the right
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_forward, color: Colors.teal),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PatientPersonalReportsPage(
                                          patientId: patient['_id'], // Pass patient ID or other relevant data
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            Text(
                              'Name: ${patient['patient_name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),

                            SizedBox(height: 4),
                            Text(
                              'City: ${patient['city']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Age: ${patient['age']}, Gender: ${patient['gender']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.email_outlined, color: Colors.teal),
                                Expanded(
                                  child: Text(
                                    patient['email_id'],
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.watch, color: Colors.teal),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SmartWatchPage(patientId: patient['_id']), // Pass the patient ID
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Patient Smart Data >>wwl',
                                      style: TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.phone_outlined, color: Colors.teal),
                                Expanded(
                                  child: Text(
                                    patient['mobile_number'],
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
            // Second Tab: Patient Pie Chart
            PatientPieChartPage(doctorId: widget.doctorId), // Navigate to the PatientPieChartPage
          ],
        ),
      ),
    );
  }
}

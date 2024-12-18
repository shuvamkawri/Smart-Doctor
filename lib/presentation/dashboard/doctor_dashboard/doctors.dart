import 'dart:convert';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/material.dart';
import '../../../domain/common_fuction_api.dart';
import '../../../widgets/nav_drawer.dart';
import 'doctor_reports_analytics/Pie_chart/doctor_list_piechart.dart';
import 'doctor_reports_analytics/patient_list.dart';

class DoctorsPage extends StatefulWidget {
  final String hospitalId;

  DoctorsPage({required this.hospitalId});

  @override
  _DoctorsPageState createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> doctors = []; // To store the list of doctors
  Map<String, int> patientCounts = {}; // Map to store patient count for each doctor
  late String selectedDoctorId; // To store the selected doctor ID
  int doctorCount = 0; // To store the count of doctors

  @override
  void initState() {
    super.initState();
    fetchDoctors(widget.hospitalId);
    fetchDoctorsLength(widget.hospitalId);
  }

  Future<void> fetchDoctors(String hospitalId) async {
    try {
      final response = await get('doctor-list/$hospitalId'); // Fetch doctors from API
      final data = jsonDecode(response);

      if (data['errorCode'] == 200) {
        setState(() {
          doctors = data['details']; // Store the list of doctors

          isLoading = false;
        });

        if (doctors.isEmpty) {
          _showNoDoctorsDialog(); // Show a dialog if no doctors are available
        }
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (error) {
      print('Error fetching doctors: $error');
    }
  }


  Future<void> fetchDoctorsLength(String hospitalId) async {
    try {
      // Call the API using the 'get' function from your common API helper
      final response = await get('hospital-wise-doctor-count/$hospitalId');

      // Log the response body
      print('Response body: $response');

      // Parse the JSON response
      final data = jsonDecode(response);

      // Check for success based on errorCode
      if (data['errorCode'] == 200) {
        setState(() {
          // Update the doctor count based on the 'details' field
          doctorCount = data['details']; // Store the count of doctors
          isLoading = false;
        });

        // If doctorCount is 0, show a dialog indicating no doctors
        if (doctorCount == 0) {
          _showNoDoctorsDialog();
        }
      } else {
        // Handle error case, if the API does not return a success code
        print('Error: ${data['message']}');
      }
    } catch (error) {
      print('Error fetching doctor count: $error');
    }
  }


  Future<void> fetchPatientData(String doctorId) async {
    try {
      final response = await get('patient-count/$doctorId'); // Use selected doctor ID to fetch patient count
      final data = jsonDecode(response);

      if (data['errorCode'] == 200) {
        if (data['details'] is int) {
          setState(() {
            patientCounts[doctorId] = data['details']; // Store the patient count for the specific doctor
          });
        } else {
          throw Exception('Unexpected data format: details is not an integer');
        }
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (error) {
      print('Error fetching patient data: $error');
    }
  }

  void _showNoDoctorsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Doctors Available'),
          content: const Text('There are no doctors listed in this hospital.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Navigate back to the previous page
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _callDoctor(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber); // Trigger the phone call
  }

  // Method to navigate to PatientListPage with doctorId
  void _navigateToPatientList(String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientListPage(doctorId: doctorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Tabulation and Graphics
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(), // Custom drawer
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Tabulation"),
              Tab(text: "Graphics"),
            ],
          ),
          title: Text(
            "Doctors List ($doctorCount)", // Dynamically display the doctor count here
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          centerTitle: true,
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
            // Tabulation Tab - List of doctors
            isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: doctors.isEmpty
                  ? const Text(
                'No doctors available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              )
                  :ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  final doctorId = doctor['_id'];

                  return GestureDetector(
                    onTap: () async {
                      // Fetch the patient count when a doctor card is tapped
                      await fetchPatientData(doctorId);
                    },
                    child: Card(
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
                            // Doctor Name Row with navigation icon on the right-hand side
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align widgets to opposite sides
                              children: [
                                Text(
                                  doctor['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _navigateToPatientList(doctor['_id']),
                                  child: const Text(
                                    'Patient>>',
                                    style: TextStyle(
                                      color: Colors.blue, // Set the text color to blue
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.underline, // Add underline
                                      decorationColor: Colors.blue, // Set underline color to blue
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Doctor specialization
                            Text(
                              'Specialist: ${doctor['specialist']['category']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Email and Next Icon in a Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.email_outlined, color: Colors.teal),
                                Expanded(
                                  child: Text(
                                    doctor['email_id'],
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Patient count Row with interactive text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => fetchPatientData(doctor['_id']), // Trigger patient data fetch
                                  child: Row(
                                    children: [
                                      const Icon(Icons.touch_app, color: Colors.teal), // Tap icon
                                      const SizedBox(width: 4), // Spacing between icon and text
                                      Text(
                                        'Total patient: ${patientCounts[doctor['_id']] ?? 'Tap to see'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Phone number Row with call icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => _callDoctor(doctor['mobile_number']),
                                  child: const Icon(Icons.phone_outlined, color: Colors.teal),
                                ),
                                Expanded(
                                  child: Text(
                                    doctor['mobile_number'],
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            ),
            // Graphics Tab - Navigate to DoctorPieChartPage
            DoctorPieChartPage(hospitalId: widget.hospitalId),
          ],
        ),
      ),
    );
  }
}


import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_reports_analytics/symptomps_analysis.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import Shared Preferences
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../doctors.dart';
import 'doctor_reports_analytics.dart';

class HospitalListPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  HospitalListPage({required this.categoryId, required this.categoryName});

  @override
  _HospitalListPageState createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> hospitals = [];
  bool isLoading = true;

  // Variable to hold the selected report type, default to 'management'
  String _selectedReportType = 'management';  // Default to 'management'

  @override
  void initState() {
    super.initState();
    fetchHospitals(widget.categoryId);
    _getSavedReportType(); // Fetch saved report type on page load
  }

  Future<void> fetchHospitalLength(String categoryId) async {
    try {
      // Call the API using the 'get' function from your common API helper
      final response = await get('hospital-category-wise-hospital-count/$categoryId');

      // Log the response body
      print('Response body: $response');

      // Parse the JSON response
      final data = jsonDecode(response);

      // Check for success based on errorCode
      if (data['errorCode'] == 200) {
        setState(() {
          // Update hospitals list with the 'details' from the response
          hospitals = List.generate(data['details'], (index) => {
            'hospital_name': 'Hospital $index', // Placeholder for hospital names
            '_id': 'hospital_id_$index' // Placeholder for hospital IDs
          });
          isLoading = false;
        });

        // If no hospitals, show the dialog
        if (hospitals.isEmpty) {
          _showNoHospitalsDialog();
        }
      } else {
        // Handle error case
        print('Error: ${data['message']}');
      }
    } catch (error) {
      print('Error fetching hospitals: $error');
    }
  }



  // Method to get the saved report type from Shared Preferences
  Future<void> _getSavedReportType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedReportType = prefs.getString('selectedReportType');

    // If the user came back from SymptomsPage, default to 'management'
    if (savedReportType == 'symptom_analysis') {
      setState(() {
        _selectedReportType = 'management';  // Default to 'management'
        _saveReportType(_selectedReportType);  // Save the updated type
      });
    } else if (savedReportType != null) {
      setState(() {
        _selectedReportType = savedReportType;
      });
    } else {
      _saveReportType(_selectedReportType);  // Save the default 'management' type
    }
  }



  // Method to save the selected report type to Shared Preferences
  Future<void> _saveReportType(String reportType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedReportType', reportType);
    print('Saved report type: $reportType');
  }

  Future<void> fetchHospitals(String categoryId) async {
    try {
      final response = await get('hospital-list/$categoryId');
      print('Response body: ${response}');
      final data = jsonDecode(response);
      if (data['errorCode'] == 200) {
        setState(() {
          hospitals = data['details'];
          isLoading = false;
        });

        if (hospitals.isEmpty) {
          _showNoHospitalsDialog();
        }
      }
    } catch (error) {
      print('Error fetching hospitals: $error');
    }
  }

  void _showNoHospitalsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Hospitals Available'),
          content: Text('There are no hospitals listed in this category.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorReportsAnalytics()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            height: 110,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Placeholder for additional navigation
                    },
                      child:Row(
                        children: [
                          Text(
                            '${widget.categoryName} (H-${hospitals.length})', // Dynamic hospital count
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.dehaze_outlined),
                      color: Colors.blue,
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Select Report Type:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: 'patient',
                      groupValue: _selectedReportType,
                      onChanged: (value) {
                        setState(() {
                          _selectedReportType = value!;
                          _saveReportType(_selectedReportType);
                          if (_selectedReportType == 'patient') {
                            if (hospitals.isNotEmpty) {
                              final hospitalId = hospitals[0]['_id'];
                              // Navigate to the desired page
                            }
                          }
                        });
                      },
                    ),
                    Text('Patient Reports'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Inside Radio button for 'symptom_analysis'
                    Radio<String>(
                      value: 'symptom_analysis',
                      groupValue: _selectedReportType,
                      onChanged: (value) {
                        setState(() {
                          _selectedReportType = value!;
                          _saveReportType(_selectedReportType);
                          if (_selectedReportType == 'symptom_analysis') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SymptomsPage()),
                            ).then((_) {
                              // Reset the report type to 'management' when coming back
                              setState(() {
                                _selectedReportType = 'patient';  // Default to 'management'
                                _saveReportType(_selectedReportType);  // Save the updated type
                              });
                            });
                          }
                        });
                      },
                    ),
                    Text('Symptom Analysis'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = hospitals[index];
                  final hospitalName = hospital['hospital_name'] ?? 'Unknown Hospital';
                  final doctorCount = hospital['doctorCount'] ?? 0; // Extract doctorCount
                  final patientCount = hospital['patientCount'] ?? 0; // Extract patientCount
                  final hospitalId = hospital['_id'] ?? 'Unknown Hospital';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10.0),
                      title: Text(
                        hospitalName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Doctors: $doctorCount | Patients: $patientCount',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorsPage(hospitalId: hospitalId),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}



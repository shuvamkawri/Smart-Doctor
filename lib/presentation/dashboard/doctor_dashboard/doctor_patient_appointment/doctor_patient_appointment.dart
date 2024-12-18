import 'dart:convert';
import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_patient_appointment/patient_reports_page/patient_report_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../notification.dart';
import '../../../../widgets/nav_drawer.dart';
import '../Video_consultancy/call_IDInputPage.dart';

class PatientAppointmentPage extends StatefulWidget {
  const PatientAppointmentPage({super.key});

  @override
  State<PatientAppointmentPage> createState() => _PatientAppointmentPageState();
}

class _PatientAppointmentPageState extends State<PatientAppointmentPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NotificationService _notificationService = NotificationService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? name;
  String? age;
  String? condition;
  String? phone;
  String? videoCallRequest;
  List<Map<String, dynamic>> patients = [];


  // Future<void> patientAppointList() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String userId = prefs.getString('user_id') ?? '';
  //
  //   // Print request data
  //   print('Request Data:');
  //   print('URL: doctor/doctor-appointment-list/$userId');
  //   print('Patient Appointment ID: $userId');
  //
  //   // Make the HTTP request
  //   final response = await get("doctor/doctor-appointment-list/$userId");
  //
  //   // Print response data
  //   print('Body: ${response}');
  //
  //   // Decode JSON response
  //   final data = json.decode(response);
  //
  //   // Check if the request was successful
  //   if (data['errorCode'] == 200) {
  //     var responseData = data['details'];
  //     setState(() {
  //       patients = responseData.map<Map<String, dynamic>>((patient) {
  //         return {
  //           'name': patient['patient_name'],
  //           'age': patient['age_year'],
  //           'condition': patient['treatment_comment'],
  //           'phone': patient['patient_number'],
  //           'videoCallRequest': patient['videoCallRequest'],
  //           'approvedCallDate': null,
  //         };
  //       }).toList();
  //     });
  //   } else {
  //     throw Exception(
  //         'Failed to load patient information: ${data['errorMessage']}');
  //   }
  // }


  Future<void> patientAppointList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Print request data
    print('Request Data:');
    print('URL: doctor/doctor-appointment-list/$userId');
    print('Patient Appointment ID: $userId');

    // Make the HTTP request
    final response = await get("doctor/doctor-appointment-list/$userId");

    // Print response data
    print('Body: ${response}');

    // Decode JSON response
    final data = json.decode(response);

    // Check if the request was successful
    if (data['errorCode'] == 200) {
      var responseData = data['details'];
      if (responseData.isEmpty) {
        // Show dialog if no data found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("No Data Found"),
              content: Text("No appointments available ."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          patients = responseData.map<Map<String, dynamic>>((patient) {
            return {
              'name': patient['patient_name'],
              'age': patient['age_year'],
              'condition': patient['treatment_comment'],
              'phone': patient['patient_number'],
              'videoCallRequest': patient['videoCallRequest'],
              'approvedCallDate': null,
            };
          }).toList();
        });
      }
    } else {
      throw Exception('Failed to load patient information: ${data['errorMessage']}');
    }
  }


  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return patients;
    } else {
      return patients
          .where((patient) =>
          patient['phone'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _requestVideoCallApproval(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Approve Video Call Request'),
          content: Text(
            'Patient ${patients[index]['name']} has requested a video call on ${patients[index]['videoCallRequest']}. Do you approve?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Approve the video call request
                  patients[index]['approvedCallDate'] =
                  patients[index]['videoCallRequest'];
                });

                // Show notification that the request has been approved
                _showVideoCallApprovedNotification(
                    '${patients[index]['name']}, your video call request has been approved.');

                Navigator.pop(context);
              },
              child: Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rescheduleVideoCall(index);
              },
              child: Text('Reschedule'),
            ),
          ],
        );
      },
    );
  }


  void _rescheduleVideoCall(int index) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (newTime != null) {
        setState(() {
          patients[index]['approvedCallDate'] =
              DateFormat('yyyy-MM-dd HH:mm').format(
                DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  newTime.hour,
                  newTime.minute,
                ),
              );
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Video Call Rescheduled'),
              content: Text(
                  'The video call has been rescheduled to ${patients[index]['approvedCallDate']}. A notification will be sent to the patient.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _deletePatient(int index) {
    setState(() {
      patients.removeAt(index);
    });
  }


  @override
  void initState() {
    super.initState();
    _notificationService.initialize(); // Initialize the notification service
    patientAppointList();
  }

  Future<void> _showVideoCallApprovedNotification(String message) async {
    await _notificationService.showNotification(
        'Video Call Request Approved', message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: lightWhite,
      body: Column(
        children: [
          Container(
            height: 110,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(
                                    0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Text(
                          "Patient Appointment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(
                                    0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.dehaze_outlined),
                            color: Colors.blue,
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 55,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Phone Number',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: _filteredPatients.map((patient) {
                    int index = patients.indexOf(patient);

                    // Convert the videoCallRequest to DateTime
                    DateTime? videoCallRequestTime = patient['videoCallRequest'] != null
                        ? DateTime.tryParse(patient['videoCallRequest'])
                        : null;

                    // Check if the video call request time is expired or upcoming
                    bool isExpired = videoCallRequestTime != null &&
                        videoCallRequestTime.isBefore(DateTime.now());

                    return Opacity(
                      opacity: isExpired ? 0.5 : 1.0, // Set lower opacity only if expired
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(patient['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Age: ${patient['age']}"),
                              Text("Condition: ${patient['condition']}"),
                              Text("Phone: ${patient['phone']}"),
                              Text("Slot: ${patient['videoCallRequest']}"),
                              if (patient['approvedCallDate'] != null)
                                Column(
                                  children: [
                                    Text("Approved Call Date: ${patient['approvedCallDate']}"),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to CallIDInputPage when the icon is tapped
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CallIDInputPage(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.video_call,
                                        color: Colors.green, // Set icon color to green
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: isExpired
                              ? null // Hide three dots if expired
                              : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'request_video_call') {
                                _requestVideoCallApproval(index);
                              } else if (value == 'delete') {
                                _deletePatient(index);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'request_video_call', 'delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(
                                    choice == 'request_video_call'
                                        ? 'Request Video Call'
                                        : 'Delete',
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientReportPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),


      ],
      ),
    );
  }
}






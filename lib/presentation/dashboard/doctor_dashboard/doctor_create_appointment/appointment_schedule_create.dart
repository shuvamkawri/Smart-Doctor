import 'dart:convert';
import 'dart:math';

import 'package:ai_medi_doctor/presentation/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../doctor_model_pages/hospital_model.dart';

class CreateAppointment extends StatefulWidget {
  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  TimeOfDay? _morningSlotTime;
  TimeOfDay? _afternoonSlotTime;
  TimeOfDay? _eveningSlotTime;
  DateTime? _weekDays;
  bool _isLoading = false;
  List<HospitalAppointData> hospitalSelect = [];
  String? selectedHospital;



  Future<void> _selectTime(BuildContext context, TimeOfDay? initialTime, ValueChanged<TimeOfDay> onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != initialTime) {
      onSelected(picked);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _weekDays ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _weekDays) {
      setState(() {
        _weekDays = picked;
      });
    }
  }

  Future<void> hospitalData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    try {
      final response = await get(
        'schedule/hospital-list/$userId',
        headers: {'accept': '*/*'},
      );

      print('Response received: $response');

      final decodedResponse = json.decode(response);
      print('Decoded response: $decodedResponse');
      if (!mounted) return;
      setState(() {
        hospitalSelect = (decodedResponse['result']['details']['hospital'] as List)
            .map((hospitalData) => HospitalAppointData.fromJson(hospitalData))
            .toList();
        print(hospitalSelect);
      });

      print('Treatment loaded successfully: $hospitalSelect');
    } catch (error) {
      print('Failed to load treatmenttype : $error');
    }
  }

  Future<void> createAppointmentSchedule () async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    String endpoint = 'schedule/create';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      "doctor_id": userId,
      "hospital": selectedHospital,
      "morningSlot": [
        {
          "morning_slot_time": _morningSlotTime != null ? _morningSlotTime!.format(context) : null
        }
      ],
      "afternoonSlot": [
        {
          "afternoon_slot_time": _afternoonSlotTime != null ? _afternoonSlotTime!.format(context) : null
        }
      ],
      "eveningSlot": [
        {
          "evening_slot_time": _eveningSlotTime != null ? _eveningSlotTime!.format(context) : null
        }
      ],
      "week_days": _weekDays != null ? _weekDays!.toLocal().toString().split(' ')[0] : null,
    };

    String body = jsonEncode(requestBody);

    print('Request body: $body');

    try{
      var responseBody = await post(endpoint, headers: headers, body: body);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      print('Response body: $responseBody');
      String message = responseJson['message'] ?? 'Unknown error occurred';


      if (responseJson["result"]['errorCode'] == 200) {

        showSuccessAlert(context, message);

      } else if (responseJson['errorCode'] == 201) {
        showErrorAlert(context, message);
      }

    }catch (e) {
      // Handle errors
      print('Error: $e');
      showErrorAlert(context, "An error occurred: $e");
    }

  }

  void showSuccessAlert(BuildContext context, String message)  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text("You have successfully create schedule appointment."),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(),));
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    hospitalData();
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
                                offset: Offset(0, 1), // changes position of shadow
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
                          "Create Appointment",
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
                                offset: Offset(0, 1), // changes position of shadow
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
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // TextFormField(
                      //   controller: _doctorController,
                      //   decoration: InputDecoration(labelText: 'Doctor'),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter doctor name';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      Container(
                        child: DropdownButtonFormField<
                            String>(
                          decoration: InputDecoration(
                            labelText: 'Hospital',
                            hintText: 'Select Hospital',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  8.0),
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 16.0,
                            ),
                          ),
                          value: selectedHospital,
                          items: hospitalSelect.map(
                                  (HospitalAppointData hos) {
                                return DropdownMenuItem<
                                    String>(
                                  value: hos.id,
                                  child: Text(hos.name),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedHospital = newValue;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Text('Morning Slot Time:',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Text(' ${_morningSlotTime?.format(context) ?? 'Not selected'}',style: TextStyle(fontSize: 14),),
                          ],
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context, _morningSlotTime, (time) {
                          setState(() {
                            _morningSlotTime = time;
                          });
                        }),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Text('Afternoon Slot Time: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Text('${_afternoonSlotTime?.format(context) ?? 'Not selected'}',style: TextStyle(fontSize: 14),),
                          ],
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context, _afternoonSlotTime, (time) {
                          setState(() {
                            _afternoonSlotTime = time;
                          });
                        }),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Text('Evening Slot Time: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Text('${_eveningSlotTime?.format(context) ?? 'Not selected'}'),
                          ],
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context, _eveningSlotTime, (time) {
                          setState(() {
                            _eveningSlotTime = time;
                          });
                        }),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Text('Week Days: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Text('${_weekDays != null ? _weekDays!.toLocal().toString().split(' ')[0] : 'Not selected'}'),
                          ],
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),

                      SizedBox(height: 20),

                      Container(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              createAppointmentSchedule();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          )
                              : Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

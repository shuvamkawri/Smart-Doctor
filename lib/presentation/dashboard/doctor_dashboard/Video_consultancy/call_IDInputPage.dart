import 'dart:convert';

import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/Video_consultancy/video_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/common_fuction_api.dart';

class CallIDInputPage extends StatefulWidget {
  const CallIDInputPage({Key? key}) : super(key: key);

  @override
  _CallIDInputPageState createState() => _CallIDInputPageState();
}

class _CallIDInputPageState extends State<CallIDInputPage> {
  final _callIDController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  DateTime? _selectedDateTime;
  String _selectedCallOption = 'Instant'; // Default option
  String _selectedCallType = 'One-on-One Video'; // Default value
  String _selectedSendOption = 'Email'; // Default to email for sending call ID

  String _generateCallID() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _sendEmail(String email, String callID, {DateTime? scheduledDateTime}) async {
    // Format the scheduled date and time properly
    String formattedDateTime = scheduledDateTime != null
        ? "${scheduledDateTime.toLocal().toString().split('.')[0]}" // Remove milliseconds for a cleaner look
        : "N/A";

    // Prepare the email body
    final requestBody = jsonEncode({
      "email": email,
      "call_id": callID,
      "scheduled_time": formattedDateTime,
    });

    print('Sending email to: $email with Call ID: $callID ');

    if (scheduledDateTime != null) {
      print('Scheduled for: $formattedDateTime'); // Print scheduled time for confirmation
    }

    // Print the request body before sending
    print('Request body: $requestBody');

    // Call the API to send the email
    final response = await post(
      'video-call/request-send',
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );


    final responseBody = jsonDecode(response);

    // Check if the errorCode is 200 and display the message from the response
    if (responseBody['errorCode'] == 200) {
      String successMessage = responseBody['message'] ?? 'Email sent successfully!'; // Fallback if message is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
        ),
      );
    } else {
      String errorMessage = responseBody['message'] ?? 'Failed to send email. Please try again.'; // Fallback for error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }





  Future<void> _sendSMS(String mobileNumber, String callID, {DateTime? scheduledDateTime}) async {
    String smsContent = 'Call ID: $callID';
    if (scheduledDateTime != null) {
      smsContent += '\nScheduled for: ${scheduledDateTime.toLocal()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SMS sent to $mobileNumber with Call ID: $callID${scheduledDateTime != null ? ' scheduled for: ${scheduledDateTime.toLocal()}' : ''}')),
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void _onRadioButtonChanged(String? value) {
    setState(() {
      _selectedCallOption = value!;
      if (_selectedCallOption == 'Instant') {
        _callIDController.text = _generateCallID(); // Auto-generate call ID for instant calls
      }
    });
  }

  void _onSendOptionChanged(String? value) {
    setState(() {
      _selectedSendOption = value!;
    });
  }

  void _joinCall() {
    final callID = _callIDController.text.isNotEmpty ? _callIDController.text : _generateCallID();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CallPage(
    //       callID: callID,
    //       isGroupCall: _selectedCallType == 'Group Video',
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video Call Options',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Choose Call Option:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Instant',
                    groupValue: _selectedCallOption,
                    onChanged: _onRadioButtonChanged,
                  ),
                  const Text('Instant Video Call', style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Schedule',
                    groupValue: _selectedCallOption,
                    onChanged: _onRadioButtonChanged,
                  ),
                  const Text('Schedule Video Call', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),

              // Call ID Field
              TextField(
                controller: _callIDController,
                decoration: InputDecoration(
                  labelText: 'Generated Call ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: const Icon(Icons.videocam, color: Colors.teal),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy, color: Colors.teal),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _callIDController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call ID copied to clipboard')),
                      );
                    },
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),

              if (_selectedCallOption == 'Schedule')
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick Date and Time for Call', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              if (_selectedDateTime != null && _selectedCallOption == 'Schedule')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Scheduled for: ${_selectedDateTime!.toLocal()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),

              const SizedBox(height: 20),

              // Radio buttons for selecting Email or SMS
              const Text(
                'Choose Send Option:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Email',
                    groupValue: _selectedSendOption,
                    onChanged: _onSendOptionChanged,
                  ),
                  const Text('Email', style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'SMS',
                    groupValue: _selectedSendOption,
                    onChanged: _onSendOptionChanged,
                  ),
                  const Text('SMS', style: TextStyle(fontSize: 16)),
                ],
              ),

              const SizedBox(height: 20),

              if (_selectedSendOption == 'Email') ...[
                const Text(
                  'Enter Email to Send Call ID:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.teal),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],

              if (_selectedSendOption == 'SMS') ...[
                const Text(
                  'Enter Mobile Number to Send Call ID:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],

              const SizedBox(height: 20),

              // Send Email or SMS Button
              Center(
                child:ElevatedButton.icon(
                  onPressed: () {
                    final callID = _callIDController.text.isNotEmpty ? _callIDController.text : _generateCallID();
                    if (_selectedSendOption == 'Email') {
                      _sendEmail(_emailController.text, callID, scheduledDateTime: _selectedDateTime);
                    } else {
                      _sendSMS(_mobileController.text, callID, scheduledDateTime: _selectedDateTime);
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text('Send Call ID', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),

              ),

              const SizedBox(height: 30),

              // Join Call Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _joinCall,
                  icon: const Icon(Icons.video_call, color: Colors.white),
                  label: const Text('Join Call', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

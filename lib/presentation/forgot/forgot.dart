import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import '../authentication/registration.dart';
import 'verifyOtp.dart';
import 'package:http/http.dart' as http;


class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _mobileController = TextEditingController();
  String _inputText = '';

  String _enteredEmail = '';
  String? callingCode;

  Future<void> _fetchCallingCode() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipregistry.co/?key=a4m6fjgj8cssxtqz'),
      );
      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        setState(() {
          callingCode = parsedResponse['location']['country']['calling_code'];

        });
      } else {
        print('Failed to fetch calling code: ${response.statusCode}');
        // Handle error if needed
      }
    } catch (e) {
      print('Error fetching calling code: $e');
      // Handle error if needed
    }
  }


  Future<void> _sendOTP() async {
    // Strip the "+" prefix from the country code
    // String countryCode = _selectedCountryCode.startsWith('+')
    //     ? _selectedCountryCode.substring(1)
    //     : _selectedCountryCode;
    // Make the API call

    SharedPreferences prefs = await SharedPreferences.getInstance();
     String? callingCodeData=prefs.getString("calling_code");

   print(callingCodeData);
    final response = await post(
      'user/generate-otp-for-forgot-password',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "country_code": callingCodeData,
        "mobile_no": _mobileController.text,
      }),
    );

    if (_mobileController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: ('Please enter mobile number'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Print the response body
    print('Response Body: $response');

    // Parse the response
    final Map<String, dynamic> responseData = json.decode(response);

    // Check if success is true
    if (responseData['errorCod'] == 200) {
      // If success, navigate to OTPVerificationPage
      _showSuccessDialog(context,"OTP Send on resgestered mobile number");
    } else {

      Fluttertoast.showToast(
        msg: responseData['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("OTP send successfully on regester mobile",style: TextStyle(fontWeight: FontWeight.w500),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OTPVerificationPage(mobile: _mobileController.text),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCallingCode();
    print("Calling code : $callingCode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue, // Set the background color here
      appBar: null,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.pop(context); // Navigate back
              //     },
              //     child: Container(
              //       margin: EdgeInsets.only(left: 20, top: 15),
              //       padding: EdgeInsets.all(16.0),
              //       child: Icon(
              //         Icons.keyboard_arrow_left,
              //         size: 30,
              //         color: Colors.blue,
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.2,
                  // height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.only(left: 10),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image.asset('assets/images/forgot_pass_img.png'),
                ),
              ),
              SizedBox(height: 15),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  'Forgot Password',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),

              SizedBox(height: 8), // Add spacing for subtext
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 280,
                child: Text(
                  'We need your registration email account to send you password reset code!',
                  textAlign: TextAlign.left, // Align text to the left
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 30),

              Container(
                margin: EdgeInsets.only(right:10, left:10),
                child: Text(
                  "Mobile Number *",
                  style:
                      TextStyle(color: lightBlack, fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 5),
              // Container(
              //   height: 76,
              //   margin: EdgeInsets.only(right:10, left:10),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(8.0),
              //   ),
              //   child: IntlPhoneField(
              //     controller: _mobileController,
              //     decoration: InputDecoration(
              //       hintText: '926292xxxx',
              //       hintStyle: TextStyle(
              //           fontWeight: FontWeight.w400, color: Colors.black54),
              //       filled: true,
              //       fillColor: Colors.white,
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(8.0),
              //         borderSide: BorderSide(color: Colors.white),
              //       ),
              //     ),
              //     onChanged: (phone) {
              //       setState(() {
              //         _inputText = phone.completeNumber;
              //         _selectedCountryCode = phone.countryCode!;
              //       });
              //     },
              //   ),
              // ),

              Container(
                margin: EdgeInsets.only(right:10, left:10),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixText: '+$callingCode', // Display the detected calling code
                    prefixIcon: Icon(Icons.call, color: Colors.black54),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.phone, // Use phone keyboard type
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(10), // Limit length to 10 digits
                  ],
                  onChanged: (value) {
                    if (value.length > 10) {
                      _mobileController.text = value.substring(0, 10);
                      _mobileController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _mobileController.text.length),
                      );
                    }
                  },
                ),
              ),

              SizedBox(
                height: 15,
              ),

              SizedBox(height: 20),

              Container(
                width: double.infinity,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  // onPressed: _sendOTP, // Call the function on button press

                  onPressed: (){
                    // Check if mobile number is empty
                    if ((_mobileController.text == null || _mobileController.text.isEmpty) ) {
                      _showToast('Mobile number is required.');
                      return;
                    }

                    if (_mobileController.text.length != 10) {
                      _showToast('Invalid phone number. Please enter a 10-digit number.');
                      return;
                    }

                    _sendOTP();

                  },

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: bgColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordPage(),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );


  }
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength:
      Toast.LENGTH_SHORT,
      // Duration for which the toast is visible
      gravity: ToastGravity.BOTTOM,
      // Position of the toast on the screen
      timeInSecForIosWeb: 1,
      // Duration for iOS (ignored on Android)
      backgroundColor: Colors.blueGrey,
      // Background color of the toast
      textColor: Colors.white,
      // Text color of the message
      fontSize: 16.0, // Font size of the message
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import '../../widgets/custom_dialog_box.dart';
import 'congrats_page.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String _inputText = '';
  String? _selectedUserType; // Declare this variable for the selected user type
  bool _isLoading = false;

  bool _isValidMobile = true;

  late String _storedMobileNo = "";
  late String _storedCountryCode = "";
  String _callingCode = ''; // To store the detected calling code

  @override
  void initState() {
    super.initState();
    _loadDataFromPreferences();
    _loadCallingCode();
  }

  Future<void> _loadCallingCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callingCode = prefs.getString('calling_code')!;

      print('Calling code: $_callingCode');
    });
  }

  void _loadDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedMobileNo = prefs.getString('mobile_no') ?? '';
      _storedCountryCode = prefs.getString('country_code') ?? '';
      // Print the loaded values
      print('Loaded Mobile No: $_storedMobileNo');
      print('Loaded Country Code: $_storedCountryCode');
    });
  }

  Future<void> postData() async {
    String endpoint = 'user/create';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {
      "full_name": _firstNameController.text,
      "email_id": _emailController.text,
      "country_code": _callingCode,
      "mobile_no": _storedMobileNo,
      "status": true,
      "password": _passwordController.text,
      "user_type": "Doctor",
    };
    print('reques$requestData');

    String body = jsonEncode(requestData);

    try {
      var responseBody = await post(endpoint, headers: headers, body: body);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      print('Response body: $responseBody');
      String message = responseJson['message'] ?? 'Unknown error occurred';
      if (responseJson['errorCode'] == 200) {
        // Store full name in shared preferences
        String fullName = responseJson['details']['full_name'];

        String userType = responseJson['details']['user_type'];

        await _storeFullNameInSharedPreferences(fullName);
        await _storeUserDetailsInSharedPreferences(responseJson);

        if (userType == "Doctor") {
          _showSuccessDialogUser(message);
        }
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
      QuickAlertUtils.showErrorAlert(context, "An error occurred: $e");
    }
  }

  void _showSuccessDialogUser(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _animatedColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 64.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CongratsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        );
      },
    );
  }


  List<Color> _animatedColors = [
    Color(0xFF6A11CB), // Initial gradient color
    Color(0xFF2575FC), // Final gradient color
  ];

  Future<void> _storeFullNameInSharedPreferences(String fullName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   //checkLoginStatus();
  // }

  bool _isPasswordVisible = false;

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            _buildHeader(),
            SizedBox(height: 15),
            Container(
              child: Text(
                "Name *",
                style:
                    TextStyle(color: lightBlack, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 5),
            _buildTextField(
              controller: _firstNameController,
              hintText: 'Abc Singh',
              prefixIcon: Icons.person,
              iconColor: Colors.black54,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 5),
            Container(
              child: Text(
                "Email (Optional)",
                style:
                    TextStyle(color: lightBlack, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 5),
            _buildTextField(
              controller: _emailController,
              hintText: 'abc@gmail.com',
              prefixIcon: Icons.email,
              iconColor: Colors.black54,
              backgroundColor: Colors.white, // Set background color here
              isValid: _isValidEmail(),
            ),

            SizedBox(height: 2),
            Container(
              child: Text(
                "Mobile Number *",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey), // Example border style
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: Text(
                      '+$_storedCountryCode $_storedMobileNo',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Divider(height: 1, color: Colors.white), // Example divider
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       vertical: 10.0, horizontal: 10.0),
                  // ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    child: Text(
                      "Password * (ex:-Abhi@123 )",
                      style: TextStyle(
                          color: lightBlack, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    child: _buildIcon(),
                  ),
                ],
              ),
            ),
            _buildPasswordField(),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Tooltip(
      message: 'Password Requirements',
      child: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Password Requirements'),
              content: Text(
                'Please enter a new password into the fields below:\n'
                '1) Your password must have at least 8 characters.\n'
                '2) Must contain at least one upper case letter, one lower case letter, one number, and one special character ( ex: %, @, #).\n'
                '3) Passwords cannot contain < or >.',
                style: TextStyle(
                  color: Colors.black, // Customize the color if needed
                  fontSize: 12, // Adjust the font size as needed
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        icon: Icon(
          Icons.info_outline,
          color: Colors.blue,
          size: 17,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Image.asset(
          'assets/images/add-user.png', // Replace with your icon asset path
          width: 45, // Adjust the width as needed
          height: 45, // Adjust the height as needed
        ),
        SizedBox(height: 5),
        Text(
          "Getting Started",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              fontFamily: "assets/fonts/regular.ttf"),
        ),
        SizedBox(height: 5),
        Text(
          'Create an account to continue!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLength,
    ValueChanged<String>? onChanged,
    bool? isValid,
    bool isRequired = true,
    IconData? prefixIcon,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    bool? _isTouched = false;

    final errorText =
        (isRequired && (_isTouched ?? false) && controller.text.isEmpty)
            ? 'This field is required'
            : null;

    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              TextStyle(fontWeight: FontWeight.w400, color: Colors.black54),
          errorText: errorText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: iconColor)
              : null, // Adding prefix icon
          suffixIcon: isValid == null
              ? null
              : isValid
                  ? Icon(
                      Icons.check,
                      color: Colors.purple,
                    )
                  : Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black, // Border color
              width: 1.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10.0), // Border radius
          ),
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        onSubmitted: (value) {
          // Update the touched state
          if (!_isTouched!) {
            _isTouched = true;
            // Trigger a rebuild
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    final password = _passwordController.text;
    String? errorText;

    if (password.isNotEmpty) {
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[%@$#])[a-zA-Z0-9%@$#]{8,}$',
      );

      if (!passwordRegex.hasMatch(password)) {
        errorText = '';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 53,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Abhi@123',
              hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              prefixIcon: Icon(Icons.lock,
                  color: Colors.black54), // Add prefix icon here
              // Display the error message
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),

              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(10.0), // Border radius
              ),
            ),
            obscureText: !_isPasswordVisible,
          ),
        ),
        SizedBox(height: 10), // Add space here
        Visibility(
          visible: errorText != null,
          child: Text(
            errorText.toString(),
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),

        SizedBox(height: 10), // Add space here
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Check if the password is valid
          if (!_isValidPassword()) {
            // Show error message or toast indicating invalid password
            _showToast('Check Password Requirements');
            return;
          }

          // Set loading to true to show the loading indicator
          setState(() {
            _isLoading = true;
          });

          // Proceed with creating the account
          postData().then((_) {
            // After completing the task, set loading back to false
            setState(() {
              _isLoading = false;
            });
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : const Text(
                'Create Account',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
      ),
    );
  }

  bool? _isValidEmail() {
    final email = _emailController.text;
    if (email.isEmpty) {
      return null; // Email is optional
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword() {
    final password = _passwordController.text;

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[%@#$])[a-zA-Z0-9%@#$]{8,}$',
    );

    return passwordRegex.hasMatch(password);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: lightBlue,
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRegistrationForm(),
                  SizedBox(height: 7),
                  // _buildSignInLink(),
                  SizedBox(height: 10), // Add space here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildSignInLink() {
  //   return Center(
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           child: GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => LoginPage()),
  //               );
  //             },
  //             child: Padding(
  //               padding: EdgeInsets.only(left: 16.0),
  //               child: Text(
  //                 'Already have an account?',
  //                 style: TextStyle(
  //                   color: Colors.black45,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         // Container(
  //         //   child: GestureDetector(
  //         //     onTap: () {
  //         //       Navigator.push(
  //         //         context,
  //         //         MaterialPageRoute(builder: (context) => LoginPage()),
  //         //       );
  //         //     },
  //         //     child: Padding(
  //         //       padding: EdgeInsets.only(right: 16.0),
  //         //       child: Text(
  //         //         ' Sign In ',
  //         //         textAlign: TextAlign.right,
  //         //         style: TextStyle(
  //         //           color: bgColor,
  //         //           fontWeight: FontWeight.bold,
  //         //         ),
  //         //       ),
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength:
          Toast.LENGTH_SHORT, // Duration for which the toast is visible
      gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
      timeInSecForIosWeb: 1, // Duration for iOS (ignored on Android)
      backgroundColor: Colors.blueGrey, // Background color of the toast
      textColor: Colors.white, // Text color of the message
      fontSize: 16.0, // Font size of the message
    );
  }

  void _saveDataToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_no', _storedMobileNo);
    await prefs.setString('country_code', _storedCountryCode);
  }

  Future<void> _storeUserDetailsInSharedPreferences(
      Map<String, dynamic> responseJson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', responseJson['details']['_id']);
    print('User ID stored: ${responseJson['details']['_id']}');
    prefs.setString('full_name', responseJson['details']['full_name']);
    print('Full Name stored: ${responseJson['details']['full_name']}');
    prefs.setString('email', responseJson['details']['email_id']);
    print('Email stored: ${responseJson['details']['email_id']}');
    prefs.setString('mobile_no', responseJson['details']['mobile_no']);
    print('Mobile Number stored: ${responseJson['details']['mobile_no']}');
    prefs.setString('user_type', responseJson['details']['user_type']);
    print('user_type stored: ${responseJson['details']['user_type']}');
  }
}

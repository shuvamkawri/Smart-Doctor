import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import '../authentication/login_page.dart';

class PasswordChangeForm extends StatefulWidget {
  final String mobile;

  PasswordChangeForm({required this.mobile});

  @override
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reEnterNewPasswordController = TextEditingController();

  bool _isUpdatingPassword = false;
  bool _newPasswordObscureText = true;
  bool _confirmPasswordObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue, // Set background color of Scaffold to blue
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Image.asset(
                              'assets/images/reset_password_img.png'),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Enter a new Password',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: Text(
                          "New Password (ex:-Abhi@123)",
                          style: TextStyle(
                              color: lightBlack, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white, // Set background color to white
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextFormField(
                          controller: newPasswordController,
                          obscureText: _newPasswordObscureText,
                          decoration: InputDecoration(
                            hintText: '********',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black54,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _newPasswordObscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _newPasswordObscureText =
                                  !_newPasswordObscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black, // Border color
                                width: 1.0, // Border width
                              ),
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                          "Confirm Password",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white, // Set background color to white
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextFormField(
                          controller: reEnterNewPasswordController,
                          obscureText: _confirmPasswordObscureText,
                          decoration: InputDecoration(
                            hintText: '********',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54),
                            prefixIcon: Icon(
                              Icons.lock_reset,
                              color: Colors.black54,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordObscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordObscureText =
                                  !_confirmPasswordObscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black, // Border color
                                width: 1.0, // Border width
                              ),
                              borderRadius:
                              BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Tooltip(
                            message: 'Password Requirements', // Tooltip message
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.info_outline),
                                  color: Colors.blue, // Info icon
                                  onPressed: () {
                                    // Show dialog or any other action when icon is pressed
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Password Requirements'),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            'Please enter a new password into the fields below:\n'
                                                '1) Your password must have at least 8 characters.\n'
                                                '2) Must contain at least one upper case letter, one lower case letter, one number, and one special character (ex: %, @, #).\n'
                                                '3) Passwords cannot contain < or >.',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  'Password Info', // Text for the icon
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                          _updatePassword, // Call the function when button is pressed
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(bgColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updatePassword() async {
    String newPassword = newPasswordController.text;

    if (!_isValidPasswordChange()) {
      _showPasswordRequirementsPopup(context);
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    final headers = {'Content-Type': 'application/json'};
    final requestBody = {
      'mobileOrEmail': widget.mobile,
      'update_password': newPassword,
    };
    print('requestBody$requestBody');

    try {
      final response = await post('user/user-forgot-password', headers: headers, body: jsonEncode(requestBody));

      final responseBody = json.decode(response);
      if (responseBody.containsKey('errorCode') &&
          responseBody['errorCode'] == 200) {
        print('Password updated successfully');
        _showSuccessDialog(responseBody['message']);
      } else {
        print('Password update failed: ${responseBody['message']}');
      }
    } catch (e) {
      print('Error updating password: $e');
    }

    setState(() {
      _isUpdatingPassword = false;
    });
  }

  bool _isValidPasswordChange() {
    String newPassword = newPasswordController.text;
    String reEnterNewPassword = reEnterNewPasswordController.text;

    if (newPassword.isEmpty || reEnterNewPassword.isEmpty) {
      print('Please fill all the fields');
      return false;
    }

    if (newPassword != reEnterNewPassword) {
      print('New Passwords do not match');
      return false;
    }

    if (!_isStrongPassword(newPassword)) {
      print('Password does not meet the requirements');
      return false;
    }

    return true;
  }

  bool _isStrongPassword(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    return passwordRegExp.hasMatch(password) &&
        !_containsInvalidCharacters(password);
  }

  bool _containsInvalidCharacters(String password) {
    final RegExp invalidCharactersRegExp = RegExp(r'[<>]');

    return invalidCharactersRegExp.hasMatch(password);
  }

  void _showPasswordRequirementsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password Requirements'),
          content: Text(
            'Please make sure your password meets the following requirements:\n'
                '1) Your password must have at least 8 characters.\n'
                '2) Must contain at least one upper case letter, one lower case letter, one number, and one special character (ex: %, @, #).\n'
                '3) Passwords cannot contain < or >.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your password has been reset'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(planName: '',),
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
}

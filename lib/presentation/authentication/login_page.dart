import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/doctor_dashboard/subscription/subscribe.dart';
import '../forgot/forgot.dart';
import 'registration.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final String? planName; // Nullable in case no plan name is passed

  LoginPage({required this.planName});


  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool otpSent = false;
  bool _showOTPField = false;
  var _otpVerified;
  bool _isPasswordVisible = false;
  bool _isGenerateButtonDisabled = false;
  int _timer = 60;

  String verificationMessage = '';

  String loggedInEmail = '';

  String loggedInUserId = '';
  bool displayOTPController = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool rememberMe = false;
  bool forOTP = false;
  bool forPassword = false;
  String _callingCode = ''; // To store the detected calling code
  String? rememberMeStatus;
  String? profile_status;
  String? userType;

  Future<TextEditingController> getMobileRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _mobileController.text = prefs.getString("mobile_number_remember")!;
    print("Mobile number taken: " + _mobileController.text);
    return _mobileController;
  }

  Future<TextEditingController> getPasswordRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _passwordController.text = prefs.getString("password_remember")!;

    print("Password taken: " + _passwordController.text!);
    return _passwordController;
  }

  void _startTimer() {
    setState(() {
      _isGenerateButtonDisabled = true;
      _timer = 60;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer == 0) {
        setState(() {
          _isGenerateButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _timer--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCallingCode();
    getMobileRememberMe();
    getPasswordRememberMe();
    // forOTP ;
    // forPassword ;
  }

  Future<void> _fetchCallingCode() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipregistry.co/?key=a4m6fjgj8cssxtqz'),
      );
      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        setState(() {
          _callingCode = parsedResponse['location']['country']['calling_code'];
        });
        await _saveCallingCode(_callingCode);
      } else {
        print('Failed to fetch calling code: ${response.statusCode}');
        // Handle error if needed
      }
    } catch (e) {
      print('Error fetching calling code: $e');
      // Handle error if needed
    }
  }

  Future<void> _saveCallingCode(String callingCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calling_code', callingCode);
  }

  Future<void> _loadCallingCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callingCode = prefs.getString('calling_code')!;

      print('Calling code: $_callingCode');
    });
  }

  // Future<void> _performSignIn() async {
  //   String endpoint = 'user/login';
  //
  //   Map<String, String> headers = {
  //     'accept': '*/*',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final requestData = {
  //     "mobileOrEmail": _mobileController.text,
  //     "otp": "",
  //     "password": _passwordController.text,
  //     "remember_me": rememberMe,
  //   };
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('Password', _passwordController.text);
  //
  //   String body = jsonEncode(requestData);
  //
  //   try {
  //     var response = await post(endpoint, headers: headers, body: body); // API call
  //     Map<String, dynamic> responseJson = jsonDecode(response); // Parse response
  //
  //     print('Response body: $response');
  //
  //     String errorMessage = responseJson['message'] ?? 'An unknown error occurred';
  //
  //     if (responseJson['errorCode'] != 200) {
  //       _showErrorDialog(errorMessage);
  //       return;
  //     }
  //
  //     // Success
  //     String message = responseJson['message'] ?? 'You have successfully logged in';
  //
  //     // Store user details
  //     Map<String, dynamic> userDetails = responseJson['details'];
  //     await _storeUserDetailsInSharedPreferences(userDetails);
  //
  //     // Store id in shared preferences
  //     String id = userDetails['id'];
  //     await _storeIdInSharedPreferences(id);
  //
  //     // Retrieve user information
  //     String? city = userDetails['city_name'];
  //     String? state = userDetails['state_name'];
  //     String? country = userDetails['country_name'];
  //     String mobile_no = userDetails['mobile_no'];
  //
  //     setState(() {
  //       rememberMeStatus = userDetails['remember_me_status'].toString();
  //       profile_status = userDetails['profile_status'].toString();
  //       userType = userDetails['user_type'];
  //     });
  //
  //     // Save city, state, and country in SharedPreferences
  //     if (city != null && state != null && country != null) {
  //       await prefs.setString('cityName', city);
  //       await prefs.setString('selectedState', state);
  //       await prefs.setString('selectedCountry', country);
  //     }
  //
  //     await prefs.setString('mobile_no', mobile_no);
  //     await prefs.setString('rememberMeStatus', rememberMeStatus!);
  //
  //     // Navigate only to the DashboardScreen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => DashboardScreen(),
  //       ),
  //     );
  //
  //     // Set login status to true
  //     await _setLoggedInStatus(true);
  //
  //   } catch (e) {
  //     // Handle errors
  //     print('Error: $e');
  //     _showErrorDialog("An error occurred: $e");
  //   }
  // }


  Future<void> _performSignIn() async {
    String endpoint = 'user/login';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {
      "mobileOrEmail": _mobileController.text,
      "otp": "",
      "password": _passwordController.text,
      "remember_me": rememberMe,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Password', _passwordController.text);

    String body = jsonEncode(requestData);

    try {
      var response = await post(endpoint, headers: headers, body: body); // API call
      Map<String, dynamic> responseJson = jsonDecode(response); // Parse response

      print('Response body: $response');

      String errorMessage = responseJson['message'] ?? 'An unknown error occurred';

      if (responseJson['errorCode'] != 200) {
        _showErrorDialog(errorMessage);
        return;
      }

      // Success
      String message = responseJson['message'] ?? 'You have successfully logged in';

      // Store user details
      Map<String, dynamic> userDetails = responseJson['details'];
      await _storeUserDetailsInSharedPreferences(userDetails);

      // Store id in shared preferences
      String id = userDetails['id'];
      await _storeIdInSharedPreferences(id);

      // Retrieve user information
      String? city = userDetails['city_name'];
      String? state = userDetails['state_name'];
      String? country = userDetails['country_name'];
      String mobile_no = userDetails['mobile_no'];
      String? planName = userDetails['subscribe_type']; // Retrieve plan name

      setState(() {
        rememberMeStatus = userDetails['remember_me_status'].toString();
        profile_status = userDetails['profile_status'].toString();
        userType = userDetails['user_type'];
      });

      // Save city, state, and country in SharedPreferences
      if (city != null && state != null && country != null) {
        await prefs.setString('cityName', city);
        await prefs.setString('selectedState', state);
        await prefs.setString('selectedCountry', country);
      }

      await prefs.setString('mobile_no', mobile_no);
      await prefs.setString('rememberMeStatus', rememberMeStatus!);

      // Save plan name in SharedPreferences
      if (planName != null) {
        await prefs.setString('plan_name', planName);
      }

      // Navigate only to the DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ),
      );

      // Set login status to true
      await _setLoggedInStatus(true);

    } catch (e) {
      // Handle errors
      print('Error: $e');
      _showErrorDialog("An error occurred: $e");
    }
  }




  // Future<void> _performSignIn() async {
  //   String endpoint = 'user/login';
  //
  //   Map<String, String> headers = {
  //     'accept': '*/*',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final requestData = {
  //     "mobileOrEmail": _mobileController.text,
  //     "otp": "",
  //     "password": _passwordController.text,
  //     "remember_me": rememberMe,
  //   };
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('Password', _passwordController.text);
  //
  //   String body = jsonEncode(requestData);
  //
  //   try {
  //     var response = await post(endpoint, headers: headers, body: body); // Call your post function
  //     Map<String, dynamic> responseJson = jsonDecode(response); // Decode response body
  //     // Print the decoded JSON for debugging
  //     print('Decoded JSON: $responseJson');
  //
  //
  //     String errorMessage = responseJson['message'] ?? 'An unknown error occurred';
  //
  //     if (responseJson['errorCode'] != 200) {
  //       _showErrorDialog(errorMessage);
  //       return;
  //     }
  //
  //     // Success
  //     String message = responseJson['message'] ?? 'You have successfully logged in';
  //
  //     // Store user details
  //     Map<String, dynamic> userDetails = responseJson['details'];
  //     await _storeUserDetailsInSharedPreferences(userDetails);
  //
  //     // Store user ID in shared preferences
  //     String id = userDetails['id'];
  //     await _storeIdInSharedPreferences(id);
  //
  //     // Get location details if available
  //     String? city = userDetails['city_name'];
  //     String? state = userDetails['state_name'];
  //     String? country = userDetails['country_name'];
  //     String mobile_no = userDetails['mobile_no'];
  //
  //     // Get subscription type
  //     String? subscribeType = userDetails['subscribe_type'];
  //
  //     // Update state variables
  //     setState(() {
  //       rememberMeStatus = userDetails['remember_me_status'].toString();
  //       profile_status = userDetails['profile_status'].toString();
  //       userType = userDetails['user_type'];
  //     });
  //
  //     // Save location details in SharedPreferences
  //     if (city != null && state != null && country != null) {
  //       await prefs.setString('cityName', city);
  //       await prefs.setString('selectedState', state);
  //       await prefs.setString('selectedCountry', country);
  //       print('Location details saved in SharedPreferences');
  //     }
  //
  //     // Save subscription type
  //     if (subscribeType != null) {
  //       await prefs.setString('subscribeType', subscribeType);
  //       print('subscribeType saved in SharedPreferences: $subscribeType'); // Debugging
  //     }
  //
  //     // Navigate to HomePage
  //     if (userType == "Doctor") {
  //       if (userDetails['payment_status'] == true) {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => DashboardScreen(),
  //           ),
  //         );
  //         // Set login status to true
  //         await _setLoggedInStatus(true);
  //       } else {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => SubscriptionPage(),
  //           ),
  //         );
  //       }
  //     }
  //
  //     // Save mobile number and rememberMe status
  //     await prefs.setString('mobile_no', mobile_no);
  //     await prefs.setString('rememberMeStatus', rememberMeStatus!);
  //
  //   } catch (e) {
  //     // Handle errors
  //     print('Error: $e');
  //     _showErrorDialog("An error occurred: $e");
  //   }
  // }


  // Future<void> _performSignIn() async {
  //   String endpoint = 'user/login';
  //
  //   Map<String, String> headers = {
  //     'accept': '*/*',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final requestData = {
  //     "mobileOrEmail": _mobileController.text,
  //     "otp": "",
  //     "password": _passwordController.text,
  //     "remember_me": rememberMe,
  //   };
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('Password', _passwordController.text);
  //
  //   String body = jsonEncode(requestData);
  //
  //   try {
  //         var response = await post(endpoint,
  //             headers: headers, body: body); // Call your post function
  //         Map<String, dynamic> responseJson =
  //             jsonDecode(response); // Correctly decode the response body
  //         print('Response body: ${response}');
  //
  //         String errorMessage =
  //             responseJson['message'] ?? 'An unknown error occurred';
  //
  //         if (responseJson['errorCode'] != 200) {
  //           _showErrorDialog(errorMessage);
  //           return;
  //         }
  //
  //
  //     // Success
  //     String message = responseJson['message'] ?? 'You have successfully logged in';
  //
  //     // Store user details
  //     Map<String, dynamic> userDetails = responseJson['details'];
  //     await _storeUserDetailsInSharedPreferences(userDetails);
  //
  //     // Store id in shared preferences
  //     String id = userDetails['id'];
  //     await _storeIdInSharedPreferences(id);
  //
  //     // Get location details if available
  //     String? city = userDetails['city_name'];
  //     String? state = userDetails['state_name'];
  //     String? country = userDetails['country_name'];
  //     String mobile_no = userDetails['mobile_no'];
  //
  //     // Update state variables
  //     setState(() {
  //       rememberMeStatus = userDetails['remember_me_status'].toString();
  //       profile_status = userDetails['profile_status'].toString();
  //       userType = userDetails['user_type'];
  //     });
  //
  //     // Save location details in SharedPreferences
  //     if (city != null && state != null && country != null) {
  //       await prefs.setString('cityName', city);
  //       await prefs.setString('selectedState', state);
  //       await prefs.setString('selectedCountry', country);
  //     }
  //         // Navigate to HomePage
  //         //       if (userType == "Doctor") {
  //         //
  //         //         if(payment_status == "successful"){
  //         //           Navigator.pushReplacement(
  //         //             context,
  //         //             MaterialPageRoute(
  //         //               builder: (context) => DashboardScreen(),
  //         //             ),
  //         //           );
  //         //           // Set login status true
  //         //           await _setLoggedInStatus(true);
  //         //         }
  //         //         else{
  //         //           Navigator.pushReplacement(
  //         //             context,
  //         //             MaterialPageRoute(
  //         //               builder: (context) => DoctorInfoProfilePage(),
  //         //             ),
  //         //           );
  //         //         }
  //
  //     // Navigate to DashboardScreen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => DashboardScreen(),
  //       ),
  //     );
  //
  //     // Set login status true
  //     await _setLoggedInStatus(true);
  //
  //     // Save mobile number and rememberMe status
  //     await prefs.setString('mobile_no', mobile_no);
  //     await prefs.setString('rememberMeStatus', rememberMeStatus!);
  //
  //   } catch (e) {
  //     // Handle errors
  //     print('Error: $e');
  //     _showErrorDialog("An error occurred: $e");
  //   }
  // }


  // Future<void> _performSignIn() async {
  //   String endpoint = 'user/login';
  //
  //   Map<String, String> headers = {
  //     'accept': '*/*',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final requestData = {
  //     "mobileOrEmail": _mobileController.text,
  //     "otp": "",
  //     "password": _passwordController.text,
  //     "remember_me": rememberMe,
  //   };
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('Password', _passwordController.text);
  //
  //   String body = jsonEncode(requestData);
  //
  //   try {
  //     var response = await post(endpoint,
  //         headers: headers, body: body); // Call your post function
  //     Map<String, dynamic> responseJson =
  //         jsonDecode(response); // Correctly decode the response body
  //     print('Response body: ${response}');
  //
  //     String errorMessage =
  //         responseJson['message'] ?? 'An unknown error occurred';
  //
  //     if (responseJson['errorCode'] != 200) {
  //       _showErrorDialog(errorMessage);
  //       return;
  //     }
  //
  //     // Success
  //     String message =
  //         responseJson['message'] ?? 'You have successfully logged in';
  //
  //     // Store user details
  //     Map<String, dynamic> userDetails = responseJson['details'];
  //     await _storeUserDetailsInSharedPreferences(userDetails);
  //
  //     // Store id in shared preferences
  //     String id = userDetails['id'];
  //     await _storeIdInSharedPreferences(id);
  //
  //     // Save the city name in SharedPreferences if it exists
  //
  //     // if (userDetails.containsKey('city_name') && userDetails['city_name'].isNotEmpty) {// }
  //
  //     String? city = userDetails['city_name'];
  //     String? state = userDetails['state_name'];
  //     String? country = userDetails['country_name'];
  //     String mobile_no = userDetails['mobile_no'];
  //     setState(() {
  //       rememberMeStatus = userDetails['remember_me_status'].toString();
  //       profile_status= userDetails['profile_status'].toString();
  //       userType = userDetails['user_type'];
  //     });
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     if (city != null && state != null && country != null) {
  //       await prefs.setString('cityName', city);
  //       await prefs.setString('selectedState', state);
  //       await prefs.setString('selectedCountry', country);
  //
  //       // Navigate to HomePage
  //       if (userType == "Doctor") {
  //
  //         if(profile_status == "true"){
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => DashboardScreen(),
  //             ),
  //           );
  //           // Set login status true
  //           await _setLoggedInStatus(true);
  //         }
  //         else{
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => DoctorInfoProfilePage(),
  //             ),
  //           );
  //         }
  //
  //       } else {
  //         Fluttertoast.showToast(
  //           msg: "This number is not registered for doctor",
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0,
  //         );
  //       }
  //     }
  //
  //
  //     await prefs.setString('mobile_no', mobile_no);
  //     await prefs.setString('rememberMeStatus', rememberMeStatus!);
  //
  //     // // Set login status to true
  //     // await _setLoggedInStatus(true);
  //
  //   } catch (e) {
  //     // Handle errors
  //     print('Error: $e');
  //     _showErrorDialog("An error occurred: $e");
  //   }
  // }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 238, 70, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 28.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
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
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: AnimatedContainer(
            duration: Duration(seconds: 1), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _animatedColors, // Colors controlled by animation
              ),
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
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationPage(),
                      ),
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
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

  void _showDialog(String message) {
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
            duration: Duration(seconds: 1), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _animatedColors, // Colors controlled by animation
              ),
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
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HomePage(),
                    //   ),
                    // );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
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

  Future<void> _storeIdInSharedPreferences(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', id);
    print('Stored user ID: $id');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SignInPage()),
                // );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 0.0),
                child: Text(
                  'Sign up',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOTP() async {
    // Make the API call
    final response = await post(
      'user/otp-generate-by-mobile',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "country_code": _callingCode,
        "mobile_no": _mobileController.value.text
      }),
    );

    // Print the response body
    print('Response Body: $response');

    // Parse the response
    final Map<String, dynamic> responseData = json.decode(response);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_no', _mobileController.text);
    await prefs.setString('country_code', _callingCode);

    if (responseData['errorCod'] == 201) {
      _showToast(responseData['message']);
      _otpVerified = responseData['otp_verification_status'];
      if (_otpVerified == true) {
        forPassword = true;
        forOTP = false;
        otpSent = true;
      } else {
        forOTP = true;
        forPassword = false;
        otpSent = true;
      }
      print(_otpVerified);
      setState(() {});
    } else if (responseData['errorCod'] == 200) {
      _showToast(responseData['message']);
      _otpVerified = responseData['otp_verification_status'];
      if (_otpVerified == true) {
        forPassword = true;
        forOTP = false;
        otpSent = true;
      } else {
        forOTP = true;
        forPassword = false;
        otpSent = true;
      }
      print(_otpVerified);
      setState(() {});
    } else {
      _showToast(responseData['message']);
    }
  }

  Future<void> verifyOTP() async {
    final Map<String, String> requestBody = {
      "mobile_no": _mobileController.text,
      "otp": _otpController.text
    };

    print('otprequest body $requestBody');

    try {
      final response = await post(
        'user/verify-otp-by-mobile',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      final responseData =
          json.decode(response); // Use response.body to access JSON data

      if (responseData['success'] == true) {
        setState(() {
          verificationMessage = "OTP verified successfully.";
        });

        String userType = responseData['user_type'];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrationPage()),
        );
      } else {
        setState(() {
          verificationMessage =
              responseData['message'] ?? "Failed to verify OTP.";
        });
        _showToast(verificationMessage);
      }
    } catch (e) {
      setState(() {
        verificationMessage = "An error occurred: $e";
      });
      _showToast(verificationMessage);
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the app when back button is pressed
        SystemNavigator.pop();
        return true; // Return true to allow back button press
      },
      child: Scaffold(
        backgroundColor: Colors.lightBlue.shade50,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image.asset('assets/images/login_img.png'),
                ),
                SizedBox(height: 15),
                Text(
                  "Let's Sign in, Doctor",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome Back, You've",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                Text(
                  "been missed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Plan: ${widget.planName ?? 'No Plan Selected'}", // Use widget.planName
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Phone",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 5),
                    Container(
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
                          prefixText:
                              '+$_callingCode', // Display the detected calling code
                          prefixIcon: Icon(Icons.call, color: Colors.black54),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType:
                            TextInputType.phone, // Use phone keyboard type
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(
                              10), // Limit length to 10 digits
                        ],
                        onChanged: (value) {
                          if (value.length > 10) {
                            _mobileController.text = value.substring(0, 10);
                            _mobileController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _mobileController.text.length),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),

                    if (!otpSent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isGenerateButtonDisabled
                                ? null
                                : () async {
                                    // Check if mobile number is empty
                                    if ((_mobileController.text == null ||
                                        _mobileController.text.isEmpty)) {
                                      _showToast('Mobile number is required.');
                                      return;
                                    }

                                    if (_mobileController.text.length != 10) {
                                      _showToast(
                                          'Invalid phone number. Please enter a 10-digit number.');
                                      return;
                                    }

                                    setState(() {
                                      _isGenerateButtonDisabled = true;
                                      otpSent = true;
                                      _startTimer();
                                      _showOTPField = true;
                                    });

                                    try {
                                      await _sendOTP(); // Call the function to send OTP
                                    } catch (e) {
                                      // Handle any errors that might occur during API call
                                      print('Error sending OTP: $e');

                                      // Reset UI state on error
                                      setState(() {
                                        _isGenerateButtonDisabled = false;
                                        otpSent = false;
                                        _showOTPField = true;
                                      });

                                      // Optionally show an error message
                                      Fluttertoast.showToast(
                                        msg:
                                            'Failed to send OTP. Please try again.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.blueGrey,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),

                    // for otp
                    if (forOTP)
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Enter OTP",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter OTP',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    prefixIcon:
                                        Icon(Icons.lock, color: Colors.black54),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 16.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // if (!_isPasswordVisible)
                              // if (otpSent && !_otpVerified)
                              Text(
                                _isGenerateButtonDisabled
                                    ? '$_timer seconds'
                                    : '',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              // if (otpSent==false || !_otpVerified==true )
                              ElevatedButton(
                                onPressed: _isGenerateButtonDisabled
                                    ? null
                                    : () async {
                                        // Check if mobile number is empty
                                        if ((_mobileController.text == null ||
                                            _mobileController.text.isEmpty)) {
                                          _showToast(
                                              'Mobile number is required.');
                                          return;
                                        }
                                        setState(() {
                                          _isGenerateButtonDisabled = true;
                                          otpSent = true;
                                          _startTimer();
                                          _showOTPField = true;
                                        });

                                        try {
                                          await _sendOTP(); // Call the function to send OTP
                                        } catch (e) {
                                          // Handle any errors that might occur during API call
                                          print('Error sending OTP: $e');

                                          // Reset UI state on error
                                          setState(() {
                                            _isGenerateButtonDisabled = false;
                                            otpSent = false;
                                            _showOTPField = true;
                                          });

                                          // Optionally show an error message
                                          Fluttertoast.showToast(
                                            msg:
                                                'Failed to send OTP. Please try again.',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.blueGrey,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // if (_mobileController.text.isEmpty) {
                                //   _showToast(
                                //       'Please enter mobile number and OTP to proceed');
                                //   return;
                                // }
                                // if (_otpController.text.isEmpty) {
                                //   _showToast('Please enter OTP to proceed');
                                //   return;
                                // }
                                await verifyOTP();
                                setState(() {
                                  _isLoading = false;
                                });
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
                                      'VERIFY OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                    // for password
                    if (forPassword)
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Password",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  keyboardType: TextInputType.text,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Enter password',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    prefixIcon:
                                        Icon(Icons.lock, color: Colors.black54),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 16.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),
                          // if (_otpVerified)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    rememberMe = newValue ?? false;
                                  });
                                },
                              ),
                              Text('Remember me'),
                            ],
                          ),
                          SizedBox(height: 10),

                          // if (otpSent == true )
                          Container(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // if (_mobileController.text.isEmpty) {
                                //   _showToast(
                                //       'Please enter mobile number and OTP to proceed');
                                //   return;
                                // }
                                // if (_otpController.text.isEmpty) {
                                //   _showToast('Please enter OTP to proceed');
                                //   return;
                                // }

                                await _performSignIn();

                                setState(() {
                                  _isLoading = false;
                                });
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
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 20),
                          // if (_otpVerified)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage()),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       "Don't have an account?",
                              //       style: TextStyle(
                              //         color: Colors.black54,
                              //         fontWeight: FontWeight.w500,
                              //         fontSize: 12,
                              //       ),
                              //     ),
                              //     SizedBox(width: 5),
                              //     GestureDetector(
                              //       onTap: () {
                              //         // Handle sign up link tap
                              //       },
                              //       child: Text(
                              //         'Sign up',
                              //         style: TextStyle(
                              //           color: Colors.blueAccent,
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 12,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleLoginResponse(Map<String, dynamic> response) {
    // Check if the response indicates an error due to the use of OTP
    if (response['errorCod'] == 201) {
      setState(() {
        displayOTPController =
            false; // Hide OTP controller and display password field
      });
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ),
      );
    }
  }

  Future<void> _setLoggedInStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _storeUserDetailsInSharedPreferences(Map<String, dynamic> userDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userDetails['id']);
    print('User ID stored: ${userDetails['id']}');
    prefs.setString('full_name', userDetails['full_name']);
    print('Full Name stored: ${userDetails['full_name']}');
    prefs.setString('email', userDetails['email_id']);
    print('Email stored: ${userDetails['email_id']}');
    prefs.setString('mobile_no', userDetails['mobile_no']);
    print('Mobile Number stored: ${userDetails['mobile_no']}');
    prefs.setString('user_type', userDetails['user_type']);
    print('user_type stored: ${userDetails['user_type']}');

    // prefs.setString('cityName', userDetails['city_name']);
    // print('selectedCity: ${userDetails['city_name']}');
  }

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

}


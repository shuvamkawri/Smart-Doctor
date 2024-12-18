// import 'dart:convert';
//
// import 'package:ai_medi_doctor/presentation/dashboard/dashboard_screen.dart';
// import 'package:flutter/material.dart';
//
// import '../../consts/colors.dart';
// import '../../domain/common_fuction_api.dart';
// import '../dashboard/doctor_dashboard/doctor_home_page/doctor_home_page.dart';
//
// class OTPVerification extends StatefulWidget {
//   final String mobile;
//
//   OTPVerification({required this.mobile});
//
//   @override
//   _OTPVerificationState createState() => _OTPVerificationState();
// }
//
// class _OTPVerificationState extends State<OTPVerification> {
//   List<TextEditingController> otpControllers =
//       List.generate(5, (_) => TextEditingController());
//
//   String verificationMessage = '';
//
//   Future<void> verifyOTP() async {
//     final Map<String, String> requestBody = {
//       "mobile_no":
//           widget.mobile, // Use the email passed from ForgotPasswordPage
//       "otp": otpControllers.map((controller) => controller.text).join(),
//     };
//     print('request body$requestBody');
//
//     try {
//       final response = await post('user/verify-otp-by-mobile',
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode(requestBody));
//
//       final responseData = json.decode(response);
//
//       if (responseData['success']) {
//         setState(() {
//           verificationMessage = "OTP verified successfully.";
//         });
//         // Navigate to PasswordChangeForm upon successful OTP verification
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DashboardScreen(),
//           ),
//         );
//       } else {
//         setState(() {
//           verificationMessage =
//               responseData['message'] ?? "Failed to verify OTP.";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         verificationMessage = "An error occurred: $e";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       backgroundColor: lightBlue,
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         child: SingleChildScrollView(
//           child: Container(
//             margin: EdgeInsets.only(left: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 60),
//                 Container(
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     child: Image.asset('assets/images/otp_verify_img.png'),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   'Verification Code',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   'Enter The Code We Send You?',
//                   style: TextStyle(fontSize: 14, color: Colors.black54),
//                 ),
//                 SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center, // Center the row horizontally
//                   children: [
//                     for (int i = 0; i < 4; i++)
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 4),
//                         width: 60,
//                         height: 60,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.rectangle,
//                           color: Colors.white,
//                           border: Border.all(color: Colors.black26),
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         child: TextField(
//                           maxLength: 1,
//                           controller: otpControllers[i],
//                           keyboardType: TextInputType.number,
//                           onChanged: (value) {
//                             if (value.isNotEmpty) {
//                               if (i < 3) {
//                                 FocusScope.of(context).nextFocus();
//                               } else {
//                                 FocusScope.of(context)
//                                     .unfocus(); // Dismiss keyboard after last digit
//                               }
//                             }
//                           },
//                           decoration: InputDecoration(
//                             counterText: '',
//                             border: InputBorder.none,
//                           ),
//                           style: TextStyle(fontSize: 20),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Didn't receive it? ",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black54,
//                       ),
//                     ),
//                     Text(
//                       "Resend Code",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 345),
//                 Container(
//                   width: double.infinity,
//                   height: 55,
//                   margin: EdgeInsets.only(right: 10),
//                   child: ElevatedButton(
//                     onPressed: verifyOTP, // Call the function on button press
//                     style: ButtonStyle(
//                       backgroundColor:
//                           MaterialStateProperty.all<Color>(bgColor),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       'Confirm',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 17),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// import 'package:permission_handler/permission_handler.dart';
//
//
// class CallPage extends StatefulWidget {
//   const CallPage({Key? key, required this.callID, required this.isGroupCall}) : super(key: key);
//   final String callID;
//   final bool isGroupCall;
//
//   @override
//   _CallPageState createState() => _CallPageState();
// }
//
// class _CallPageState extends State<CallPage> {
//   bool _permissionsGranted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAndRequestPermissions();
//   }
//
//   Future<void> _checkAndRequestPermissions() async {
//     var cameraStatus = await Permission.camera.status;
//     var microphoneStatus = await Permission.microphone.status;
//
//     if (cameraStatus.isGranted && microphoneStatus.isGranted) {
//       setState(() {
//         _permissionsGranted = true;
//       });
//     } else {
//       _showPermissionDialog();
//     }
//   }
//
//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent dismissal by tapping outside the dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Permissions Required'),
//           content: const Text(
//               'This app requires camera and microphone permissions to function properly. Please grant the permissions.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 Navigator.of(context).pop(); // Return to the previous screen
//               },
//               child: const Text('Deny'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 var cameraGranted = await Permission.camera.request().isGranted;
//                 var microphoneGranted = await Permission.microphone.request().isGranted;
//
//                 if (cameraGranted && microphoneGranted) {
//                   setState(() {
//                     _permissionsGranted = true;
//                   });
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Camera and microphone permissions are required')),
//                   );
//                   Navigator.of(context).pop(); // Return to the previous screen if permissions are not granted
//                 }
//               },
//               child: const Text('Allow'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_permissionsGranted) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Permission Required')),
//         body: const Center(
//           child: Text('Waiting for permissions to be granted...'),
//         ),
//       );
//     }
//
//     final userID = 'user_id_${DateTime.now().millisecondsSinceEpoch}';
//     final userName = 'user_name';
//
//     return ZegoUIKitPrebuiltCall(
//       appID: 1937626138, // Replace with your ZEGOCLOUD appID.
//       appSign: "d5d47be13995891e1ac6bc05eed646efc25091f4d25aab5f524adb38412dcf38", // Replace with your ZEGOCLOUD appSign.
//       userID: userID, // Generated unique user ID
//       userName: userName, // Assigned user name
//       callID: widget.callID, // Dynamic call ID
//       config: widget.isGroupCall
//           ? ZegoUIKitPrebuiltCallConfig.groupVideoCall() // Configuration for group call
//           : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(), // Configuration for one-on-one call
//     );
//   }
// }

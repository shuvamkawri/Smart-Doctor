import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../pharmacy_page/pharmacy_page.dart';
import 'generate_prescription.dart';


class DoctorPrescriptionPages extends StatefulWidget {
  final String pharmacyId;

  const DoctorPrescriptionPages({super.key, required this.pharmacyId});

  @override
  State<DoctorPrescriptionPages> createState() => _DoctorPrescriptionPagesState();
}

class _DoctorPrescriptionPagesState extends State<DoctorPrescriptionPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  List<Prescription> prescriptions = [];
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    patientAppointList();
    printPharmacyId();
  }

  void printPharmacyId() {
    print('Pharmacy ID: ${widget.pharmacyId}');
  }

  Future<void> patientAppointList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    print('Request Data:');
    print('URL: doctor/doctor-appointment-list/$userId');

    final response = await get("doctor/doctor-appointment-list/$userId");
    print('Body: $response');

    final data = json.decode(response);
    print('Response body: ${data}');

    if (data['errorCode'] == 200) {
      var responseData = data['details'];
      setState(() {
        prescriptions = responseData.map<Prescription>((patient) {
          return Prescription(
            id: patient['_id'] ?? '',
            patientName: patient['patient_name'] ?? '',
            patientAddress: patient['patient_address'] ?? '',
            date: patient['date'] ?? '', // Provide date if available
            user: patient['user'] ?? '',
            ageYear: patient['age_year'] ?? '',
            ageMonth: patient['age_month'] ?? '',
            weight: patient['weight'] ?? '',
            gender: patient['gender'] ?? '',
            patientNumber: patient['patient_number'] ?? '',
          );
        }).toList();
      });
    } else {
      throw Exception(
          'Failed to load patient information: ${data['errorMessage']}');
    }
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/${DateTime.now()
          .toIso8601String()}.png';
      await image.saveTo(path);
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  // Future<void> uploadImage(File imageFile, Prescription prescription) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String doctorId = prefs.getString('user_id') ?? '';
  //
  //   print("Starting uploadImage function");
  //
  //   String base64Image = base64Encode(imageFile.readAsBytesSync());
  //
  //
  //   try {
  //     var response = await post(
  //       'doctor/prescription-upload',
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'accept': '*/*',
  //       },
  //       body: jsonEncode({
  //         'patient_id': prescription.id,
  //         'doctor_id': doctorId,
  //         'pharmacy_id': widget.pharmacyId,
  //         'image': {
  //           'image': base64Image,
  //           'imgExt': 'jpg',
  //         },
  //       }),
  //     );
  //
  //     var jsonResponse = jsonDecode(response);
  //
  //     if (jsonResponse['errorCode'] == 200) {
  //       print("Image uploaded: $jsonResponse");
  //       setState(() {
  //         _imageFile = null; // Clear the image after uploading
  //       });
  //       // Show success dialog
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("Success"),
  //             content: Text("Image uploaded successfully!"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       print("Upload failed with error code: ${jsonResponse['errorCode']}");
  //     }
  //   } catch (e) {
  //     print("Error uploading image: $e");
  //   }
  // }


  Future<void> uploadImage(File imageFile, Prescription prescription) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String doctorId = prefs.getString('user_id') ?? '';
    String prescriptionId = prefs.getString('selected_prescription_id') ?? '';
    String userId = prefs.getString('selected_user_id') ?? '';

    // Check if pharmacy_id is available
    if (widget.pharmacyId.isEmpty) {
      // Show error alert if pharmacy_id is not present
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please upload prescription through pharmacy."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the error dialog
                  // Navigate to PharmacyProfile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PharmacyList()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function early
    }

    print("Starting uploadImage function");

    // Convert image to base64
    String base64Image = base64Encode(imageFile.readAsBytesSync());
    String imageExtension = 'jpg'; // Assuming jpg format

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'user':userId,
      'patient_id': prescriptionId,
      'doctor_id': doctorId,
      'pharmacy_id': widget.pharmacyId,
      'image': {
        'image': base64Image,
        'imgExt': imageExtension,
      },
    };

    // Print the request body
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      var response = await post(
        'doctor/prescription-upload',
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(requestBody),
      );

      // Print the response body
      print("Response Body: ${response}");

      var jsonResponse = jsonDecode(response);

      if (jsonResponse['errorCode'] == 200) {
        print("Image uploaded successfully: $jsonResponse");
        setState(() {
          _imageFile = null; // Clear the image after uploading
        });
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Image uploaded successfully!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print("Upload failed with error code: ${jsonResponse['errorCode']}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }


  Future<void> _captureAndUploadPrescription(Prescription prescription) async {
    await _takePicture();
    if (_imageFile != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Preview Prescription'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(_imageFile!),
                SizedBox(height: 10),
                Text('Do you want to upload this prescription?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await uploadImage(_imageFile!, prescription);
                },
                child: Text('Upload'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showPrescriptionOptions(Prescription prescription) async {
    // Save prescription ID in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isStored = await prefs.setString('selected_prescription_id', prescription.id);
    bool isStore = await prefs.setString('selected_user_id', prescription.user);

    if (isStored) {
      print('Prescription ID stored successfully: ${prescription.id}');
    } else {
      print('Failed to store prescription ID');
    }
    if (isStore) {
      print('Prescription ID stored successfully: ${prescription.user}');
    } else {
      print('Failed to store prescription ID');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Prescription'),
          content: Text('Would you like to upload a new prescription for ${prescription.patientName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _captureAndUploadPrescription(prescription);
              },
              child: Text('Capture and Upload'),
            ),
          ],
        );
      },
    );
  }


  void navigateToDetail(Prescription prescription) {
    // Uncomment and implement this to navigate to the prescription detail page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PrescriptionDetailPage(prescription: prescription),
    //   ),
    // );
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
            child: Padding(
              padding: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Prescriptions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.dehaze_outlined, color: Colors.blue),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription = prescriptions[index];
                  return Card(
                    child: ListTile(
                      title: Text(prescription.patientName),
                      subtitle: Text(prescription.date),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () => _showPrescriptionOptions(prescription),
                          ),
                          TextButton(
                            child: Text('Generate'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GeneratePrescriptionPage( patientName: prescription.patientName,patientAddress:
                                  prescription.patientAddress, pharmacyId: widget.pharmacyId,),


                                ),
                              );
                            },
                          ),

                        ],
                      ),
                      onTap: () => navigateToDetail(prescription),
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

class Prescription {
  final String id;
  final String patientName;
  final String patientAddress;
  final String date;
  final String user;
  final String ageYear;
  final String ageMonth;
  final String weight;
  final String gender;
  final String patientNumber;

  Prescription({
    required this.id,
    required this.patientName,
    required this.patientAddress,
    required this.date,
    required this.user,
    required this.ageYear,
    required this.ageMonth,
    required this.weight,
    required this.gender,
    required this.patientNumber,
  });
}


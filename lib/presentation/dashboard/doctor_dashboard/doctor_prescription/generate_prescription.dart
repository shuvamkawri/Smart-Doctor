import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../pharmacy_page/pharmacy_page.dart'; // Adjust the import path as necessary

class GeneratePrescriptionPage extends StatefulWidget {
  final String patientName, patientAddress, pharmacyId;

  GeneratePrescriptionPage({
    required this.patientName,
    required this.patientAddress,
    required this.pharmacyId,
  });

  @override
  _GeneratePrescriptionPageState createState() => _GeneratePrescriptionPageState();
}

class _GeneratePrescriptionPageState extends State<GeneratePrescriptionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _medicines = [];
  DateTime? _prescriptionDate;
  DateTime? _expiryDate;

  // Map _medicines to medicineArray for API call
  List<Map<String, dynamic>> get medicineArray {
    return _medicines.map((medicine) {
      return {
        'medicine_name': medicine['medicineName'],
        'dosage': medicine['dosage'],
        'instruction': medicine['instructions'],
      };
    }).toList();
  }

  Future<void> _pickPrescriptionDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _prescriptionDate) {
      setState(() {
        _prescriptionDate = pickedDate;
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      uploadPrescription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16),
                      _buildPatientDetails(),
                      SizedBox(height: 16),
                      _buildPrescriptionForm(),
                      SizedBox(height: 16),
                      _buildAddMedicineButton(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Submit Prescription',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildFooter(),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 110,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconWithShadow(
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              "Generate Prescription",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildIconWithShadow(
              icon: Icons.dehaze_outlined,
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithShadow({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blue),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPatientDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    "Patient Name:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.patientName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.patientAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._medicines.map((medicine) => _buildMedicineEntry(medicine)).toList(),
            SizedBox(height: 16),
            ListTile(
              title: Text("Prescription Date:"),
              subtitle: Text(
                _prescriptionDate != null
                    ? "${_prescriptionDate!.toLocal()}".split(' ')[0]
                    : "Select a date",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickPrescriptionDate,
            ),
            ListTile(
              title: Text("Expiry Date:"),
              subtitle: Text(
                _expiryDate != null
                    ? "${_expiryDate!.toLocal()}".split(' ')[0]
                    : "Select a date",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickExpiryDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineEntry(Map<String, dynamic> medicine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMedicineTextField(
                  initialValue: medicine['medicineName'],
                  hint: 'Medicine Name',
                  onChanged: (value) {
                    setState(() {
                      medicine['medicineName'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _medicines.remove(medicine);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildMedicineTextField(
            initialValue: medicine['dosage'],
            hint: 'Dosage',
            onChanged: (value) {
              setState(() {
                medicine['dosage'] = value;
              });
            },
          ),
          SizedBox(height: 8),
          _buildMedicineTextField(
            initialValue: medicine['instructions'],
            hint: 'Instructions',
            onChanged: (value) {
              setState(() {
                medicine['instructions'] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTextField({
    required String initialValue,
    required String hint,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hint';
        }
        return null;
      },
    );
  }

  Widget _buildAddMedicineButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _medicines.add({
            'medicineName': '',
            'dosage': '',
            'instructions': '',
          });
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Add Medicine',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        "Please review all the information before submitting.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
  // Updated API call method
  Future<void> uploadPrescription() async {
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


    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'user': userId,
      'patient_id': prescriptionId,
      'doctor_id': doctorId,
      'pharmacy_id': widget.pharmacyId,
      'prescription_date': _prescriptionDate?.toIso8601String() ?? '',
      'expiry_date': _expiryDate?.toIso8601String() ?? '',
      'medicineArray': medicineArray,

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

        });
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Prescription uploaded successfully!"),
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
}


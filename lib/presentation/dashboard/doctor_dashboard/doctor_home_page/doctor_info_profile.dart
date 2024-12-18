import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../../domain/common_fuction_api.dart';

class DoctorInfoProfile extends StatefulWidget {
  @override
  _DoctorInfoProfileState createState() => _DoctorInfoProfileState();
}

class _DoctorInfoProfileState extends State<DoctorInfoProfile> {
  int _currentStep = 0;
  double profileCompletion = 50.0; // 50% for each step

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedHospitalCategory;
  String? _selectedHospital;
  String? _doctorName;
  String? _qualification;
  String? _profile;
  String? _phoneNumber;
  String? _email;
  String? _ssnOrPan;
  String? _selectedSpecialist;

  List<dynamic> _hospitalCategories = [];
  List<dynamic> _hospitals = [];

  bool _isLoadingCategories = true;
  bool _isLoadingHospitals = false;
  List<dynamic> _specialists = [];


  bool _isLoadingSpecialists = true;

  // Fetch hospital categories
  Future<void> _fetchHospitalCategories() async {
    try {
      String response = await get('hospital-category-list');
      var jsonResponse = jsonDecode(response);
      if (jsonResponse['errorCode'] == 200) {
        setState(() {
          _hospitalCategories = jsonResponse['details'];
          _isLoadingCategories = false;
        });
      }
    } catch (error) {
      print("Error fetching categories: $error");
    }
  }

  // Fetch hospitals based on category
  Future<void> _fetchHospitals(String categoryId) async {
    try {
      setState(() {
        _isLoadingHospitals = true;
      });
      String response = await get('hospital-list/$categoryId');
      var jsonResponse = jsonDecode(response);
      if (jsonResponse['errorCode'] == 200) {
        setState(() {
          _hospitals = jsonResponse['details'];
          _isLoadingHospitals = false;
        });
      }
    } catch (error) {
      print("Error fetching hospitals: $error");
    }
  }

  // Fetch specialists
  Future<void> _fetchSpecialists() async {
    try {
      setState(() {
        _isLoadingSpecialists = true; // Start loading
      });

      String response = await get('treatment-category/list'); // Your API endpoint for specialists
      var jsonResponse = jsonDecode(response); // Decode the JSON response

      // Print the raw response for debugging
      print("API Response: $jsonResponse");

      // Check if the response contains the expected error code
      if (jsonResponse['results']['errorCode'] == 200) {
        setState(() {
          _specialists = jsonResponse['results']['result']; // Update specialists list
          _isLoadingSpecialists = false; // Stop loading
        });
      } else {
        // Handle any error codes other than 200
        print("Error: ${jsonResponse['results']['message']}");
        setState(() {
          _isLoadingSpecialists = false; // Stop loading even on error
        });
      }
    } catch (error) {
      print("Error fetching specialists: $error");
      setState(() {
        _isLoadingSpecialists = false; // Stop loading on error
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _fetchHospitalCategories(); // Fetch hospital categories when the widget is initialized
    _fetchSpecialists(); // Fetch specialists when the widget is initialized
  }

  // Function to calculate profile completion percentage
  void _calculateProfileCompletion() {
    int totalFields = 6;
    int completedFields = 0;

    if (_selectedHospital != null) completedFields++;
    if (_doctorName != null && _doctorName!.isNotEmpty) completedFields++;
    if (_qualification != null && _qualification!.isNotEmpty) completedFields++;
    if (_profile != null && _profile!.isNotEmpty) completedFields++;
    if (_phoneNumber != null && _phoneNumber!.isNotEmpty) completedFields++;
    if (_email != null && _email!.isNotEmpty) completedFields++;
    if (_ssnOrPan != null && _ssnOrPan!.isNotEmpty) completedFields++;

    setState(() {
      profileCompletion = (completedFields / totalFields) * 100;
    });
  }
  List<Step> getSteps() {
    return [
      // Step 1: Hospital Category and Hospital Selection
      Step(
        title: Text('Hospital/Clinic'),
        content: SingleChildScrollView( // This will make the content scrollable if it exceeds the available space
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add some padding to avoid content touching screen edges
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align the column items to the start
              children: [
                // Dropdown for Hospital Category
                _isLoadingCategories
                    ? CircularProgressIndicator() // Show loader while fetching categories
                    : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9, // Set a maximum width for the dropdown
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Hospital Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _hospitalCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['_id'],
                        child: Text(
                          category['name'],
                          overflow: TextOverflow.ellipsis, // Handle long text
                          maxLines: 1, // Limit to one line
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHospitalCategory = value;
                        _selectedHospital = null;
                        _hospitals = []; // Clear previous hospital list
                      });
                      if (value != null) {
                        _fetchHospitals(value); // Fetch hospitals for selected category
                      }
                    },
                    value: _selectedHospitalCategory,
                  ),
                ),
                SizedBox(height: 10),
                // Dropdown for Hospitals under selected category
                _isLoadingHospitals
                    ? CircularProgressIndicator() // Show loader while fetching hospitals
                    : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9, // Set a maximum width for the dropdown
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Hospital/Clinic',
                      border: OutlineInputBorder(),
                    ),
                    items: _hospitals.map((hospital) {
                      return DropdownMenuItem<String>(
                        value: hospital['_id'],
                        child: Text(
                          hospital['hospital_name'],
                          overflow: TextOverflow.ellipsis, // Handle long hospital names
                          maxLines: 1, // Limit to one line
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHospital = value;
                        _calculateProfileCompletion();
                      });
                    },
                    value: _selectedHospital,
                  ),
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 0,
      ),

      // Step 2: Basic Information
      Step(
        title: Text('Basic Info'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _doctorName = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Qualifications (e.g., MBBS, MD)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _qualification = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Short Profile/Bio',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _profile = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'SSN/PAN Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _ssnOrPan = value;
                    _calculateProfileCompletion();
                  });
                },
              ),
              SizedBox(height: 10),
              // Dropdown for Specialists
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9, // Set a maximum width for the dropdown
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Specialist',
                    border: OutlineInputBorder(),
                  ),
                  items: _specialists.isNotEmpty
                      ? _specialists.map((specialist) {
                    return DropdownMenuItem<String>(
                      value: specialist['_id'],
                      child: Text(
                        specialist['category'], // Adjust this key based on your API response
                        overflow: TextOverflow.ellipsis, // Handle long text
                        maxLines: 1, // Limit to one line
                      ),
                    );
                  }).toList()
                      : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('No specialists available'), // Placeholder text
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialist = value;
                      _calculateProfileCompletion(); // Recalculate profile completion
                    });
                  },
                  value: _selectedSpecialist,
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
      ),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Info Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _currentStep == 0 ? 0.5 : 1.0, // 50% for each step
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Profile Completion: ${_currentStep == 0 ? "50%" : "100%"}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                steps: getSteps(),
                onStepContinue: () {
                  if (_currentStep < getSteps().length - 1) {
                    setState(() {
                      _currentStep++;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep--;
                    });
                  }
                },
                controlsBuilder: (BuildContext context, ControlsDetails controls) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        ElevatedButton(
                          onPressed: controls.onStepCancel,
                          child: Text('Back'),
                        ),
                      ElevatedButton(
                        onPressed: controls.onStepContinue,
                        child: Text(_currentStep == getSteps().length - 1 ? 'Finish' : 'Next'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

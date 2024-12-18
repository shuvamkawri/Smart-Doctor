import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../../location_pages/city_list_page.dart';


class DiagnosisPage extends StatefulWidget {
  @override
  _DiagnosisPageState createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> tests = [];
  final TextEditingController testTypeNameController = TextEditingController();
  final TextEditingController testTypePriceController = TextEditingController();
  bool _isLoading = false;
  bool _dataLoaded = false;
  List<dynamic> _diagnosticList = [];
  List<PathologyTest> pathologyTests = [];
  List<Pathology> pathologyList = [];
  String? selectedTestId;
  String? selectedTestName;

  @override
  void initState() {
    super.initState();
    fetchDiagnosticList();
    fetchPathologyTests();
    fetchPathologyListAndSetState();
  }

  Future<void> fetchDiagnosticList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await get(
        'hospital/diagnostic-list/$userId',
        headers: {'accept': '*/*'},
      );

      final data = json.decode(response);
      setState(() {
        _diagnosticList = data['details'];
        _dataLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load diagnostic list')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchPathologyTests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pathologyId = prefs.getString('selected_pathology_id') ?? '';

    try {
      final response = await get(
        'pathology/pathologyTestList/$pathologyId',
        headers: {'accept': '*/*'},
      );

      final decodedResponse = json.decode(response);

      if (decodedResponse != null &&
          decodedResponse['details'] != null &&
          decodedResponse['details']['pathologyTest'] != null) {
        final List<dynamic> testList = decodedResponse['details']['pathologyTest'];

        if (testList is List) {
          setState(() {
            pathologyTests = testList.map((data) => PathologyTest.fromJson(data)).toList();
          });
        } else {
          throw Exception('Invalid test list format');
        }
      } else {
        throw Exception('Missing details or pathologyTest in response');
      }
    } catch (error) {
      print('Failed to load pathology tests: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pathology tests')),
      );
    }
  }


  Future<void> fetchPathologyListAndSetState() async {
    try {
      final list = await fetchPathologyList();
      setState(() {
        pathologyList = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pathology list')),
      );
    }
  }

  Future<List<Pathology>> fetchPathologyList() async {
    try {
      final selectedCity = await getSelectedCity();
      print('Selected city: $selectedCity'); // Added print statement

      print('Fetching pathology list...');
      final dynamic responseBody = await post(
        'pathology/list', // Endpoint specific to pathology list
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "city": selectedCity,
        }),
      );

      print('Response received: $responseBody'); // Added print statement

      final jsonData = jsonDecode(responseBody);
      final errorCode = jsonData['errorCode'];
      print('Error Code: $errorCode'); // Added print statement

      if (errorCode == 200) {
        final details = jsonData['details'] as List;
        print('Details: $details'); // Added print statement

         pathologyList =
        details.map<Pathology>((json) => Pathology.fromJson(json)).toList();

        print('List: $pathologyList'); // Added print statement
        print('Pathology list updated.'); // Added print statement

        return pathologyList;
      } else if (errorCode == 200) {
        // Show no data dialog for selected location
        // _showNoDataDialog();
        return [];
      } else {
        // Handle other error codes
        print('Error fetching pathology list: Error Code: $errorCode');
        throw Exception(
            'Failed to fetch pathology list. Error Code: $errorCode');
      }
    } catch (e) {
      print('Error fetching pathology list: $e');
      throw e; // Throw the error so the caller can handle it appropriately
    }
  }

  Future<void> createDiagnostic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    final endpoint = 'hospital/hosptal-diagnostic-create';

    final body = jsonEncode({
      'hospital_id': userId,
      'name': selectedTestName ?? '',  // Use the selected test name
      'name_type': tests.expand((test) {
        return test['testTypes'].map((type) {
          return {
            'name_type': type['typeName'],
            'price': type['price'] ?? '0.0',
          };
        }).toList();
      }).toList(),
    });

    try {
      final response = await post(
        endpoint,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final responseBody = json.decode(response);

      if (responseBody['results']['errorCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diagnostic created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create diagnostic')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating diagnostic')),
      );
    }
  }

  void addTestType(int testIndex) {
    setState(() {
      tests[testIndex]['testTypes'].add({
        'typeName': testTypeNameController.text,
        'price': testTypePriceController.text,
      });
      testTypeNameController.clear();
      testTypePriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: Colors.teal,
      body: Column(
        children: [
          Container(
            height: 110,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Text(
                    'Diagnosis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
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
                      icon: const Icon(Icons.dehaze_outlined, color: Colors.blue),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Pathology>(
                    decoration: const InputDecoration(
                      labelText: 'Select Pathology',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: pathologyList.map((pathology) {
                      return DropdownMenuItem<Pathology>(
                        value: pathology,
                        child: Text(pathology.name),
                      );
                    }).toList(),
                    onChanged: (Pathology? selectedPathology) async {
                      if (selectedPathology != null) {
                        print('Selected Pathology ID: ${selectedPathology.id}');
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selected_pathology_id', selectedPathology.id);
                        await fetchPathologyTests();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (pathologyTests.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Test Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: pathologyTests.map((test) {
                        return DropdownMenuItem<String>(
                          value: test.id,
                          child: Text(test.name),
                        );
                      }).toList(),
                      onChanged: (String? selectedTest) {
                        final selectedTestItem = pathologyTests.firstWhere((test) => test.id == selectedTest);
                        setState(() {
                          selectedTestId = selectedTest;
                          selectedTestName = selectedTestItem.name;
                        });
                        print('Selected Test ID: $selectedTest');
                        print('Selected Test Name: $selectedTestName');
                      },
                    ),

                  const SizedBox(height: 16),
                  if (selectedTestId != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tests.add({
                            'testId': selectedTestId,
                            'testTypes': [],
                          });
                          selectedTestId = null;
                        });
                      },
                      child: const Text('Add Test'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue, // Text color
                        backgroundColor: lightWhite, // Replace with your background color
                        padding: const EdgeInsets.symmetric(vertical: 13.0), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  for (int testIndex = 0; testIndex < tests.length; testIndex++)
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test: ${pathologyTests.firstWhere((test) => test.id == tests[testIndex]['testId']).name}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...tests[testIndex]['testTypes'].map<Widget>((type) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      type['typeName'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Price: ${type['price']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: testTypeNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Test Type Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: testTypePriceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Price',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  height: 50,

                                  child: ElevatedButton(
                                    onPressed: () => addTestType(testIndex),
                                    child: const Text('Add Type'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.blue, backgroundColor: Colors.white, // Text color
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : createDiagnostic,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue, // Text color
                        backgroundColor: lightWhite, // Replace with your background color
                        padding: const EdgeInsets.symmetric(vertical: 13.0), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loading indicator
                          : Text(
                        'Test Submit',
                        style: const TextStyle(
                          fontSize: 14, // Font size
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Pathology {
  final String id;
  final String name;

  Pathology({required this.id, required this.name});

  factory Pathology.fromJson(Map<String, dynamic> json) {
    return Pathology(
      id: json['_id'] ?? '',
      name: json['pathology_name']?? '',
    );
  }
}

class PathologyTest {
  final String id;
  final String name;
  final String description;

  PathologyTest({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PathologyTest.fromJson(Map<String, dynamic> json) {
    return PathologyTest(
      id: json['_id'],
      name: json['pathologyTest_id']['name'],
      description: json['pathologyTest_id']['description'],
    );
  }
}

// Example of retrieving the stored pathology ID
Future<void> printStoredPathologyId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedPathologyId = prefs.getString('selected_pathology_id');
  print('Stored Pathology ID: $storedPathologyId');
}
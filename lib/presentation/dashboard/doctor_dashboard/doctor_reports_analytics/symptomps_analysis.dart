
import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_reports_analytics/suggestions.dart';
import 'package:flutter/material.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import 'dart:convert'; // To decode the JSON response

class SymptomsPage extends StatefulWidget {
  @override
  _SymptomsPageState createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController(); // Controller for search bar

  // State variables
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> symptomsList = [];
  List<dynamic> filteredSymptomsList = []; // List to display filtered symptoms
  dynamic displayedSymptomsCount = 10; // Default count of symptoms to display, dynamic to handle "ALL"
  final List<dynamic> symptomOptions = [10, 25, 50, 100, 'ALL']; // Dropdown options with 'ALL'

  @override
  void initState() {
    super.initState();
    fetchSymptoms();
    _searchController.addListener(_filterSymptoms); // Add listener for search input
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  // Function to fetch symptoms from API
  Future<void> fetchSymptoms() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Using the common GET function to make the API request
      final response = await get('symptoms-list', headers: {
        'accept': '*/*',
      });

      // Check if response is null or not a valid JSON string
      if (response != null && response.isNotEmpty) {
        // Parse the response body
        final data = json.decode(response);

        // Check for valid error code
        if (data['errorCode'] == 200) {
          setState(() {
            symptomsList = data['details'] ?? []; // Update state with the symptoms list or an empty list
            filteredSymptomsList = symptomsList; // Initially, show all symptoms
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true; // Indicate an error if errorCode is not 200
            isLoading = false;
          });
        }
      } else {
        // Handle case where response is null or empty
        setState(() {
          hasError = true; // Indicate an error if response is null or empty
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle any exceptions that occur during the fetch
      setState(() {
        hasError = true; // Indicate an error on catch
        isLoading = false;
      });
    }
  }

  // Function to filter symptoms based on search query
  void _filterSymptoms() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredSymptomsList = symptomsList.where((symptom) {
        return symptom['symptoms_name'].toLowerCase().contains(query); // Ensure the correct key is used here
      }).toList();
    });
  }

  // Function to sort the symptoms list in ascending order
  void _sortSymptomsAscending() {
    setState(() {
      filteredSymptomsList.sort((a, b) => a['symptoms_name'].compareTo(b['symptoms_name']));
    });
  }

  // Function to sort the symptoms list in descending order
  void _sortSymptomsDescending() {
    setState(() {
      filteredSymptomsList.sort((a, b) => b['symptoms_name'].compareTo(a['symptoms_name']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: const Text(
            'Symptoms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dehaze_outlined, color: Colors.blue),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loading indicator
          : hasError
          ? Center(child: Text('Error loading symptoms')) // Show an error message
          : Column(
        children: [
          // Search bar to filter symptoms
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Symptoms',
                labelStyle: TextStyle(color: Colors.blue), // Set label text color to blue
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Dropdown to select number of symptoms to display and sorting icons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Show Symptoms: '),
                DropdownButton<dynamic>(
                  value: displayedSymptomsCount,
                  items: symptomOptions.map((dynamic value) {
                    return DropdownMenuItem<dynamic>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      displayedSymptomsCount = newValue;
                    });
                  },
                ),
                // Ascending sort icon
                IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: _sortSymptomsAscending,
                ),
                // Descending sort icon
                IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: _sortSymptomsDescending,
                ),
              ],
            ),
          ),

          // Display the list of filtered symptoms
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: displayedSymptomsCount == 'ALL'
                  ? filteredSymptomsList.length // Display all symptoms if 'ALL' is selected
                  : (filteredSymptomsList.length < displayedSymptomsCount
                  ? filteredSymptomsList.length
                  : displayedSymptomsCount),
              itemBuilder: (context, index) {
                final symptom = filteredSymptomsList[index];
                return Card(
                  child: ListTile(
                    title: Text(symptom['symptoms_name']), // Use 'symptoms_name' instead of 'symptoms'
                    onTap: () {
                      // Navigate to SuggestionPage with selected symptom details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestionPage(
                            symptom: symptom['symptoms_name'], // Pass the symptom name
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

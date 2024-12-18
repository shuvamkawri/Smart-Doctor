import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For better loading animation
import 'dart:convert'; // For JSON decoding
import 'package:animate_do/animate_do.dart'; // For simple animations
import '../../../../domain/common_fuction_api.dart'; // Assuming this is where the post function is defined
import '../../../../widgets/nav_drawer.dart';

class SuggestionPage extends StatefulWidget {
  final String symptom;

  const SuggestionPage({Key? key, required this.symptom}) : super(key: key);

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State variables
  bool isLoading = true;
  bool hasError = false;
  String? diagnosisSuggestion;
  String? prescriptionsOverview;
  String? suggest;
  String selectedType = 'Ayurvedic'; // Default selected type

  // State variables for the additional data
  String? drugA;
  String? drugB;
  String? drugC;
  String? drugD;
  String? drugF;

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  // Function to fetch suggestions from API
  Future<void> fetchSuggestions() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await post('suggestion-list',
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'symptoms': widget.symptom, // Send the selected symptom in the body
          'type': selectedType, // Send the selected suggestion type
        }),
      );

      final data = json.decode(response);

      if (data['errorCode'] == 200) {
        setState(() {
          diagnosisSuggestion = data['details']['symptoms_name'];
          prescriptionsOverview = data['details']['prescriptions_overview'];
          suggest = data['details']['suggest'];
          drugA = data['details']['drug_a'];
          drugB = data['details']['drug_b'];
          drugC = data['details']['drug_c'];
          drugD = data['details']['drug_d'];
          drugF = data['details']['drug_f'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar section with drawer and back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Health Suggestion',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
              ),

              // Add image from assets
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeInDown(
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Subtle shadow effect
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Apply rounded corners to the image
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/suggestion_tips.jpg',
                            height: 100,
                            width: double.infinity, // Full width image
                            fit: BoxFit.cover, // Cover mode to ensure no cropping
                          ),
                          Container(
                            height: 100, // Same height as the image
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              // Radio buttons for selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'Ayurvedic', // First option should be Ayurvedic
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          fetchSuggestions(); // Fetch suggestions when type changes
                        });
                      },
                    ),
                    Text(
                      'Ayurvedic',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(width: 20),
                    Radio<String>(
                      value: 'Allopathy', // Second option should be Allopathy
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          fetchSuggestions(); // Fetch suggestions when type changes
                        });
                      },
                    ),
                    Text(
                      'Allopathy',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content in scrollable view
              Expanded(
                child: isLoading
                    ? SpinKitWave(
                  color: Colors.white,
                  size: 50.0,
                )
                    : hasError
                    ? Center(
                  child: Text(
                    'No suggestion found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  child: FadeIn(
                    duration: Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Symptom: ${widget.symptom}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Diagnosis suggestion card
                          diagnosisSuggestion != null
                              ? ZoomIn(
                            duration: Duration(milliseconds: 600),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Suggested Diagnosis:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      diagnosisSuggestion!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                    SizedBox(height: 20),

                                    // Prescription overview
                                    if (prescriptionsOverview != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Prescriptions Overview:',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            prescriptionsOverview!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            softWrap: true,
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),

                                    // Drug information
                                    _buildDrugInfo('Drug A', drugA),
                                    _buildDrugInfo('Drug B', drugB),
                                    _buildDrugInfo('Drug C', drugC),
                                    _buildDrugInfo('Drug D', drugD),
                                    _buildDrugInfo('Drug F', drugF),

                                    // Suggested advice
                                    if (suggest != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'Suggestion:',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            suggest!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            softWrap: true,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Please consult Ayurvedic doctors or practitioners for better results.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.teal,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              : Text(
                            'No suggestion available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugInfo(String label, String? value) {
    if (value == null || value.isEmpty) {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

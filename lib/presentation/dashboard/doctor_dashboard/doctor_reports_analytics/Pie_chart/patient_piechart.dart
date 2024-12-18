import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../../../domain/common_fuction_api.dart';
import '../../../../../widgets/nav_drawer.dart';



class PatientPieChartPage extends StatefulWidget {
  final String doctorId;
  PatientPieChartPage({required this.doctorId});

  @override
  _PatientPieChartPageState createState() => _PatientPieChartPageState();
}

class _PatientPieChartPageState extends State<PatientPieChartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, double> patientData = {}; // Data for the pie chart
  bool isLoading = true;
  bool hasError = false; // Error state flag

  // Enhanced color palette for the pie chart
  final List<Color> colorList = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  @override
  void initState() {
    super.initState();
    fetchPatientData(); // Fetch data when the page is loaded
  }

  Future<void> fetchPatientData() async {
    try {
      final response = await get('patient-count/${widget.doctorId}'); // Replace with your API endpoint
      final data = jsonDecode(response);

      if (data['errorCode'] == 200) {
        if (data['details'] is Map) {
          // Convert Map to Map<String, double> for the pie chart
          Map<String, double> detailsMap = Map<String, double>.from(data['details']);
          setState(() {
            patientData = detailsMap;
            isLoading = false;
          });
        } else if (data['details'] is int) {
          double percentage = data['details'].toDouble();
          setState(() {
            patientData = {
              'Doctor': percentage,
              'Remaining': 100 - percentage,
            };
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected data format: details is not a recognized type');
        }
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (error) {
      print('Error fetching patient data: $error');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void onChartTap() {
    // Navigate to previous page when the pie chart is tapped
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(), // Your custom drawer
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom AppBar with title and buttons
          Container(
            height: MediaQuery.of(context).size.height * 0.05, // 5% of the screen height
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Container(
                  //   margin: const EdgeInsets.all(7),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     shape: BoxShape.circle,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         spreadRadius: 1,
                  //         blurRadius: 2,
                  //         offset: const Offset(0, 1),
                  //       ),
                  //     ],
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(Icons.arrow_back, color: Colors.blue),
                  //     onPressed: () {
                  //       Navigator.pop(context);
                  //     },
                  //   ),
                  // ),
                  // const Text(
                  //   'Patient Pie Chart',
                  //   style: TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.blue,
                  //   ),
                  // ),
                  // Container(
                  //   margin: const EdgeInsets.all(7),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     shape: BoxShape.circle,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         spreadRadius: 1,
                  //         blurRadius: 2,
                  //         offset: const Offset(0, 1),
                  //       ),
                  //     ],
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(Icons.dehaze_outlined),
                  //     color: Colors.blue,
                  //     onPressed: () {
                  //       _scaffoldKey.currentState?.openDrawer();
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Content area for the Pie Chart
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : hasError
                ? Center(child: Text('Error fetching patient data.', style: TextStyle(fontSize: 16, color: Colors.red))) // Show error message
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Distribution by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: onChartTap, // Call the method on tap
                      child: PieChart(
                        dataMap: patientData,
                        colorList: colorList, // Use the color list for the chart
                        chartRadius: MediaQuery.of(context).size.width / 2.2,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 32, // Width of the ring
                        centerText: "Patients",
                        centerTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                          decimalPlaces: 1, // Decimal places for percentage
                        ),
                        legendOptions: LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.bottom,
                          legendTextStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        animationDuration: Duration(milliseconds: 800),
                        emptyColor: Colors.grey[200]!, // Color when there's no data
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

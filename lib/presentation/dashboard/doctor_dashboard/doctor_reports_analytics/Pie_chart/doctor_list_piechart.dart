import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../../../domain/common_fuction_api.dart';
import '../../../../../widgets/nav_drawer.dart';


class DoctorPieChartPage extends StatefulWidget {
  final String hospitalId;

  DoctorPieChartPage({required this.hospitalId});

  @override
  _DoctorPieChartPageState createState() => _DoctorPieChartPageState();
}

class _DoctorPieChartPageState extends State<DoctorPieChartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool hasError = false;
  Map<String, double> doctorData = {}; // Data for the pie chart

  @override
  void initState() {
    super.initState();
    fetchDoctorData(); // Fetch doctor data when the page loads
  }

  Future<void> fetchDoctorData() async {
    try {
      final response = await get('doctor-list/${widget.hospitalId}');
      final data = jsonDecode(response);

      if (data['errorCode'] == 200) {
        // Extract doctors data and categorize by specialization
        Map<String, double> specializationCount = {};
        for (var doctor in data['details']) {
          String specialization = doctor['specialist']['category'];
          if (specializationCount.containsKey(specialization)) {
            specializationCount[specialization] =
                specializationCount[specialization]! + 1;
          } else {
            specializationCount[specialization] = 1;
          }
        }

        setState(() {
          doctorData = specializationCount; // Update chart data
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true; // Handle error response
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true; // Handle any errors during the request
      });
      print('Error fetching doctor data: $error');
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Your content here
              ],
            ),
          ),



          // Content area for the Pie Chart
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : hasError
                ? Center(child: Text('Error fetching doctor data.', style: TextStyle(fontSize: 16, color: Colors.red))) // Show error message
                : GestureDetector(
              onTap: onChartTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctors Distribution by Specialization',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        dataMap: doctorData,
                        colorList: [
                          Colors.blue,
                          Colors.green,
                          Colors.red,
                          Colors.orange,
                          Colors.purple,
                        ], // Customize colors
                        chartRadius: MediaQuery.of(context).size.width / 2.2,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 32, // Width of the ring
                        centerText: "Doctors",
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../../domain/common_fuction_api.dart';
import '../../../../../widgets/nav_drawer.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartPage extends StatefulWidget {
  @override
  _PieChartPageState createState() => _PieChartPageState();
}

class _PieChartPageState extends State<PieChartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, double> hospitalDataMap = {};
  bool isLoading = true;
  List<dynamic> hospitalCategories = [];

  // Colors for each section of the pie chart
  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple, // Add more colors if needed
  ];

  @override
  void initState() {
    super.initState();
    fetchHospitalCategories(); // Fetch categories when the page is loaded
  }

  Future<void> fetchHospitalCategories() async {
    try {
      final response = await get('hospital-category-list');
      final data = jsonDecode(response);
      if (data['errorCode'] == 200) {
        hospitalCategories = data['details'];
        await calculateHospitalPercentages();
      }
    } catch (error) {
      print('Error fetching categories: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> calculateHospitalPercentages() async {
    try {
      Map<String, double> tempDataMap = {};

      bool bhuHasData = false;

      // Check if BHU category exists
      for (var category in hospitalCategories) {
        String categoryId = category['_id'];
        String categoryName = category['name'];

        if (categoryName == "BHU") {
          final response = await get('hospital-list/$categoryId');
          final data = jsonDecode(response);

          if (data['errorCode'] == 200 && data['details'].isNotEmpty) {
            bhuHasData = true;
          }
          break;
        }
      }

      int totalCategories = hospitalCategories.length;

      if (bhuHasData) {
        // BHU gets 60% if it has data
        tempDataMap["BHU"] = 50.0;

        // Calculate remaining percentage and distribute equally among other categories
        double remainingPercentage = 100.0 - 50.0;
        int otherCategoriesCount = totalCategories - 1; // Excluding BHU

        if (otherCategoriesCount > 0) {
          double percentagePerCategory = remainingPercentage / otherCategoriesCount;
          for (var category in hospitalCategories) {
            String categoryName = category['name'];
            if (categoryName != "BHU") {
              tempDataMap[categoryName] = percentagePerCategory;
            }
          }
        }
      } else {
        // Distribute percentages equally if BHU has no data
        double percentagePerCategory = 100.0 / totalCategories;
        for (var category in hospitalCategories) {
          String categoryName = category['name'];
          tempDataMap[categoryName] = percentagePerCategory;
        }
      }

      setState(() {
        hospitalDataMap = tempDataMap;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching hospital data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onChartTap() {
    Navigator.pop(context); // Navigate back to the previous page
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
          // Container(
          //   height: 110,
          //   color: Colors.white,
          //   child: Padding(
          //     padding: const EdgeInsets.only(top: 25),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Container(
          //           margin: const EdgeInsets.all(7),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.2),
          //                 spreadRadius: 1,
          //                 blurRadius: 2,
          //                 offset: const Offset(0, 1),
          //               ),
          //             ],
          //           ),
          //           child: IconButton(
          //             icon: const Icon(Icons.arrow_back, color: Colors.blue),
          //             onPressed: () {
          //               Navigator.pop(context);
          //             },
          //           ),
          //         ),
          //         // Display the title of the page
          //         const Text(
          //           'Graphical View',
          //           style: TextStyle(
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.blue,
          //           ),
          //         ),
          //         Container(
          //           margin: const EdgeInsets.all(7),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.2),
          //                 spreadRadius: 1,
          //                 blurRadius: 2,
          //                 offset: const Offset(0, 1),
          //               ),
          //             ],
          //           ),
          //           child: IconButton(
          //             icon: const Icon(Icons.dehaze_outlined),
          //             color: Colors.blue,
          //             onPressed: () {
          //               _scaffoldKey.currentState?.openDrawer();
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // Pie chart content
          Expanded(
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator() // Display a loading indicator
                  : GestureDetector(
                onTap: onChartTap,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PieChart(
                    dataMap: hospitalDataMap, // Dynamically fetched data
                    animationDuration: const Duration(milliseconds: 800),
                    chartRadius: MediaQuery.of(context).size.width / 2,
                    colorList: colorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "Hospitals",
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.bottom,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import 'Pie_chart/hospital_piechart.dart';
import 'hospital_list_under_category.dart';



class DoctorReportsAnalytics extends StatefulWidget {
  const DoctorReportsAnalytics({Key? key}) : super(key: key);

  @override
  State<DoctorReportsAnalytics> createState() => _DoctorReportsAnalyticsState();
}

class _DoctorReportsAnalyticsState extends State<DoctorReportsAnalytics> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> hospitalCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalCategories();
  }

  // Fetch hospital categories
  Future<void> fetchHospitalCategories() async {
    try {
      final response = await get('hospital-category-list');
      final data = jsonDecode(response);
      if (data['errorCode'] == 200) {
        setState(() {
          hospitalCategories = data['details'];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavDrawer(), // Your custom drawer widget
        backgroundColor: Colors.grey[100], // Light background color
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Tabulation"),
              Tab(text: "Graphics"),
            ],
          ),
          title: const Text(
            "Hospital Reports",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          centerTitle: true,
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
        body: TabBarView(
          children: [
            // Tabulation Tab
            isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: hospitalCategories.length,
                itemBuilder: (context, index) {
                  final category = hospitalCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalListPage(
                            categoryId: category['_id'], // passing the category ID
                            categoryName: category['name'], // passing the category Name
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shadowColor: Colors.blueAccent.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.blueAccent, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Graphics Tab - directly display the PieChartPage content
            PieChartPage(),  // Replaces the button with the actual PieChartPage widget
          ],
        ),
      ),
    );
  }
}

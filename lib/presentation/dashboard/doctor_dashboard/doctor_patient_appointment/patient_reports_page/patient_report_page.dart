import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../consts/colors.dart';
import '../../../../../widgets/nav_drawer.dart';

class PatientReportPage extends StatefulWidget {
  const PatientReportPage({super.key});

  @override
  State<PatientReportPage> createState() => _PatientReportPageState();
}

class _PatientReportPageState extends State<PatientReportPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Text(
                          "Patient Reports",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.dehaze_outlined),
                            color: Colors.blue,
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: "Lab Test"),
              Tab(text: "ECG"),
              Tab(text: "IoT"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LabTestPage(),
                EcgPage(),
                IotPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LabTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labTestDetails = '''
    Blood Test:
    - Hemoglobin: 13.5 g/dL
    - White Blood Cell Count: 4,500 to 11,000 cells/mcL
    - Platelets: 150,000 to 450,000/mcL

    Urine Test:
    - pH: 6.0
    - Protein: Negative
    - Glucose: Negative

    X-Ray:
    - Chest X-Ray: Normal

    MRI:
    - Brain MRI: No abnormalities detected
    ''';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lab Test Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(labTestDetails, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Share.share('Check out this lab test report:\n\n$labTestDetails');
              },
              child: Text("Share Lab Test Report"),
            ),
          ],
        ),
      ),
    );
  }
}

class EcgPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ECG Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Detailed information about ECG will go here."),
          ],
        ),
      ),
    );
  }
}

class IotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IoT Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Detailed information about IoT devices will go here."),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../consts/colors.dart';
import '../../../../widgets/nav_drawer.dart';

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailPage({required this.doctor, Key? key}) : super(key: key);

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                                offset: Offset(0, 1), // changes position of shadow
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
                          "Medical Details",
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
                                offset: Offset(0, 1), // changes position of shadow
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(widget.doctor['image']!),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.doctor['name']!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.doctor['specialty']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(widget.doctor['contact']!),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Biography:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.doctor['biography']!),
                            const SizedBox(height: 10),
                            Text(
                              'Qualifications:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.doctor['qualifications']!),
                            const SizedBox(height: 10),
                            Text(
                              'Consultation Times:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.doctor['consultationTimes']!),
                            const SizedBox(height: 20),
                            Text(
                              'Department: ${widget.doctor['department']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Medical History:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...widget.doctor['medicalHistory'].map<Widget>((history) {
                              return Text('- $history');
                            }).toList(),
                            const SizedBox(height: 10),
                            Text(
                              'Patient Records:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...widget.doctor['patientRecords'].map<Widget>((record) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                    '${record['patientName']} - ${record['condition']} (Last Visit: ${record['lastVisit']})'),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),

            ),
          ),
        ],
      ),
    );

  }
}

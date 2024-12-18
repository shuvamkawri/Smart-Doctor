import 'package:flutter/material.dart';

import '../../../../consts/colors.dart';
import '../../../../widgets/nav_drawer.dart';

class InvoicePage extends StatefulWidget {
  final String patientName;
  final String patientID;
  final String service;
  final String cost;
  final String date;
  final String comments;

  const InvoicePage({
    Key? key,
    required this.patientName,
    required this.patientID,
    required this.service,
    required this.cost,
    required this.date,
    required this.comments,
  }) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
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
                          "Invoice",
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Details',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Table(
                              border: TableBorder.all(),
                              columnWidths: {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Patient Name'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.patientName),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Patient ID'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.patientID),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Service Provided'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.service),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Cost'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("\$${widget.cost}"),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Date'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.date),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Comments'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(widget.comments),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            Container(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Placeholder for actual print functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Invoice printed successfully!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                icon: Icon(Icons.print),
                                label: Text('Print Invoice'),
                              ),
                            ),
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

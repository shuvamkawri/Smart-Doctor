import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../../location_pages/country_list_page.dart';
import '../doctor_prescription/doctor_prescription_pages.dart';


class PharmacyProfile extends StatefulWidget {
  final String pharmacyId;

  const PharmacyProfile({Key? key, required this.pharmacyId}) : super(key: key);

  @override
  State<PharmacyProfile> createState() => _PharmacyProfileState();
}

class _PharmacyProfileState extends State<PharmacyProfile>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _descriptionController = TextEditingController();
  double _rating = 0.0; // Define _rating here
  bool _isLoading = false;

  String? pharmacyName;

  String? pharmacyImage;

  String? pharmacyExperience;
  String? pharmacyAverageReview;
  String? reviewUserName;
  String? reviewUserComment;
  String? reviewUserRating;
  String? reviewUserDate;
  List<dynamic>? reviewUserList;
  String? biography;
  String? experienceDetails;
  String? pharmacyestablish;

  String? pharmacyPhone;

  String? pharmacyCity;
  String? pharmacyState;

  Future<void> fetchPharmacyProfileData() async {
    const String endpoint = 'pharmacy/view';

    final Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {"id": "${widget.pharmacyId}"};

    String body = jsonEncode(requestData);

    try {
      var response = await post(endpoint, headers: headers, body: body);

      Map<String, dynamic> responseJson = jsonDecode(response);

      print('Response body: $responseJson');

      if (responseJson['result']['errorCode'] != 200) {
        final String errorMessage =
            responseJson['message'] ?? 'An unknown error occurred';
        print("Wrong Response : $errorMessage");
        return;
      }
      if (responseJson.isEmpty) {
        _showNoDataDialog();
      } else {
        if (!mounted) return;

        setState(() {
          final Map<String, dynamic> pharmacyDetails =
              responseJson['result']['result']['doctor_details'];

          pharmacyImage = pharmacyDetails["image"];
          pharmacyName = pharmacyDetails["pharmacy_name"];
          pharmacyCity = pharmacyDetails["city"];
          pharmacyState = pharmacyDetails["state"];
          pharmacyAverageReview =
              responseJson['result']['result']['average_review'].toString();
          biography = pharmacyDetails['biography'];
          pharmacyExperience = pharmacyDetails['experience_details'];
          pharmacyestablish = pharmacyDetails['establish'];

          print("Pharmacy image: $pharmacyImage");
          print("Pharmacy name: $pharmacyName");
          print("Pharmacy city: $pharmacyCity");
          print("Pharmacy review: $pharmacyAverageReview");

          reviewUserList = responseJson['result']['result']['review_user_list'];

          print("Review User Data : $reviewUserList");
        });
      }
    } catch (error) {
      print('Failed to load pharmacy profile: $error');
      throw Exception('Failed to load pharmacy profile: $error');
    }
  }

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString('user_id') ?? "";

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    final requestBody = {
      'type': 'pharmacy',
      "user_id": user_id,
      'doctorHospitalPharmacyPathology': widget.pharmacyId,
      'comment': _descriptionController.text,
      'review_number': _rating.toInt(),
    };

    print('request body $requestBody');
    try {
      final response = await post(
        'review/review-add',
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Body: $response');

      final responseJson = jsonDecode(response);
      if (responseJson['errorCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' ${responseJson['message']}')),
        );

        _descriptionController.clear();

        reviewUserList = responseJson['review_user_list'];

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to create review: ${responseJson['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create review')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading =
        false;
      });
    }
  }

  String truncateText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      return words.sublist(0, wordLimit).join(' ') + '...';
    }
    return text;
  }

  void _showNoDataDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Data Available for the selected location.'),
          content: Text(
            'Please change your location',
            style: TextStyle(color: Colors.blue),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountryListPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchPharmacyProfileData();
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
            height: 103,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10, left: 10, top: 10),
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
                                offset:
                                    Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.blue,
                            ),
                            color: Colors.black54,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                          child: Text(
                            "Pharmacy Profile",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 20,
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
                                offset:
                                    Offset(0, 1), // changes position of shadow
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 250,
                          child: pharmacyImage != null
                              ? Image.network(
                                  "$imageUrlBase${pharmacyImage!}",fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                )
                              : SizedBox(), // Placeholder when pharmacyImage is null
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  pharmacyName ?? "Default lab Name",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  '${pharmacyCity ?? ''}${pharmacyCity != null && pharmacyState != null ? ', ' : ''}${pharmacyState ?? ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Icon(
                                      Icons.people,
                                      color: Colors.black54,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Patient",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            "10.20K",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.black54,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Review",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            pharmacyAverageReview ??
                                                "Loading...",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: Icon(
                                      Icons.watch,
                                      color: Colors.black54,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Establishment",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            pharmacyestablish ??
                                                "N/A", // Display "N/A" if pharmacyEstablish is null
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black54,
                              width: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: DefaultTabController(
                      length: 3,
                      child: Builder(
                        builder: (BuildContext context) {
                          final TabController tabController =
                              DefaultTabController.of(context)!;

                          String cleanedBiography = biography?.replaceAll(
                                  RegExp(r'<[^>]*>|&nbsp;'), '') ??
                              '';

                          String cleanedExperience = pharmacyExperience
                                  ?.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '') ??
                              '';
                          return Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: TabBar(
                                  tabs: [
                                    Tab(
                                      text: 'Overview',
                                    ),
                                    Tab(text: 'Experience'),
                                    Tab(text: 'Review'),
                                  ],
                                  controller:
                                      tabController, // assign the controller
                                ),
                              ),
                              Container(
                                height: 300,
                                child: TabBarView(
                                  controller:
                                      tabController, // assign the controller
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  "About Pharmacy",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                child: Text(
                                                  cleanedBiography.isNotEmpty
                                                      ? truncateText(
                                                          cleanedBiography, 100)
                                                      : "Biography not available",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [],
                                          )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [],
                                          )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [],
                                          )),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 25,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                cleanedExperience.isNotEmpty
                                                    ? cleanedExperience
                                                    : "Experience details not available",
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 10, top: 10),
                                            child: Text(
                                              "Rate Us",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 10),
                                                RatingBar.builder(
                                                  initialRating: 0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 4.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {
                                                    setState(() {
                                                      _rating = rating;
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 20),
                                                TextField(
                                                  controller:
                                                      _descriptionController,
                                                  maxLines: 5,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Description',
                                                    alignLabelWithHint: true,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                SizedBox(
                                                  height:
                                                      50, // Set a specific height for the button
                                                  width: double
                                                      .infinity, // Make the button as wide as its parent
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor: bgColor,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 13.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                    onPressed: _isLoading
                                                        ? null
                                                        : _submitReview,
                                                    child: _isLoading
                                                        ? CircularProgressIndicator()
                                                        : Text(
                                                            'Submit',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 10, top: 10),
                                            child: Text(
                                              "Reviews (${reviewUserList?.length ?? 0})", // Display the number of reviews dynamically
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                reviewUserList?.length ?? 0,
                                            itemBuilder: (context, index) {
                                              var reviewUser =
                                                  reviewUserList?[index] ?? {};
                                              print(
                                                  'review length $reviewUser');
                                              return GestureDetector(
                                                onTap: () {
                                                  // Handle onTap action if needed
                                                },
                                                child: Container(
                                                  color: Colors.white,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin: EdgeInsets.only(
                                                            left: 5, right: 5),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            50,
                                                                        width:
                                                                            50,
                                                                        child:
                                                                            CircleAvatar(
                                                                          child:
                                                                              Text(
                                                                            (reviewUser["user_name"] as String?)?.isNotEmpty == true
                                                                                ? reviewUser["user_name"][0].toUpperCase()
                                                                                : "", // Display first character of user name as avatar
                                                                          ),
                                                                          radius:
                                                                              25,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              12),
                                                                      Container(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              reviewUser["user_name"] ?? "Loading...",
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 170,
                                                                              child: Text(
                                                                                reviewUser["comment"] ?? "Loading...",
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black54,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar
                                                                          .builder(
                                                                        initialRating:
                                                                            double.tryParse(reviewUser["review_number"].toString() ?? '0.0') ??
                                                                                0.0,
                                                                        minRating:
                                                                            1,
                                                                        itemSize:
                                                                            14.0,
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        allowHalfRating:
                                                                            true,
                                                                        itemCount:
                                                                            5,
                                                                        itemBuilder:
                                                                            (context, _) =>
                                                                                Icon(
                                                                          Icons
                                                                              .star,
                                                                          color:
                                                                              Colors.amberAccent,
                                                                        ),
                                                                        onRatingUpdate:
                                                                            (double
                                                                                value) {},
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              3),
                                                                      Text(
                                                                        "(${reviewUser["review_number"]?.toString() ?? '0.0'})",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black54,
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
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors.black54,
                                                            width: 0.1,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, top: 10),
                                              child: Text(
                                                "Tap here for all reviews",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: bgColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                // onPressed: _performSignIn,
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => DoctorPrescriptionPages(pharmacyId: widget.pharmacyId,),));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: bgColor,
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Upload Prescriptions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




}

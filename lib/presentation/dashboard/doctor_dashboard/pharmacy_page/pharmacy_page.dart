import 'dart:convert';


import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/pharmacy_page/pharmacy_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';


class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  List<Pharmacy> pharmacyList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Pharmacy> filteredPharmacyList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPharmacyList();
    searchController.addListener(_filterPharmacy);
  }

  Future<String> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCity = prefs.getString('cityName') ?? '';
    print('Selected City: $selectedCity');
    return selectedCity;
  }

  void _filterPharmacy() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPharmacyList = pharmacyList.where((Pharmacy) {
        return Pharmacy.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchPharmacyList() async {
    try {
      String selectedCity = await getSelectedCity();
      print('Fetching pharmacy list...');
      final response = await post(
        'pharmacy/list', // Endpoint specific to pharmacy list
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "city": selectedCity,
        }),
      );

      print('Response received: $response');

      final jsonData = jsonDecode(response);
      final results = jsonData['results']['result'] as List;

      setState(() {
        pharmacyList = results.map((json) => Pharmacy.fromJson(json)).toList();
      });
      filteredPharmacyList = pharmacyList;
      print('Pharmacy list updated.');
    } catch (e) {
      print('Error fetching pharmacy list: $e');
    }
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
            height: 190,
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
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
                            },
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
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        errorText: null,
                        prefixIcon: Icon(
                            Icons.search), // Use prefixIcon instead of prefix
                        hintText: 'Find your suitable pharmacy!',
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              width: 0.3,
                              color: Colors.white), // Set border width to 0.3
                        ),
                      ),
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "Top Pharmacy ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // itemCount: pharmacyList.length,
                      // itemBuilder: (context, index) {
                      //   var pharmacy = pharmacyList[index];
                      itemCount: filteredPharmacyList.length,
                      itemBuilder: (context, index) {
                        var pharmacy = filteredPharmacyList[index];
                        return GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: PharmacyProfile(
                                pharmacyId: pharmacy.id,
                              ), // Pass pharmacy data to PharmacyProfile
                              withNavBar: false,
                            );
                          },
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                child: Image.network(
                                                  pharmacy
                                                      .image, // Use pharmacy image from API
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      pharmacy
                                                          .name, // Use pharmacy name from API
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          child:
                                                          RatingBar.builder(
                                                            minRating: 1,
                                                            itemSize: 14.0,
                                                            direction:
                                                            Axis.horizontal,
                                                            allowHalfRating:
                                                            true,
                                                            itemCount: 5,
                                                            itemBuilder:
                                                                (context, _) =>
                                                                Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amberAccent,
                                                                ),
                                                            onRatingUpdate:
                                                                (double
                                                            value) {},
                                                          ),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Container(
                                                          child: Text(
                                                            "4.9", // Replace with actual rating from API if available
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Container(
                                                          child: Text(
                                                            "(5,380)", // Replace with actual review count from API if available
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 200,
                                                    child: Text(
                                                      pharmacy
                                                          .address, // Use pharmacy address from API
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
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
                        );
                      },
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

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String city;
  final String image;
  final String? registrationId;
  final String? state;
  final String? openingTime;
  final String? closingTime;
  final String? contactNumber;
  final String? email;
  final String? website;
  final String? licenseNumber;
  final String? totalEmployee;
  final String? doctorName;
  final String? biography;
  final String? gstNumber;
  final String? panNumber;
  final String? experienceDetails;
  final String? establish;

  final String? createdBy;
  final DateTime? createdAt;
  final bool? isApprove;
  final DateTime? updatedAt;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.image,
    required this.experienceDetails,
    required this.establish,
    this.registrationId,
    this.state,
    this.openingTime,
    this.closingTime,
    this.contactNumber,
    this.email,
    this.website,
    this.licenseNumber,
    this.totalEmployee,
    this.doctorName,
    this.biography,
    this.gstNumber,
    this.panNumber,
    this.createdBy,
    this.createdAt,
    this.isApprove,
    this.updatedAt,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['_id'],
      name: json['pharmacy_name'],
      address: json['address'],
      city: json['city'],
      image: '$imageUrlBase${json['image']}',
      registrationId: json['registration_id'],
      state: json['state'], // Assign null if state is null in the response
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      contactNumber: json['contact_number'],
      email: json['email'],
      website: json['website'],
      establish: json['establish'],
      licenseNumber: json['license_number'],
      totalEmployee: json['total_emplyee'],
      doctorName: json['doctor_name'],
      biography: json['biography'],
      experienceDetails: json['experience_details'],
      gstNumber: json['gst_number'],
      panNumber: json['pan_number'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isApprove: json['is_approve'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

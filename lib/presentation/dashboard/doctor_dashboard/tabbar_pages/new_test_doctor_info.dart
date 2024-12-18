import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../consts/colors.dart';
import '../../../../../domain/common_fuction_api.dart';
import '../../doctor_model_pages/treatment_model.dart';

class DoctorInfoProfilePage extends StatefulWidget {
  const DoctorInfoProfilePage({super.key});

  @override
  State<DoctorInfoProfilePage> createState() => _DoctorInfoProfilePageState();
}

class _DoctorInfoProfilePageState extends State<DoctorInfoProfilePage> {
  // for treatment data
  String? selectedCategory;
  List<Map<String, String>> selectedCategoryId = [];
  List<TreatmentCategory> treatmentsCategory = [];
  List<SubCategory> selectedSubCategories = [];
  List<TreatmentSubCategory> treatmentsSubCategory = [];
  bool showSubCategoryList = false;
  List<Map<String, dynamic>> fetchTreatmentSubmitSubCategory = [];

  Future<void> treatmentCategory() async {
    try {
      final response = await get(
        'doctor/treatment-list',
        headers: {'accept': '*/*'},
      );

      print('Response received: $response');

      final decodedResponse = json.decode(response);
      print('Decoded response: $decodedResponse');
      final List<dynamic> treatmentCategoryData = decodedResponse['details'];
      if (!mounted) return;
      setState(() {
        treatmentsCategory = treatmentCategoryData.map((data) {
          return TreatmentCategory.fromJson(data);
        }).toList();
        print('Treatments11111$treatmentsCategory');
      });
      print('Treatment loaded successfully: $treatmentsCategory');
    } catch (error) {
      print('Failed to load treatment type: $error');
    }
  }

  Future<void> treatmentSubCategory(String category) async {
    try {
      final response = await post(
        'doctor/treatment/subcategory-list',
        headers: {
          'accept': '/',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'parent_name': category,
        }),
      );

      print('Response received: ${response}');

      final decodedResponse = json.decode(response);
      print('Decoded response: $decodedResponse');
      final List<dynamic> treatmentSubCategoryData =
      decodedResponse['results']['details'];
      if (!mounted) return;
      setState(() {
        treatmentsSubCategory = treatmentSubCategoryData.map((data) {
          return TreatmentSubCategory.fromJson(data);
        }).toList();
        print('TreatmentsSubCategory: $treatmentsSubCategory');
      });
      print('Treatment loaded successfully: $treatmentsSubCategory');
    } catch (error) {
      print('Failed to load treatment sub-category: $error');
    }
  }

  Future<void> treatmentSubCategorySubmitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    try {
      final response = await post(
        'doctor/treatment/update',
        headers: {
          'accept': '/',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "user_id": userId,
          "treatment": selectedCategory,
          "sub_treatment": selectedCategoryId
        }),
      );

      print('Response received: ${response}');

      final data = json.decode(response);
      String errorMessage = data['message'] ?? 'An unknown error occurred';
      if (data['errorCode'] == 200) {
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      print('Failed to load treatment sub-category: $error');
    }
  }

  Future<void> fetchTreatmentSubCategorySubmitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    try {
      final response = await get(
        'doctor/treatment-list/$userId',
        headers: {'accept': '*/*'},
      );

      print('Response received: ${response}');

      final data = json.decode(response);

      // Check if the response contains the expected structure
      if (data['errorCode'] == 200 && data['details'] != null) {
        var fetchTreatmentSubmitData = data["details"];
        print(fetchTreatmentSubmitData);

        setState(() {
          selectedCategory = fetchTreatmentSubmitData['specialist']?["_id"];
          print("selectedCategoryData:$selectedCategory");
          List subTreatments = fetchTreatmentSubmitData['sub_treatment'] ?? [];

          for (var subTreatment in subTreatments) {
            var subTreatmentId = subTreatment['sub_treatment_id']?['_id'];
            if (subTreatmentId != null) {
              selectedCategoryId.add({'_id': subTreatmentId});
              selectedSubCategories.add(SubCategory(
                name: subTreatment['sub_treatment_id']['sub_category'] ?? 'Unknown',
                isSelected: true,
              ));
              print("fetchSelectedCategoryId:$selectedCategoryId");
            }
          }
        });
      } else {
        print('Unexpected response structure or errorCode is not 200.');
      }
    } catch (error) {
      print('Failed to load treatment sub-category: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    treatmentCategory();
    fetchTreatmentSubCategorySubmitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightWhite,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: DefaultTabController(
                      length: 4,
                      child: Builder(
                        builder: (BuildContext context) {
                          final TabController tabController =
                          DefaultTabController.of(context)!;

                          return Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: TabBar(
                                  isScrollable: true,
                                  tabAlignment: TabAlignment.start,
                                  tabs: [
                                    Tab(
                                      text: 'Doctor Info',
                                    ),
                                    Tab(text: 'Qualification'),
                                    Tab(text: 'Hospital Affiliation'),
                                    Tab(text: 'Treatment'),
                                  ],
                                  controller:
                                  tabController, // assign the controller
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height:
                                MediaQuery.of(context).size.height * 0.80,
                                child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  controller: tabController,
                                  children: [
                                    SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                              'Treatment Categories',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              children: treatmentsCategory
                                                  .map((category) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    await treatmentSubCategory(
                                                        category.category);
                                                    setState(() {
                                                      selectedCategory = category.id;
                                                      showSubCategoryList = true;
                                                      print("selectedCategory:$selectedCategory");
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.all(3),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                      children: [
                                                        ListTile(
                                                          contentPadding:
                                                          EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              10,
                                                              vertical:
                                                              5),
                                                          title: Text(
                                                            category.category,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color:
                                                              Colors.blue,
                                                            ),
                                                          ),
                                                          trailing: Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                          tileColor:
                                                          Colors.white,
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                10),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                    0.5)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        if (showSubCategoryList &&
                                                            selectedCategory ==
                                                                category.id)
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10), // Adjust the radius as needed
                                                                ),
                                                                padding:
                                                                EdgeInsets
                                                                    .all(
                                                                    10),
                                                                child: Text(
                                                                  'Select Subcategories',
                                                                  style:
                                                                  TextStyle(
                                                                    fontSize:
                                                                    18,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              SingleChildScrollView(
                                                                physics:
                                                                NeverScrollableScrollPhysics(),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children:
                                                                  treatmentsSubCategory
                                                                      .map(
                                                                          (subCategory) {
                                                                        return CheckboxListTile(
                                                                          title: Text(
                                                                              subCategory
                                                                                  .subCategoryListName),
                                                                          value: selectedSubCategories.any((sc) =>
                                                                          sc.name ==
                                                                              subCategory.subCategoryListName &&
                                                                              sc.isSelected),
                                                                          onChanged:
                                                                              (bool?
                                                                          value) {
                                                                            setState(
                                                                                    () {
                                                                                  final existingIndex = selectedSubCategories.indexWhere((sc) =>
                                                                                  sc.name ==
                                                                                      subCategory.subCategoryListName);

                                                                                  // Update the selectedCategoryId list
                                                                                  if (value ??
                                                                                      false) {
                                                                                    selectedCategoryId.add({
                                                                                      "sub_treatment_id": subCategory.subCategoryListId,
                                                                                      "sub_treatment_id": subCategory.subCategoryListId,
                                                                                    });
                                                                                  } else {
                                                                                    selectedCategoryId.removeWhere((map) =>
                                                                                    map["sub_treatment_id"] ==
                                                                                        subCategory.subCategoryListId);
                                                                                  }

                                                                                  if (existingIndex !=
                                                                                      -1) {
                                                                                    selectedSubCategories[existingIndex].isSelected =
                                                                                        value ?? false;
                                                                                  } else {
                                                                                    selectedSubCategories.add(SubCategory(
                                                                                        name: subCategory.subCategoryListName,
                                                                                        isSelected: value ?? false));
                                                                                  }

                                                                                  print(
                                                                                      "selectedCategoryId:$selectedCategoryId");
                                                                                });
                                                                          },
                                                                        );
                                                                      }).toList(),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    width: 155,
                                                                    child:
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                                () {
                                                                              showSubCategoryList =
                                                                              false;
                                                                            });
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                        bgColor,
                                                                        foregroundColor:
                                                                        Colors.white,
                                                                        shape:
                                                                        RoundedRectangleBorder(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                        ),
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                            16,
                                                                            vertical:
                                                                            14),
                                                                      ),
                                                                      child:
                                                                      Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                            16,
                                                                            fontWeight:
                                                                            FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 155,
                                                                    child:
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                                () {
                                                                              showSubCategoryList =
                                                                              false; // Hide the subcategory list
                                                                            });
                                                                        // Do something with selected subcategories
                                                                        List<String> selectedNames = selectedSubCategories
                                                                            .where((sc) =>
                                                                        sc.isSelected)
                                                                            .map((sc) => sc.name)
                                                                            .toList();
                                                                        print(
                                                                            'Selected Subcategories: $selectedNames');

                                                                        treatmentSubCategorySubmitData();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                        bgColor,
                                                                        foregroundColor:
                                                                        Colors.white,
                                                                        shape:
                                                                        RoundedRectangleBorder(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                        ),
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                            16,
                                                                            vertical:
                                                                            14),
                                                                      ),
                                                                      child:
                                                                      Text(
                                                                        "Ok",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                            16,
                                                                            fontWeight:
                                                                            FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TreatmentDoctorTab {
  String treatmentDataId;
  String treatmentSabCategoryData;
  String treatmentParentname;

  TreatmentDoctorTab({
    required this.treatmentDataId,
    required this.treatmentSabCategoryData,
    required this.treatmentParentname,
  });

  factory TreatmentDoctorTab.fromJson(Map<String, dynamic> json) {
    return TreatmentDoctorTab(
      treatmentDataId: json['_id'],
      treatmentSabCategoryData: json['sub_category'],
      treatmentParentname: json['parent_name'],
    );
  }
}

class SubCategory {
  String name;
  bool isSelected;

  SubCategory({
    required this.name,
    this.isSelected = false,
  });
}

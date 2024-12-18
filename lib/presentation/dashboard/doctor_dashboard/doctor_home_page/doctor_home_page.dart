import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../consts/colors.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../doctor_model_pages/doctor_home_model_pages.dart';
import '../doctor_billing_invoicing/doctor_billing_invoicing.dart';
import '../doctor_create_appointment/appointment_schedule_create.dart';
import '../doctor_diagnosis/diagnosis.dart';
import '../doctor_patient_appointment/doctor_patient_appointment.dart';
import '../doctor_prescription/doctor_prescription_pages.dart';
import '../doctor_reports_analytics/doctor_reports_analytics.dart';
import '../pharmacy_page/pharmacy_page.dart';
import '../subscription/subscribe.dart';

import '../subscription/upgrade_subscrption.dart';
import '../tabbar_pages/doctor_info_profile_page.dart';



class DoctorHomePage extends StatefulWidget {
  final String productName;

  const DoctorHomePage({Key? key, required this.productName}) : super(key: key);


  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {

  List<String> images = [];
  List<DoctorHomeCategoryModel> heathCategory = [];
  double profileCompletion = 0.0; // Variable to hold profile completion percentage

  void _navigateToCategoryPage(String categoryNavigate) {
    // You can add more conditions if needed for other pages
    if (categoryNavigate == 'PatientAppointmentPage') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PatientAppointmentPage(),
        withNavBar: false,
      );
    }
    else if (categoryNavigate == 'DoctorInfoProfilePage') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DoctorInfoProfilePage(),
        withNavBar: false,
      );
    }

    // else if (categoryNavigate == 'DoctorMedicalRecords') {
    //   PersistentNavBarNavigator.pushNewScreen(
    //     context,
    //     screen: DoctorMedicalRecords(),
    //     withNavBar: false,
    //   );
    // }

    else if (categoryNavigate == 'DoctorPrescriptionPages') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DoctorPrescriptionPages(pharmacyId: '',),
        withNavBar: false,
      );
    }

    else if (categoryNavigate == 'CreateAppointment') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: CreateAppointment(),
        withNavBar: false,
      );
    }

    else if (categoryNavigate == 'DoctorBillingInvoicing') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DoctorBillingInvoicing(),
        withNavBar: false,
      );
    }

    else if (categoryNavigate == 'DoctorReportsAnalytics') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DoctorReportsAnalytics(),
        withNavBar: false,
      );
    }

    else if (categoryNavigate == 'PharmacyList') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PharmacyList(),
        withNavBar: false,
      );
    }

    else if (categoryNavigate == 'SubscriptionPlansPage') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: SubscriptionPlansPage(planName: _planName),
        withNavBar: false,
      );
    }



    else if (categoryNavigate == 'PatientDiagnosisPage') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DiagnosisPage(),
        withNavBar: false,
      );
    }
  }


  // List<DoctorHomeCategoryModel> heathCategory = [
  //
  //   DoctorHomeCategoryModel(
  //     doctorCategoryName: 'Patient Management',
  //     doctorCategoryIcon: 'assets/images/patients-management.png',
  //     doctorCategoryNavigate: 'PatientManagementPage',
  //   ),
  //
  //   // DoctorHomeCategoryModel(
  //   //   doctorCategoryName: "Medical Records",
  //   //   doctorCategoryIcon: 'assets/images/medical_records.png',
  //   //   doctorCategoryNavigate: 'DoctorMedicalRecords',
  //   // ),
  //
  //   DoctorHomeCategoryModel(
  //     doctorCategoryName: 'Prescriptions',
  //     doctorCategoryIcon: 'assets/images/prescription_image_icon.png',
  //     doctorCategoryNavigate: 'DoctorPrescriptionPages',
  //   ),
  //
  //   DoctorHomeCategoryModel(
  //     doctorCategoryName: 'Appointm...',
  //     doctorCategoryIcon: 'assets/images/appointment_image_icon.png',
  //     doctorCategoryNavigate: 'Appointment',
  //   ),
  //
  //   DoctorHomeCategoryModel(
  //     doctorCategoryName: 'Billing and Invoicing',
  //     doctorCategoryIcon: 'assets/images/billing_invoice.png',
  //     doctorCategoryNavigate: 'DoctorBillingInvoicing',
  //   ),
  //
  //   DoctorHomeCategoryModel(
  //     doctorCategoryName: 'Reports and Analytics',
  //     doctorCategoryIcon: 'assets/images/reports_analaytic.png',
  //     doctorCategoryNavigate: 'DoctorReportsAnalytics',
  //   ),
  //
  // ];


  Future<void> fetchProfileCompletionPercentage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    try {
      // Define the endpoint
      String endpoint = 'doctor/profile-percentage-details/$userId';

      // Make the POST request using the common function
      var response = await post(endpoint);

      // Print the raw response body (for debugging)
      print('Raw response: $response');

      // Parse the response (assuming it's JSON)
      var data = jsonDecode(response);

      if (data['errorCode'] == 200) {
        // Extract the profile percentage
        String profilePercentage = data['details']['status_percentage'];
        profileCompletion =
            double.parse(profilePercentage); // Save the percentage
        setState(() {}); // Update the UI
      } else {
        print('Error: ${data['errorCode']}');
      }
    } catch (e) {
      print('Error fetching profile completion: $e');
    }
  }


  Future<void> fetchAndSetHealthCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String plan = prefs.getString('plan_name') ?? '';
    try {
      print('Getting SharedPreferences instance...');
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences instance obtained.');

      final selectedOption = prefs.getString('selectedOption') ?? '';
      print('Selected option from SharedPreferences: $selectedOption');

      print('Making API call...');
      final response = await get('doctor-menu-list?subscribe_type=$plan',
          headers: {
        'accept': '*/*',
      });
      print('API call completed. Response: $response');

      print('Decoding the response...');
      final Map<String, dynamic> jsonResponse = json.decode(response);
      print('Decoded response: $jsonResponse');

      if (jsonResponse['errorCode'] == 200) {
        print('Error code 200 received. Processing response...');
        setState(() {
          final List<dynamic> categoryDetails = jsonResponse['details'];
          print('Category details received: $categoryDetails');

          // Flatten the list of lists
          final List<dynamic> flattenedCategories = categoryDetails.expand((list) => list).toList();

          heathCategory = flattenedCategories
              .map((item) => DoctorHomeCategoryModel.fromJson(item))
              .toList();
          print('HeathCategory list updated: $heathCategory');
        });
      } else {
        throw Exception(
            'Failed to load health categories: ${jsonResponse['errorCode']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> fetchBanner() async {
    try {
      var response = await get('banner-list');
      print('Response body: $response');
      final data = json.decode(response);
      print(data);
      int? errorCode = data["errorCode"];
      if (errorCode == 200) {
        setState(() {
          List<dynamic> details = data['details'];
          var imageList = details.map((detail) => detail['images'] as String)
              .toList();
          images.addAll(imageList);
          print("images: $images");
        });
      } else {
        throw Exception(
            'Failed to load health categories: ${data['errorCode']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _planName = "Loading..."; // Initial placeholder value

  @override
  void initState() {
    super.initState();
    fetchBanner();
    _loadPlanName(); // Load the plan name from SharedPreferences
    fetchProfileCompletionPercentage();
    fetchAndSetHealthCategories();
    _getDashboardStatus().then((status) {
      setState(() {
        dashboardStatus = status;
      });
    });
  }



  Future<void> _loadPlanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPlan = prefs.getString('plan_name');
    setState(() {
      _planName = storedPlan ?? "No Plan Selected"; // Fallback if not found
    });
  }

  Future<bool> _getDashboardStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dashboardStatus') ??
        false; // Default to false if not set
  }

// Call this function in your initState or wherever appropriate to load the status
  bool dashboardStatus = false;


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
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FutureBuilder<String?>(
                              future: SharedPreferences.getInstance()
                                  .then((prefs) => prefs.getString('full_name')),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String? fullName = snapshot.data;
                                  String firstLetter =
                                  fullName != null && fullName.isNotEmpty ? fullName[0] : '';

                                  return CircleAvatar(
                                    radius: 25,
                                    backgroundColor: bgColor,
                                    child: Text(
                                      firstLetter.toUpperCase(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Doctor",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                FutureBuilder<String?>(
                                  future: SharedPreferences.getInstance()
                                      .then((prefs) => prefs.getString('full_name')),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        "${snapshot.data}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  "$_planName",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
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
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        errorText: null,
                        prefixIcon: Icon(
                            Icons.search),
                        // Use prefixIcon instead of prefix
                        hintText: 'Find your suitable doctor!',
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              width: 0.1
                          ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the radius as needed
                        ),
                        child: Swiper(
                          autoplay: true,
                          itemCount: images.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                '$imageUrlBase${images[index]}',
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            // Set the number of columns here
                            crossAxisSpacing: 0.0,
                            // Adjust spacing between columns
                            mainAxisSpacing: 5.0, // Adjust spacing between rows
                          ),
                          itemCount: heathCategory.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isProfileIcon = heathCategory[index]
                                .doctorCategoryName ==
                                'Profile'; // Profile Icon Condition
                            bool isEnabled = profileCompletion >= 50 ||
                                isProfileIcon; // Enable only if completion >= 50% or it's the profile icon

                            return GestureDetector(
                              onTap: () {
                                if (isEnabled) { // Only allow navigation if enabled
                                  _navigateToCategoryPage(heathCategory[index]
                                      .doctorCategoryNavigate);
                                } else {
                                  // Show a dialog to complete the profile if the icon is disabled
                                  _showProfileCompletionDialog(context);
                                }
                              },
                              child: Opacity(
                                opacity: isEnabled ? 1.0 : 0.5,
                                // Grey out the icon if status is less than 50
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // Set a background color if needed
                                    borderRadius: BorderRadius.circular(
                                        20), // Set border radius
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                20),
                                            // Clip the image to the rounded corners
                                            child: Image.network(
                                              heathCategory[index]
                                                  .doctorCategoryIcon,
                                              fit: BoxFit
                                                  .cover, // Adjust the fit to your requirements
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Expanded(
                                          child: Text(
                                            heathCategory[index]
                                                .doctorCategoryName,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isEnabled
                                                  ? Colors.black
                                                  : Colors
                                                  .grey, // Grey out text if status is less than 50
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Function to show the profile completion dialog
  void _showProfileCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Profile Completion Suggested"),
          content: Text(
            "To unlock all features, we encourage you to complete at least 25% of your profile. "
                "This helps us provide a better experience for you.",
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onOptionSelected(String choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedOption', choice);
    await fetchAndSetHealthCategories(); // Fetch data immediately
  }
}

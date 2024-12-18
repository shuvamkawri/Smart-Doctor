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
import '../../../authentication/login_page.dart';
import '../../doctor_model_pages/hospital_model.dart';
import '../../doctor_model_pages/treatment_model.dart';

class DoctorDrawerProfile extends StatefulWidget {
  const DoctorDrawerProfile({super.key});

  @override
  State<DoctorDrawerProfile> createState() => _DoctorDrawerProfileState();
}

class _DoctorDrawerProfileState extends State<DoctorDrawerProfile> with SingleTickerProviderStateMixin{
  late TabController _tabController; // TabController for handling tab changes
  int currentStep = 0; // Define the current step variable

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? imagePath;
  String? imageUrl;
  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  late String _storedMobileNo = "";
  late String _storedCountryCode = "";
  String _callingCode = '';

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController doctorLicenseNumber = TextEditingController();
  TextEditingController regestrationNumber = TextEditingController();
  TextEditingController experienceYear = TextEditingController();
  TextEditingController website = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController panCardAndSsn = TextEditingController();
  TextEditingController biograpgy = TextEditingController();
  TextEditingController experienceDetails = TextEditingController();

  List<TreatmentType> Treatment = [];
  List<HospitalType> Hospital = [];
  TextEditingController otherHospital = TextEditingController();
  TextEditingController contactPerson = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController contactEmail = TextEditingController();
  TextEditingController contactComment = TextEditingController();

  String? selectedTreatment;
  String? fetchTreatmentType;
  String? fetchGenderType;
  List<HospitalType> selectedHospitals = [];
  List<Map<String, String>> selectedData = [];
  List<String> sex = [
    "Male",
    "Female",
    "Others",
  ];

  bool isHospitalFieldEnabled = false;

  String? selectedSex;

  Future<void> _loadCallingCode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _callingCode = prefs.getString('calling_code')!;

      print('Calling code: $_callingCode');
    });
  }

  void _loadDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _storedMobileNo = prefs.getString('mobile_no') ?? '';
      _storedCountryCode = prefs.getString('country_code') ?? '';
      // Print the loaded values
      print('Loaded Mobile No: $_storedMobileNo');
      print('Loaded Country Code: $_storedCountryCode');
    });
  }

  Future<TextEditingController> getFullName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullNameController.text = prefs.getString("full_name")!;
    print("Full Name: " + fullNameController.text);
    return fullNameController;
  }

  Future<TextEditingController> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString("email")!;
    print("Email Id: " + emailController.text);
    return emailController;
  }


  Future<TextEditingController> getCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    country.text = prefs.getString('selectedCountry')!;
    print("Country Name: " + country.text);
    return country;
  }

  Future<TextEditingController> getState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state.text = prefs.getString('selectedState')!;
    print("State Name: " + state.text);
    return state;
  }

  Future<TextEditingController> getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    city.text = prefs.getString('cityName')!;
    print("City Name: " +  city.text);
    return city;
  }

  Future<void> treatmentTypeData() async {
    setState(() {
      selectedHospitals.clear();
    });

    print("DATA CLEAR : $selectedHospitals");

    try {
      final response = await get(
        'doctor/treatment-list',
        headers: {'accept': '*/*'},
      );

      print('Response received: $response');

      final decodedResponse = json.decode(response);
      print('Decoded response: $decodedResponse');
      if (!mounted) return;
      setState(() {
        Treatment = (decodedResponse['details'] as List)
            .map((hospitalData) => TreatmentType.fromJson(hospitalData))
            .toList();
      });

      print('Treatment loaded successfully: $Treatment');
    } catch (error) {
      print('Failed to load treatmenttype : $error');
      // throw Exception('Failed to load hospitals: $error');
    }
  }

  Future<void> hospitalTypeData(String treatmentTypeId) async {
    try {
      setState(() {
        Hospital.clear(); // Clear existing hospitals
      });

      final response = await get(
        'doctor/hospital-list/$treatmentTypeId',
        headers: {'accept': '*/*'},
      );

      print('Response received: $response');

      final jsonResponse = jsonDecode(response);
      final errorCode = jsonResponse['errorCode'];

      if (errorCode == 200) {
        final details = jsonResponse['details'];
        print('Details: $details');

        if (details != null) {
          if (!mounted) return;
          setState(() {
            Hospital = (details as List)
                .map((hospitalData) => HospitalType.fromJson(hospitalData))
                .toList();
          });

          print('List after setState: $Hospital');
        } else {
          print('Details is null');
        }
      } else {
        // Handle error code
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }

  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future<void> DoctorInfoData(TabController tabController) async {
    // Check if any required field is empty
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        dateOfBirth.text.isEmpty ||
        country.text.isEmpty ||
        state.text.isEmpty ||
        city.text.isEmpty ||
        pinCode.text.isEmpty ||
        address.text.isEmpty ||
        experienceYear.text.isEmpty ||
        experienceDetails.text.isEmpty ||
        biograpgy.text.isEmpty ||
        doctorLicenseNumber.text.isEmpty ||
        regestrationNumber.text.isEmpty ||
        panCardAndSsn.text.isEmpty
    ) {
      showErrorAlert(context, "Please fill in all required fields.");
      return;
    }

    // Check if selectedData is empty
    if (selectedData.isEmpty) {
      showErrorAlert(context, "Please select at least one hospital.");
      return;
    }

    // // Check if experienceDetails has at least 10 letters
    // if (experienceDetails.text.replaceAll(RegExp(r'\s+'), '').length < 10) {
    //   showErrorAlert(context, "Please enter at least 10 letters in experience details.");
    //   return;
    // }
    //
    // // Check if biograpgy has at least 10 letters
    // if (biograpgy.text.replaceAll(RegExp(r'\s+'), '').length < 10) {
    //   showErrorAlert(context, "Please enter at least 10 letters in biography.");
    //   return;
    // }

    // Email regex pattern
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    // Date format pattern (MM/dd/yyyy)
    final DateFormat dateFormat = DateFormat('MM/dd/yyyy');

    if (!emailRegex.hasMatch(emailController.text)) {
      showErrorAlert(context, "Please enter a valid email address.");
      return;
    }

    try {
      dateFormat.parse(dateOfBirth.text);
    } catch (e) {
      showErrorAlert(context, "Please enter a valid date of birth in MM/dd/yyyy format.");
      return;
    }

    // Convert image to base64
    String base64Image = '';
    if (_image != null) {
      base64Image = await imageToBase64(_image!);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String endpoint = 'doctor/profile/update';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {
      "user_id": userId,
      "hospital": selectedData,
      "specialist": selectedTreatment,
      "others_hospital": otherHospital.text,
      "contact_person": contactPerson.text,
      "contact_number": contactNumber.text,
      "contact_email": contactEmail.text,
      "comment": contactComment.text,
      "name": fullNameController.text,
      "email_id": emailController.text,
      "date_of_birth": dateOfBirth.text,
      "gender": selectedSex,
      "country": country.text,
      "state": state.text,
      "city": city.text,
      "pin_code": pinCode.text,
      "address": address.text,
      "image": base64Image,
      "imgExt": "jpg",
      "experience": experienceYear.text,
      "website": website.text,
      "experience_details": '<p>${experienceDetails.text}</p>',
      "biography": '<p>${biograpgy.text}</p>',
      "doctor_license_number": doctorLicenseNumber.text,
      "registration_number": regestrationNumber.text,
      "pan_card": panCardAndSsn.text,


    };

    String body = jsonEncode(requestData);

    print('Request body ====: $body');
    try {
      var responseBody = await post(endpoint, headers: headers, body: body);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      print('Response body: $responseBody');
      String message = responseJson['message'] ?? 'Unknown error occurred';

      if (responseJson['errorCode'] == 200) {
        // Save the data locally
        prefs.setString('doctorInfo', body);
        print('Doctor info data saved locally: $body');

        setState(() {
          selectedData.clear();
          selectedTreatment = null;
          otherHospital.clear();
          fullNameController.clear();
          emailController.clear();
          dateOfBirth.clear();
          country.clear();
          state.clear();
          city.clear();
          pinCode.clear();
          address.clear();
          _image = null;
          experienceYear.clear();
          website.clear();
          experienceDetails.clear();
          biograpgy.clear();
          doctorLicenseNumber.clear();
          regestrationNumber.clear();
          selectedHospitals.clear();
          selectedSex = null;
        });

          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0,
          );

      } else if (responseJson['errorCode'] == 201) {
        showErrorAlert(context, message);
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
      showErrorAlert(context, "An error occurred: $e");
    }
  }

  Future<void> fetchDoctorInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Print request data
    print('Request Data:');
    print('URL: doctor/profile/details/$userId');
    print('Appointment ID: $userId');

    // Make the HTTP request
    final response = await get('doctor/profile/details/$userId');

    // Print response data
    print('Response Data:');
    print('Body: ${response}');

    // Decode JSON response
    final data = json.decode(response);

    // Check if the request was successful
    if (data['errorCode'] == 200) {
      var responseData = data['details'];
      var responseContactData = data['contactDetails'];

      setState(() async {

        fetchTreatmentType = responseData["specialist"]["category"];
        print(fetchTreatmentType);
        selectedTreatment = Treatment.firstWhere(
                (treatment) => treatment.name == fetchTreatmentType).id;

        // Fetch the hospitals related to the doctor
        selectedHospitals.clear();
        selectedData.clear();
        for (var hospital in responseData["hospital"]) {
          var hospitalType = HospitalType(
            id: hospital["hospital"],
            name: hospital["hospital_name"],
          );
          selectedHospitals.add(hospitalType);
          selectedData.add({
            'hospital': hospitalType.id,
            'hospital_name': hospitalType.name,
          });
        }

        fetchGenderType = responseData["gender"];
        print(fetchGenderType);
        selectedSex = sex.firstWhere((gender) => gender == fetchGenderType);

        imagePath = responseData["image"];
        if (imagePath != null && imagePath!.isNotEmpty) {
          imageUrl = '$imageUrlBase/$imagePath';
        } else {
          print('No image URL provided.');
        }

        fullNameController.text = responseData["name"];
        emailController.text = responseData["email_id"];
        dateOfBirth.text = responseData["date_of_birth"];
        doctorLicenseNumber.text = responseData["doctor_license_number"];
        regestrationNumber.text = responseData["registration_number"];
        experienceYear.text = responseData["experience"];
        website.text = responseData["website"];
        country.text = responseData["country"];
        state.text = responseData["state"];
        city.text = responseData["city"];
        address.text = responseData["address"];
        pinCode.text = responseData["pin_code"];
        experienceDetails.text = responseData["experience_details"];
        biograpgy.text = responseData["biography"];
        panCardAndSsn.text = responseData["pan_card"];
        print("Pan=============${panCardAndSsn.text}");

        otherHospital.text = responseContactData["contact_person"];
        contactPerson.text = responseContactData["contact_number"];
        contactNumber.text = responseContactData["contact_email"];
        contactEmail.text = responseContactData["others_hospital"];
        contactComment.text = responseContactData["comment"];

      });

      if (selectedTreatment != null) {
        await hospitalTypeData(selectedTreatment!);
      }
    } else {
      throw Exception(
          'Failed to load patient information: ${data['errorMessage']}');
    }
  }

  // for Qualification

  final _formKey = GlobalKey<FormState>();
  final List<Qualification> _qualifications = [];

  final TextEditingController _qualificationNameController = TextEditingController();
  final TextEditingController _instituteNameController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();

  void _addQualification() {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _qualifications.add(Qualification(
          qualificationName: _qualificationNameController.text,
          instituteName: _instituteNameController.text,
          startYear: _startYearController.text,
          endYear: _endYearController.text,
          percentage: _percentageController.text,
          totalMarks: _totalMarksController.text,
        ));

        _qualificationNameController.clear();
        _instituteNameController.clear();
        _startYearController.clear();
        _endYearController.clear();
        _percentageController.clear();
        _totalMarksController.clear();
      });
    }
  }

  void _editQualification(int index) {
    final qualification = _qualifications[index];
    _qualificationNameController.text = qualification.qualificationName;
    _instituteNameController.text = qualification.instituteName;
    _startYearController.text = qualification.startYear;
    _endYearController.text = qualification.endYear;
    _percentageController.text = qualification.percentage;
    _totalMarksController.text = qualification.totalMarks;
    if (!mounted) return;
    setState(() {
      _qualifications.removeAt(index);
    });
  }

  void _deleteQualification(int index) {
    if (!mounted) return;
    setState(() {
      _qualifications.removeAt(index);
    });
  }

  Future<void> DoctorQualification() async {
    List<Map<String, String>> qualificationDataBody =
    _qualifications.map((qualification) => qualification.toMap()).toList();

    if (qualificationDataBody.isEmpty) {
      showErrorAlert(context, "Please click Add More button.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String endpoint = 'doctor/education/update';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {
      "user_id": userId,
      "education": qualificationDataBody,
    };

    String body = jsonEncode(requestData);

    print('Request body: $body');

    try {
      var responseBody = await post(endpoint, headers: headers, body: body);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      print('Response body: $responseBody');
      String message = responseJson['message'] ?? 'Unknown error occurred';

      if (responseJson['errorCode'] == 200) {
        showSuccessWithoutNavigateAlert(context, message);
      } else if (responseJson['errorCode'] == 201) {
        showErrorAlert(context, message,);
      }
    } catch (e) {
      print('Error: $e');
      showErrorAlert(context, "An error occurred: $e");
    }
  }

  Future<void> fetchQualificationInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Print request data
    print('Request Data:');
    print('URL: doctor/education/details/$userId');
    print('Appointment ID: $userId');

    // Make the HTTP request
    final response = await get('doctor/education/details/$userId');

    // Print response data
    print('Response Data:');
    print('Body: ${response}');

    // Decode JSON response
    final data = json.decode(response);

    // Check if the request was successful
    if (data['errorCode'] == 200) {
      var responseData = data['details']["education"];
      setState(() {
        _qualifications.clear();

        // Populate qualifications list
        for (var education in responseData) {
          Qualification qualification = Qualification.fromJson(education);
          _qualifications.add(qualification);
        }
      });

      if (selectedTreatment != null) {
        await hospitalTypeData(selectedTreatment!);
      }
    } else {
      throw Exception(
          'Failed to load patient information: ${data['errorMessage']}');
    }
  }

  // for Hospital Affiliation

  final _formKeyHospitalAffiliation = GlobalKey<FormState>();
  final List<HospitalAffiliation> _hospitalAffiliations = [];

  final TextEditingController _hospitalAffiliationNameController = TextEditingController();
  final TextEditingController _cityAffiliationController = TextEditingController();
  final TextEditingController _countryAffiliationController = TextEditingController();
  final TextEditingController _startDateAffiliationController = TextEditingController();
  final TextEditingController _endDateAffiliationController = TextEditingController();
  final TextEditingController _totalExperienceAffiliationController = TextEditingController();

  void _addHospitalAffiliation() {
    final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
    try {
      dateFormat.parse(_startDateAffiliationController.text);
      dateFormat.parse(_endDateAffiliationController.text);
    } catch (e) {
      showErrorAlert(
          context, "Please enter a valid date of birth in MM/dd/yyyy format.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _hospitalAffiliations.add(HospitalAffiliation(
          hospitalAffiliationName: _hospitalAffiliationNameController.text,
          cityAffiliationName: _cityAffiliationController.text,
          countryAffiliation: _countryAffiliationController.text,
          startAffiliationDate: _startDateAffiliationController.text,
          endAffiliationDate: _endDateAffiliationController.text,
          totalAffiliationExperience:
          _totalExperienceAffiliationController.text,
        ));

        _hospitalAffiliationNameController.clear();
        _cityAffiliationController.clear();
        _countryAffiliationController.clear();
        _startDateAffiliationController.clear();
        _endDateAffiliationController.clear();
        _totalExperienceAffiliationController.clear();
      });
    }
  }

  void _editHospitalAffiliation(int index) {
    final hospitalAffiliation = _hospitalAffiliations[index];
    _hospitalAffiliationNameController.text =
        hospitalAffiliation.hospitalAffiliationName;
    _cityAffiliationController.text = hospitalAffiliation.cityAffiliationName;
    _countryAffiliationController.text = hospitalAffiliation.countryAffiliation;
    _startDateAffiliationController.text =
        hospitalAffiliation.startAffiliationDate;
    _endDateAffiliationController.text = hospitalAffiliation.endAffiliationDate;
    _totalExperienceAffiliationController.text =
        hospitalAffiliation.totalAffiliationExperience;
    if (!mounted) return;
    setState(() {
      _hospitalAffiliations.removeAt(index);
    });
  }

  void _deleteHospitalAffiliation(int index) {
    if (!mounted) return;
    setState(() {
      _hospitalAffiliations.removeAt(index);
    });
  }

  Future<void> DoctorHospitalAffiliation() async {
    List<Map<String, String>> hospitalAffiliationBodyData =
    _hospitalAffiliations
        .map((affiliation) => affiliation.toMap())
        .toList();

    if (hospitalAffiliationBodyData.isEmpty) {
      showErrorAlert(context, "Please click Add More button.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';
    String endpoint = 'doctor/hospital-affiliation/update';

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final requestData = {
      "user_id": userId,
      "doctor_work": hospitalAffiliationBodyData,
    };

    String body = jsonEncode(requestData);

    print('Request body: $body');

    try {
      var responseBody = await post(endpoint, headers: headers, body: body);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      print('Response body: $responseBody');
      String message = responseJson['message'] ?? 'Unknown error occurred';

      if (responseJson['errorCode'] == 200) {
        showSuccessWithoutNavigateAlert(context, message);
      } else if (responseJson['errorCode'] == 201) {
        showErrorAlert(context, message);
      }
    } catch (e) {
      print('Error: $e');
      showErrorAlert(context, "An error occurred: $e");
    }
  }

  Future<void> fetchHospitalAffiliation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Print request data
    print('Request Data:');
    print('URL: doctor/hospital-affiliation/details/$userId');
    print('Appointment ID: $userId');

    // Make the HTTP request
    final response = await get('doctor/hospital-affiliation/details/$userId');

    // Print response data
    print('Response Data:');
    print('Body: ${response}');

    // Decode JSON response
    final data = json.decode(response);

    // Check if the request was successful
    if (data['errorCode'] == 200) {
      var responseData = data['details']["doctor_work"];
      setState(() {
        _hospitalAffiliations.clear();

        // Populate qualifications list
        for (var affiliation in responseData) {
          HospitalAffiliation hospitalAffi =
          HospitalAffiliation.fromJson(affiliation);
          _hospitalAffiliations.add(hospitalAffi);
        }
      });

      if (selectedTreatment != null) {
        await hospitalTypeData(selectedTreatment!);
      }
    } else {
      throw Exception(
          'Failed to load patient information: ${data['errorMessage']}');
    }
  }


  void showSuccessWithoutNavigateAlert(BuildContext context, String message)  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text(" $message"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorHomePage(),));
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool oennother = false;

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
        print('Treatments11111$Treatment');
      });
      print('Treatment loaded successfully: $Treatment');
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
                name: subTreatment['sub_treatment_id']['sub_category'] ??
                    'Unknown',
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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentStep = _tabController.index;
      });
    });

    _loadDataFromPreferences();
    _loadCallingCode();
    getFullName();
    getEmail();
    getCountry();
    getState();
    getCity();
    fetchDoctorInfo();
    treatmentTypeData();

    fetchQualificationInfo();
    fetchHospitalAffiliation();

    treatmentCategory();
    fetchTreatmentSubCategorySubmitData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOthersSelected =
    selectedHospitals.any((hospital) => hospital.name == 'others');
    return Scaffold(
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
                            "Doctor Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                          ],
                        )
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
                                    controller: _tabController,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height:
                                MediaQuery.of(context).size.height * 0.80,
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    SingleChildScrollView(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 80.0,
                                                    backgroundImage:
                                                    imageUrl != null
                                                        ? NetworkImage(
                                                        imageUrl!)
                                                        : null,
                                                    child: imageUrl == null
                                                        ? Icon(Icons.person,
                                                        size: 30.0)
                                                        : null,
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    bottom: 0,
                                                    child: CircleAvatar(
                                                      radius:
                                                      20.0, // Adjust radius as needed for the size of the edit button
                                                      backgroundColor:
                                                      Colors.white,
                                                      child: IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: Colors
                                                                .black), // Adjust icon color
                                                        onPressed: getImage,
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),

                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                SizedBox(
                                                    height:
                                                    10.0), // Use height instead of width for spacing
                                                Text(
                                                  _image == null
                                                      ? ''
                                                      : _image!.path,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration: InputDecoration(
                                                  labelText: 'Specialist',
                                                  hintText: 'Select Specialist',
                                                  hintStyle: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black54,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 14.0,
                                                    horizontal: 16.0,
                                                  ),
                                                ),
                                                value: selectedTreatment,
                                                items: Treatment.map(
                                                        (TreatmentType treatment) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: treatment.id,
                                                        child: Text(treatment.name),
                                                      );
                                                    }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    selectedTreatment =
                                                        newValue;
                                                    selectedHospitals
                                                        .clear(); // Clear selected hospitals
                                                    selectedData
                                                        .clear(); // Clear selected data
                                                    oennother = true;
                                                    if (newValue != null) {
                                                      hospitalTypeData(
                                                          newValue); // Fetch new hospitals for the selected treatment
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            if (selectedTreatment != null)
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 1.0),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      5.0),
                                                ),
                                                child: Column(
                                                  children: [
                                                    MultiSelectDialogField<
                                                        HospitalType>(
                                                      items: Hospital.map(
                                                              (hospital) =>
                                                              MultiSelectItem<
                                                                  HospitalType>(
                                                                hospital,
                                                                hospital.name,
                                                              )).toList(),
                                                      // initialValue:
                                                      // selectedHospitals, // Set the initial value here
                                                      initialValue: [], // Set the initial value here
                                                      title: Text('Hospital'),
                                                      buttonIcon: Icon(Icons
                                                          .arrow_drop_down),
                                                      buttonText: Text(
                                                          'Select Hospital'),
                                                      onConfirm: (results) {
                                                        setState(() {
                                                          selectedHospitals
                                                              .clear();
                                                          selectedData.clear();
                                                          selectedHospitals
                                                              .addAll(results);
                                                          selectedData =
                                                              selectedHospitals
                                                                  .map(
                                                                      (hospital) =>
                                                                  {
                                                                    'hospital':
                                                                    hospital.id,
                                                                    'hospital_name':
                                                                    hospital.name
                                                                  })
                                                                  .toList();
                                                          print(
                                                              "selectedData: $selectedData");
                                                        });
                                                      },
                                                      chipDisplay:
                                                      MultiSelectChipDisplay(
                                                        items: selectedHospitals
                                                            .map((hospital) =>
                                                            MultiSelectItem<
                                                                HospitalType>(
                                                              hospital,
                                                              hospital.name,
                                                            ))
                                                            .toList(),
                                                        onTap: (hospital) {
                                                          setState(() {
                                                            selectedHospitals
                                                                .remove(
                                                                hospital);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    if (isOthersSelected)
                                                      Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Container(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                otherHospital,
                                                                decoration:
                                                                InputDecoration(
                                                                  labelText:
                                                                  'Add Hospital',
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                ),
                                                                onSubmitted:
                                                                    (value) {
                                                                  if (value
                                                                      .isNotEmpty) {
                                                                    setState(
                                                                            () {
                                                                          final newHospital =
                                                                          HospitalType(
                                                                            id: (Hospital.length +
                                                                                1)
                                                                                .toString(),
                                                                            name:
                                                                            value,
                                                                          );
                                                                          Hospital.add(
                                                                              newHospital);
                                                                          selectedHospitals
                                                                              .add(
                                                                              newHospital);
                                                                          selectedData
                                                                              .add({
                                                                            'hospital':
                                                                            newHospital.id,
                                                                            'hospital_name':
                                                                            newHospital.name,
                                                                          });
                                                                          otherHospital
                                                                              .clear();
                                                                          print(
                                                                              "selectedData: $selectedData");
                                                                        });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Container(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                contactPerson,
                                                                decoration:
                                                                InputDecoration(
                                                                  labelText:
                                                                  'Contact Person',
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Container(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                contactNumber,
                                                                decoration:
                                                                InputDecoration(
                                                                  labelText:
                                                                  'Contact Number',
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Container(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                contactEmail,
                                                                decoration:
                                                                InputDecoration(
                                                                  labelText:
                                                                  'Contact Email',
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Container(
                                                              height: 50,
                                                              child: TextField(
                                                                controller:
                                                                contactComment,
                                                                decoration:
                                                                InputDecoration(
                                                                  labelText:
                                                                  'Comments',
                                                                  border:
                                                                  OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: fullNameController,
                                                decoration: InputDecoration(
                                                  labelText: 'Full Name',
                                                  hintText: 'Dr.Abhi',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: emailController,
                                                decoration: InputDecoration(
                                                  labelText: 'Email Id',
                                                  hintText: 'abc@gmail.com',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 58,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                                border: Border.all(
                                                    color: Colors
                                                        .grey), // Example border style
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16.0,
                                                        horizontal: 16.0),
                                                    child: Text(
                                                      '+$_storedCountryCode $_storedMobileNo',
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: dateOfBirth,
                                                decoration: InputDecoration(
                                                  labelText: 'Date Of Birth',
                                                  hintText: '01/03/1990',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  decoration: InputDecoration(
                                                    labelText: 'Gender',
                                                    hintText: 'M/F',
                                                    hintStyle: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black54,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  value: selectedSex,
                                                  items: sex.map((String status) {
                                                    return DropdownMenuItem<String>(
                                                      value: status,
                                                      child: Text(status),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedSex = newValue;
                                                    });
                                                  },
                                                )),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: doctorLicenseNumber,
                                                decoration: InputDecoration(
                                                  labelText:
                                                  'Doctor License Number',
                                                  hintText: 'CX674478Qe',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: regestrationNumber,
                                                decoration: InputDecoration(
                                                  labelText:
                                                  'Regestration Number',
                                                  hintText: 'CX674478Qe',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: experienceYear,
                                                keyboardType:
                                                TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Experience Years',
                                                  hintText: '10 Years',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            Container(
                                              child: TextField(
                                                controller: panCardAndSsn,
                                                decoration: InputDecoration(
                                                  labelText: 'Company Pan Card/EIN',
                                                  hintText: 'ABCTY1234D/12-3456789',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 10,),

                                            Container(
                                              child: TextField(
                                                controller: website,
                                                decoration: InputDecoration(
                                                  labelText: 'Website',
                                                  hintText:
                                                  'Enter website link',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: country,
                                                decoration: InputDecoration(
                                                  labelText: 'Country',
                                                  hintText: 'India',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: state,
                                                decoration: InputDecoration(
                                                  labelText: 'State',
                                                  hintText: 'West Bengal',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: city,
                                                decoration: InputDecoration(
                                                  labelText: 'City',
                                                  hintText: 'Kolkata',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: address,
                                                decoration: InputDecoration(
                                                  labelText: 'Addess',
                                                  hintText: '51,south kolkata',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: pinCode,
                                                keyboardType:
                                                TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Pin Code',
                                                  hintText: '841198',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: experienceDetails,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  labelText:
                                                  'Experience Deatails',
                                                  hintText: 'Type here...',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: TextField(
                                                controller: biograpgy,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  labelText: 'Biography',
                                                  hintText: 'Type here...',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  DoctorInfoData(tabController);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: bgColor,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 13.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 130,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _qualificationNameController,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                    'Qualification Name',
                                                    hintText: 'MBBS',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter hospitalAffi name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _instituteNameController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Institute Name',
                                                    hintText: 'AIIMS',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter institute name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _startYearController,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Start Year',
                                                    hintText: '2015',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter start year';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _endYearController,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'End Year',
                                                    hintText: '2020',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter end year';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _percentageController,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Percentage',
                                                    hintText:
                                                    'Enter marks percentage',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter percentage';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: TextFormField(
                                                  controller:
                                                  _totalMarksController,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Total Marks',
                                                    hintText: 'Enter marks',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Colors.black54),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter total marks';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed:
                                                      _addQualification,
                                                      child: Text(
                                                        "Add More",
                                                        style: TextStyle(
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: Card(
                                                  color: Colors
                                                      .yellowAccent, // Set the card color to yellow accent
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .all(
                                                        8.0), // Add padding inside the card
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          child: Icon(
                                                            Icons.info_outline,
                                                            size: 18,
                                                          ), // Use Icon widget for the icon
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            "Note : ",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          // Use Expanded to avoid overflow issues
                                                          child: Container(
                                                            child: Text(
                                                              "Fill profile, click Add More to verify, then click Submit. Without this, data won't update.",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                _qualifications.length,
                                                itemBuilder: (context, index) {
                                                  final qualification =
                                                  _qualifications[index];
                                                  return Card(
                                                    child: ListTile(
                                                      title: Text(qualification
                                                          .qualificationName),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              'Institute: ${qualification.instituteName}'),
                                                          Text(
                                                              'Years: ${qualification.startYear} - ${qualification.endYear}'),
                                                          Text(
                                                              'Percentage: ${qualification.percentage}'),
                                                          Text(
                                                              'Total Marks: ${qualification.totalMarks}'),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () =>
                                                                _editQualification(
                                                                    index),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () =>
                                                                _deleteQualification(
                                                                    index),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed:
                                                  DoctorQualification,
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                    Colors.white,
                                                    backgroundColor: bgColor,
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 13.0),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Update',
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 130,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _hospitalAffiliationNameController,
                                                decoration: InputDecoration(
                                                  labelText: 'Hospital Name',
                                                  hintText: 'Kolkata AIIMS',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter hospital name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _cityAffiliationController,
                                                decoration: InputDecoration(
                                                  labelText: 'City',
                                                  hintText: 'Kolkata',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter city';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _countryAffiliationController,
                                                decoration: InputDecoration(
                                                  labelText: 'Country',
                                                  hintText: 'India',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter country';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _startDateAffiliationController,
                                                decoration: InputDecoration(
                                                  labelText: 'Start Year',
                                                  hintText: '20/04/2019',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter start date';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _endDateAffiliationController,
                                                decoration: InputDecoration(
                                                  labelText: 'End Date',
                                                  hintText: '07/04/2021',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter end date';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller:
                                                _totalExperienceAffiliationController,
                                                keyboardType:
                                                TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Total Experience',
                                                  hintText: '3 Years',
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0),
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 16.0),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter total experience';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed:
                                                    _addHospitalAffiliation,
                                                    child: Text(
                                                      "Add More",
                                                      style: TextStyle(
                                                          decoration:
                                                          TextDecoration
                                                              .underline),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: Card(
                                                  color: Colors
                                                      .yellowAccent, // Set the card color to yellow accent
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .all(
                                                        8.0), // Add padding inside the card
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          child: Icon(
                                                            Icons.info_outline,
                                                            size: 18,
                                                          ), // Use Icon widget for the icon
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            "Note : ",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          // Use Expanded to avoid overflow issues
                                                          child: Container(
                                                            child: Text(
                                                              "Fill profile, click Add More to verify, then click Submit. Without this, data won't update.",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _hospitalAffiliations
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  final affiliation =
                                                  _hospitalAffiliations[
                                                  index];
                                                  return Card(
                                                    child: ListTile(
                                                      title: Text(affiliation
                                                          .hospitalAffiliationName),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              'City: ${affiliation.cityAffiliationName}'),
                                                          Text(
                                                              'Country: ${affiliation.countryAffiliation}'),
                                                          Text(
                                                              'Period: ${affiliation.startAffiliationDate} - ${affiliation.endAffiliationDate}'),
                                                          Text(
                                                              'Experience: ${affiliation.totalAffiliationExperience}'),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () =>
                                                                _editHospitalAffiliation(
                                                                    index),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () =>
                                                                _deleteHospitalAffiliation(
                                                                    index),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    DoctorHospitalAffiliation();
                                                  },
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                    Colors.white,
                                                    backgroundColor: bgColor,
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 13.0),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Update',
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 130,
                                              ),                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
                                                      selectedCategory =
                                                          category.id;
                                                      showSubCategoryList =
                                                      true;
                                                      print(
                                                          "selectedCategory:$selectedCategory");
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
      bottomNavigationBar:Container(
        child: SizedBox(
          height: 80, // Adjust the height as needed
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: currentStep,
            onStepTapped: (step) {
              setState(() {
                currentStep = step;
                _tabController.index = step; // Update tab based on step
              });
            },
            onStepContinue: () {
              if (currentStep < 3) {
                setState(() {
                  currentStep++;
                  _tabController.index = currentStep; // Update tab based on step
                });
              }
            },
            onStepCancel: () {
              if (currentStep > 0) {
                setState(() {
                  currentStep--;
                  _tabController.index = currentStep; // Update tab based on step
                });
              }
            },
            steps: [
              Step(
                title: Text(''),
                content: Container(), // Add your content here
                isActive: currentStep >= 0,
                state: currentStep == 0 ? StepState.editing : StepState.indexed,
              ),
              Step(
                title: Text(''),
                content: Container(), // Add your content here
                isActive: currentStep >= 1,
                state: currentStep == 1 ? StepState.editing : StepState.indexed,
              ),
              Step(
                title: Text(''),
                content: Container(), // Add your content here
                isActive: currentStep >= 2,
                state: currentStep == 2 ? StepState.editing : StepState.indexed,
              ),
              Step(
                title: Text(''),
                content: Container(), // Add your content here
                isActive: currentStep >= 3,
                state: currentStep == 3 ? StepState.editing : StepState.indexed,
              ),

            ],
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Container(
                height: 50,
                width: 50,
              ); // Hide default controls
            },
            elevation: 0, // Default value is 0, can adjust if needed
          ),
        ),
      ),

    );
  }
}

class Qualification {
  String qualificationName;
  String instituteName;
  String startYear;
  String endYear;
  String percentage;
  String totalMarks;

  Qualification({
    required this.qualificationName,
    required this.instituteName,
    required this.startYear,
    required this.endYear,
    required this.percentage,
    required this.totalMarks,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      qualificationName: json['degree_name'],
      instituteName: json['institute_name'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      percentage: json['percentage'],
      totalMarks: json['total_marks'],
    );
  }

  Map<String, String> toMap() {
    return {
      'degree_name': qualificationName,
      'institute_name': instituteName,
      'start_year': startYear,
      'end_year': endYear,
      'percentage': percentage,
      'total_marks': totalMarks,
    };
  }
}

class HospitalAffiliation {
  String hospitalAffiliationName;
  String cityAffiliationName;
  String countryAffiliation;
  String startAffiliationDate;
  String endAffiliationDate;
  String totalAffiliationExperience;

  HospitalAffiliation({
    required this.hospitalAffiliationName,
    required this.cityAffiliationName,
    required this.countryAffiliation,
    required this.startAffiliationDate,
    required this.endAffiliationDate,
    required this.totalAffiliationExperience,
  });

  factory HospitalAffiliation.fromJson(Map<String, dynamic> json) {
    return HospitalAffiliation(
      hospitalAffiliationName: json['hospital_name'],
      cityAffiliationName: json['city_name'],
      countryAffiliation: json['country_name'],
      startAffiliationDate: json['start_date'],
      endAffiliationDate: json['end_date'],
      totalAffiliationExperience: json['total_experience'],
    );
  }

  Map<String, String> toMap() {
    return {
      "hospital_name": hospitalAffiliationName,
      "city_name": cityAffiliationName,
      "country_name": countryAffiliation,
      "start_date": startAffiliationDate,
      "end_date": endAffiliationDate,
      "total_experience": totalAffiliationExperience
    };
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

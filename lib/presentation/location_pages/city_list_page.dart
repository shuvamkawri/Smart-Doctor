import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/doctor_dashboard/tabbar_pages/doctor_info_profile_page.dart';

class CityListPage extends StatefulWidget {
  final String? isoCode;
  final String? countryCode;
  const CityListPage({super.key, this.isoCode, this.countryCode});

  @override
  State<CityListPage> createState() => _CityListPageState();
}

class _CityListPageState extends State<CityListPage> {
  List<Map<String, String>> cityList = [];
  List<Map<String, String>> filteredCityList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCityList();
  }

  Future<void> fetchCityList() async {
    String endpoint = 'user/UserCityList';
    print('Starting the fetchCityList function');

    final requestData = json.encode(
        {'country_code': widget.countryCode, 'state_code': widget.isoCode});

    Map<String, String> headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    var response = await post(endpoint, headers: headers, body: requestData);

    print('Request Body: $response');

    final data = json.decode(response);

    if (data['errorCod'] == 200) {
      final List<dynamic> dynamicCityList = data['city_list'];

      final List<Map<String, String>> convertedCityList = dynamicCityList
          .map((dynamic item) =>
              Map<String, String>.from(item as Map<String, dynamic>))
          .toList();

      setState(() {
        cityList = filteredCityList = convertedCityList;
      });
    } else {
      print('Error code is not 200');
    }
  }

  void filterCityList(String query) {
    setState(() {
      filteredCityList = cityList.where((city) {
        return city['name']!.contains(query);
      }).toList();
    });
  }

  void navigateToHospitalDashboardPage(String cityName) async {
    // Save the selected city name to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cityName', cityName);
    print('Selected City: $cityName');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(),
      ),
    );
  }

  Future<void> fetchCityListSave(String selectedCity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      String? country = prefs.getString('selectedCountry');
      String? state = prefs.getString('selectedState');
      String? city = prefs.getString('cityName');

      String endpoint = 'user/country-state-City-save';
      print('Starting the fetchCityList function');

      final requestData = json.encode({
        "user_id": userId,
        "country_name": country,
        "state_name": state,
        "city_name": city
      });

      print('request body$requestData');

      Map<String, String> headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
      };

      var response = await post(endpoint, headers: headers, body: requestData);

      print('Request Body: $response');

      final data = json.decode(response);

      if (data['errorCod'] == 200) {
        print(data['message']);
        // Perform any additional actions you need based on the response
        // For example, you could update the state to reflect the successful update
        // setState(() {
        //   // Update your state if needed
        // });
      } else {
        print('Error code is not 200');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            SizedBox(
              width: 40,
            ),
            Text(
              "City List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        leading: Container(
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
      ),
      backgroundColor: lightWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              "Search City",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 55,
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterCityList(query);
              },
              decoration: InputDecoration(
                hintText: 'First letter should be capital',
                hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: ListView.builder(
                itemCount: filteredCityList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      // Handle city selection here
                      final selectedCity = filteredCityList[index]['name'];
                      navigateToHospitalDashboardPage(selectedCity!);
                      await fetchCityListSave(selectedCity);
                    },
                    child: Card(
                      // color: bgColor,
                      child: ListTile(
                        title: Text(
                          filteredCityList[index]['name'] ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          filteredCityList[index]['stateCode']!,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Text(
                          filteredCityList[index]['countryCode']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> getSelectedCity() async {
  final prefs = await SharedPreferences.getInstance();
  final selectedCity = prefs.getString('cityName') ?? '';
  print('Selected City: $selectedCity');
  return selectedCity;
}

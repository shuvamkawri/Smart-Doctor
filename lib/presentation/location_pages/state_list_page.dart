import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';
import 'city_list_page.dart';

class StateListPage extends StatefulWidget {
  final String selectedCountry;
  final String countryName;
  const StateListPage(
      {super.key, required this.selectedCountry, required this.countryName});

  @override
  State<StateListPage> createState() => _StateListPageState();
}

class _StateListPageState extends State<StateListPage> {
  List<Map<String, String>> stateList = [];
  String? selectedState;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchStateList();
  }

  Future<void> fetchStateList() async {
    String endpoint = 'user/UserStateList';

    final selectedCountry = widget.selectedCountry;

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? userId = prefs.getString('user_id');

    Map<String, String> headers = {
      'accept': '*',
      'Content-Type': 'application/json',
    };

    final requestData = jsonEncode({
      "country_name": selectedCountry,
      // "user_id": userId,
    });

    print('request data$requestData');

    var response = await post(endpoint, headers: headers, body: requestData);
    print(response);

    final Map<String, dynamic> data = json.decode(response);

    if (data['errorCode'] == 200) {
      final List<dynamic> dynamicStateList = data['state_list'];

      final List<Map<String, String>> convertedStateList = dynamicStateList
          .map((dynamic item) =>
              Map<String, String>.from(item as Map<String, dynamic>))
          .toList();

      setState(() {
        stateList = convertedStateList;
      });
    } else {
      // Handle the error
    }
  }

  void navigateToCityPage(String? state) async {
    final selectedState = stateList.firstWhere(
      (element) => element['name'] == state,
      orElse: () => {'isoCode': '', 'countryCode': ''},
    );
    final isoCode = selectedState['isoCode'];
    final countryCode = selectedState['countryCode'];

    if (isoCode!.isNotEmpty) {
      // Save selected state to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedState', state!);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CityListPage(isoCode: isoCode, countryCode: countryCode),
        ),
      );
    } else {
      print('Invalid isoCode for state: $state');
    }
  }

  List<Map<String, String>> _filteredStateList() {
    if (searchText.isEmpty) {
      return stateList;
    } else {
      return stateList.where((state) {
        final stateName = state['name'];
        return stateName?.contains(searchText!) ?? false;
      }).toList();
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
              "State List",
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
              "Search State",
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
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
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
                itemCount: _filteredStateList().length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      final selectedState = _filteredStateList()[index]['name'];
                      navigateToCityPage(selectedState);
                    },
                    child: Card(
                      // color: bgColor,
                      child: ListTile(
                        // contentPadding: EdgeInsets.all(16),
                        title: Text(
                          _filteredStateList()[index]['name']!,
                          style: TextStyle(fontSize: 16),
                        ),

                        subtitle: Text(
                          _filteredStateList()[index]['isoCode']!,
                          style: TextStyle(fontSize: 16),
                        ),

                        trailing: Text(
                          _filteredStateList()[index]['countryCode']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),

                        onTap: () {
                          final selectedState =
                              _filteredStateList()[index]['name'];
                          navigateToCityPage(selectedState);
                        },
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

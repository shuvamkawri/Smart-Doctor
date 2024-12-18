import 'dart:convert';

import 'package:ai_medi_doctor/presentation/location_pages/state_list_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/colors.dart';
import '../../domain/common_fuction_api.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  State<CountryListPage> createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<dynamic> countries = [];
  String selectedCountry = '';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    loadSelectedCountry();
  }

  Future<void> fetchData() async {
    String endpoint = 'user/UserCountryList';

    Map<String, String> headers = {
      'accept': '*'
    };

    var response = await post(endpoint, headers: headers, body: '');
    print(response);

    final Map<String, dynamic> data = json.decode(response);
    final int errorCod = data['errorCod'];
    if (errorCod == 200) {
      setState(() {
        countries = data['Country_list'];
        print(countries);
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _onCountrySelected(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', countryName);

    final storedCountry = prefs.getString('selectedCountry');

    if (storedCountry != null) {
      print('Stored selected country: $storedCountry');

      // Pass the selectedCountry and countryName to LocationPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StateListPage(
            selectedCountry: selectedCountry,
            countryName: countryName,
          ),
        ),
      );
    } else {
      print('Failed to retrieve selected country from SharedPreferences');
    }

    setState(() {
      selectedCountry = countryName;
    });
  }

  Future<void> loadSelectedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCountry = prefs.getString('selectedCountry');
    if (storedCountry != null) {
      setState(() {
        selectedCountry = storedCountry;
      });
    }
  }

  List<dynamic> _filteredCountries() {
    if (searchText.isEmpty) {
      return countries;
    } else {
      return countries.where((country) {
        final countryName = country['name'];
        final isoCode = country['isoCode'];
        final phonecode = country['phonecode'];
        return countryName.contains(searchText) || isoCode.contains(searchText)||phonecode.contains(searchText);
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
              "Country List",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w500),
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

      ),
      backgroundColor: lightWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 9,
          ),

          Container(margin:EdgeInsets.only(left: 10) ,child: Text("Search Country",style: TextStyle(color: Colors.black54),),),
          SizedBox(height: 5,),

          Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'First letter should be capital',
                  hintStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10,right: 10),
              child: ListView.builder(
                itemCount: _filteredCountries().length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries()[index];
                  return Card(
                    // color: bgColor,
                    child: ListTile(
                      title: Text(country['name'],),
                      subtitle: Text(country['isoCode']),
                      trailing: Text(country['phonecode'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13),),
                      onTap: () {
                        _onCountrySelected(country['name']);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Selected country : ',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black54 ),),
                  Text('$selectedCountry')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

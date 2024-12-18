
import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/text_style.dart';
import '../location_pages/country_list_page.dart';

class CongratsPage extends StatefulWidget {
  const CongratsPage({super.key});

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

class _CongratsPageState extends State<CongratsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: lightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/doctor_splash.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text(
                    'Congrats!',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: regular,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: Text(
                    'Welcome to AISmartdoctor',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: regular,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 150,
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              child: ElevatedButton(
                // onPressed: _completeRegistration,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountryListPage(),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Go Through Location ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../consts/text_style.dart';
import '../landing_page_screen/landing_page_first.dart';


class SplashScreenPage extends StatelessWidget {
  void navigateToScreen1(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LandingPageFirst(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyanAccent,

      body: Center(
        child: GestureDetector(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      'AISmartdoctor',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: regular,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => navigateToScreen1(context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: 
                  Image.asset(
                    'assets/images/next_icon_white.png',
                    width: 58,
                    height: 58,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}





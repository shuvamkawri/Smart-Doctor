import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../consts/colors.dart';
import '../authentication/login_page.dart';
import '../authentication/registration.dart';
import '../dashboard/dashboard_screen.dart';
import '../landing_page_screen/landing_page_first.dart';

class get_started_page extends StatefulWidget {
  @override
  _get_started_pageState createState() => _get_started_pageState();
}

class _get_started_pageState extends State<get_started_page> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // If user swipes from left to right (backward)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    LandingPageFirst()), // Navigate to Screen3
          );
        }
      },
      child: Scaffold(
        backgroundColor: lightBlue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.250),
                width: screenWidth * 0.5, // Responsive width
                height: screenHeight * 0.1, // Responsive height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/doctor_splash.png'), // Set the image path
                    fit: BoxFit.contain, // Cover the entire container
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "AISmartdoctor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: bgColor),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Container(
                child: Text(
                  "Let's get started! ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                width: screenWidth * 0.8,
                child: Text(
                  "Login to enjoy the features we've provided , and stay safe!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 80,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      color: bgColor,
                      elevation: 5,
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage(planName: '',)),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(screenHeight * 0.02),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(
                    //     horizontal: screenWidth * 0.04,
                    //     vertical: screenHeight * 0.02,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(
                    //         10), // Adjust the radius as needed
                    //     border: Border.all(
                    //         color: Colors.black,
                    //         width: 1), // Define border properties
                    //   ),
                    //   child: Material(
                    //     borderRadius: BorderRadius.circular(
                    //         10), // Match the outer container's border radius
                    //     color: Colors.transparent,
                    //     child: InkWell(
                    //       onTap: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => RegistrationPage(),
                    //           ),
                    //         );
                    //       },
                    //       child: Padding(
                    //         padding: EdgeInsets.all(screenHeight * 0.02),
                    //         child: Text(
                    //           'Sign Up',
                    //           style: TextStyle(
                    //               color: Colors.black54,
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 18),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

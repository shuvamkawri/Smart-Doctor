
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../consts/colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../get_started/get_started_page.dart';

class LandingPageFirst extends StatefulWidget {
  @override
  _LandingPageFirstState createState() => _LandingPageFirstState();
}

class _LandingPageFirstState extends State<LandingPageFirst> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightBlue,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              height: 570,
              width: double.infinity,
              child: Stack(
                children: [
                  // CarouselSlider(
                  //   options: CarouselOptions(
                  //     autoPlay: true,
                  //     enlargeCenterPage: true,
                  //     onPageChanged: (index, _) {
                  //       setState(() {
                  //         _currentIndex = index;
                  //         _pageController.animateToPage(
                  //           _currentIndex,
                  //           duration: Duration(milliseconds: 500),
                  //           curve: Curves.ease,
                  //         );
                  //       });
                  //     },
                  //   ),
                  //   items: [
                  //     'assets/images/landing_page_first_img.png',
                  //     'assets/images/landing_page_two_img.png',
                  //     'assets/images/landing_page_three_img.png',
                  //   ].map((item) {
                  //     return Container(
                  //       width: double.infinity,
                  //       height: screenHeight * 0.4,
                  //       decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //           image: AssetImage(item),
                  //           fit: BoxFit.contain,
                  //         ),
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),
                  // d
                  Container(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        buildTextContent(
                          "Find your ideal doctor",
                          "in just a few clicks!",
                          "Connect with highly-rated doctors in various specialties for personalized care and expert advice.",
                        ),
                        buildTextContent(
                          "Book an appointment",
                          "with the best doctors!",
                          "Schedule appointments with top doctors near you for comprehensive and compassionate healthcare.",
                        ),
                        buildTextContent(
                          "Consult with trusted doctors",
                          "anytime, anywhere!",
                          "Access professional medical consultations with renowned doctors, available for both in-person and online appointments.",
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 400,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildDot(0),
                          buildDot(1),
                          buildDot(2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => get_started_page()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: bgColor,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                child: Text(
                  'NEXT',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget buildTextContent(String title, String subTitle, String content) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(height: 5),
          Text(
            subTitle,
            style: TextStyle(color: bgColor, fontSize: 17),
          ),
          SizedBox(height: 8),
          Container(
            width: screenWidth * 0.7,
            alignment: Alignment.center,
            child: Text(
              content,
              style: TextStyle(fontSize: 14, color: dimBlack),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

}

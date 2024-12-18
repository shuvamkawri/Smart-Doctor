import 'package:flutter/material.dart';



class ButtomNavigation extends StatefulWidget {
  const ButtomNavigation({super.key});

  @override
  State<ButtomNavigation> createState() => _ButtomNavigationState();
}

class _ButtomNavigationState extends State<ButtomNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    // HomePage(),
    // DoctorListPage(),
    // VideoPage(),
    // ChatPage(),
    // ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // body: _pages[_currentIndex],
      // Set the background color here

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          // Update the selected index when a tab is pressed
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(Icons.home),
            label: 'HOME',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'SEARCH',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_back_rounded),
            label: 'VIDEO',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'CHAT',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'PROFILE',
          ),

        ],
        selectedItemColor: Colors.blue,
      ),

    );
  }
}




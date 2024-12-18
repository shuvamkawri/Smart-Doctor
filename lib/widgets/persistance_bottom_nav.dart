import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/doctor_prescription/doctor_prescription_pages.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../presentation/dashboard/doctor_dashboard/doctor_home_page/doctor_home_page.dart';
import '../presentation/dashboard/doctor_dashboard/doctor_medical_records/doctor_medical_record.dart';
import '../presentation/dashboard/doctor_dashboard/doctor_message_pages/doctor_message_pages.dart';
import '../presentation/dashboard/doctor_dashboard/doctor_overview_page/doctor_overview_page.dart';

class BottomNavigationBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      context,
      controller: _controller,
      screens: [
        DoctorHomePage(productName: ''),
        DoctorOverviewPage(),
        MessagePage(),
      ],
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: 'Home',
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          textStyle: TextStyle(color: Colors.black),
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.view_agenda, color: Colors.white),
          title: 'Overview',
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          textStyle: TextStyle(color: Colors.black),
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.message),
          title: 'Messages',
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          textStyle: TextStyle(color: Colors.black),
        ),
      ],
      navBarStyle: NavBarStyle.style15,
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      hideNavigationBar: _controller.index == 0, // Hide the nav bar for DoctorHomePage
      decoration: NavBarDecoration(
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4.0)],
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

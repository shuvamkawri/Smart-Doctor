import 'package:flutter/material.dart';

import '../../widgets/test_buttom_navigation.dart';
import '../../widgets/persistance_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBox(),
    );
  }
}

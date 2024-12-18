import 'package:flutter/cupertino.dart';

import '../presentation/get_started/get_started_page.dart';
import '../presentation/landing_page_screen/landing_page_first.dart';
import '../presentation/splash_screen/splashScreen.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String landingPage = '/landingPage';
  static const String loginScreen = '/loginScreen';
  static const String getStarted = '/getStarted';
  // static const String dashboard = '/dashboard';
  // static const String login_with_phone = '/login_with_phone';
  // static const String verifycode = '/verifycode';

  //
  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.splashScreen: (context) => SplashScreenPage(),
      AppRoutes.landingPage: (context) => LandingPageFirst(),
      AppRoutes.landingPage: (context) => get_started_page(),
      // AppRoutes.loginScreen: (context) => LoginScreen(),
      // AppRoutes.dashboard: (context) => DashBoard(),

    };
  }
}

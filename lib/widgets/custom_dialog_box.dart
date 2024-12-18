import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

// Utility class containing functions to show different types of QuickAlerts
class QuickAlertUtils {
  static void showConfirmAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: text,
    );
  }

  static void showSuccessAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  static void showSuccessProfileUpdate(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: " Profile Updated Successfully",
    );
    // Navigate to a different screen after a delay (for better user experience)
    // Future.delayed(Duration(seconds: 2), () {
    //   PersistentNavBarNavigator.pushNewScreen(
    //     context,
    //     screen: ProfilePage(),
    //     withNavBar: false,
    //   );
    // }
    // );
  }

  static void showErrorAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: text,
    );
  }

  static void showInfoAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: text,
    );
  }

  static void showWarningAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: text,
    );
  }

  static void showLoadingAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: text,
    );
  }

  static void showCustomAlert(BuildContext context, String text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      text: text,
    );
  }
}

class CustomScreen extends StatelessWidget {
  const CustomScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                QuickAlertUtils.showConfirmAlert(context, "Are you sure?");
              },
              child: Text("Show Confirm Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showSuccessAlert(context, "Success message");
              },
              child: Text("Show Success Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showErrorAlert(context, "Error message");
              },
              child: Text("Show Error Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showInfoAlert(context, "Info message");
              },
              child: Text("Show Info Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showWarningAlert(context, "Warning message");
              },
              child: Text("Show Warning Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showLoadingAlert(context, "Loading message");
              },
              child: Text("Show Loading Alert"),
            ),
            TextButton(
              onPressed: () {
                QuickAlertUtils.showCustomAlert(context, "Custom message");
              },
              child: Text("Show Custom Alert"),
            ),
          ],
        ),
      ),
    );
  }
}




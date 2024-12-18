import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../authentication/login_page.dart';
import '../doctor_home_page/doctor_home_page.dart';



class PaymentDetailsPage extends StatelessWidget {
  final String amount;
  final String currency;
  final String paymentMethod;
  final String paymentStatus;
  final String productName;
  final String unitPrice;
  final int quantity;

  PaymentDetailsPage({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  Future<void> _submitPaymentDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Prepare the request body
    final body = jsonEncode({
      "user_id": userId, // Replace with actual user ID
      "plan_name": productName,
      "payment_method": paymentMethod,
      "paid_amount": amount,
      "unit_price": unitPrice,
      "plan_quantity": quantity.toString(),
      "status": paymentStatus.toLowerCase() == 'successful',
    });

    try {
      // Print the request body
      print("Request Body: $body");

      // Make the API call
      final response = await post(
        'hospital-wise-subscription/create',
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: body,
      );

      // Print the raw response
      print("Raw Response: ${response}");

      // Decode the response
      final result = jsonDecode(response);

      // Print the parsed response
      print("Parsed Response: $result");

      if (result['errorCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription is completed')),
        );

        // Navigate to the home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>  LoginPage(planName: productName), // Pass the plan name
            // builder: (context) =>  LoginPage(), // Pass the plan name
          ),
              (route) => false,
        );
      } else {
        _showErrorDialog(context, 'Error', result['message']);
      }
    } catch (error) {
      // Print the error for debugging
      print("Error: $error");

      _showErrorDialog(context, 'An error occurred', error.toString());
    }
  }


  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DoctorHomePage(productName: '',)),
                    (route) => false, // Remove all previous routes
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Status: $paymentStatus',
              style: TextStyle(
                fontSize: 22,
                color: paymentStatus == 'Successful' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('Plan Name: $productName', style: TextStyle(fontSize: 18)),
            Text('Payment Method: $paymentMethod', style: TextStyle(fontSize: 18)),
            Text('Amount Paid: $amount $currency', style: TextStyle(fontSize: 18)),
            Text('Unit Price: $unitPrice $currency', style: TextStyle(fontSize: 18)),
            Text('Plan Quantity: $quantity', style: TextStyle(fontSize: 18)),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitPaymentDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

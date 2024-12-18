
import 'package:ai_medi_doctor/presentation/dashboard/doctor_dashboard/payment_gateway/payment_details.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';



class PaymentScreen extends StatefulWidget {
  final String planName;
  final double price;

  PaymentScreen({required this.planName, required this.price});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  CardFieldInputDetails? _card;
  String? _paymentIntentClientSecret;
  String _selectedCurrency = 'Dollar'; // Default currency
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
    _initializeRazorpay();
    print('Selected Plan: ${widget.planName}');
    print('Selected Plan Price: ${widget.price}');
  }

  void _initializeStripe() {
    Stripe.publishableKey =
    'pk_test_51QA4xV041ffhzrHeUQZCsqQqo04ZyAtQdpSpPtiWWAzhxqq9qKxeR7W7M87CwfJiVTyI3CAeDN0gNuKzMg4JNxV000q2Em1vUW';
    Stripe.instance.applySettings();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
  }

  Future<void> _createPaymentIntent() async {
    try {
      int amountInCents = (widget.price * 100).toInt();
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
          'Bearer sk_test_51QA4xV041ffhzrHe3biDHIGUxWOHPB7Xru7CySnLk9H4JzZrLl8Pe6L9meAawpeRLsfXImqepAiRV7vMZSfWZJ6200QXjxRFeT',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': 'usd',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _paymentIntentClientSecret = jsonResponse['client_secret'];
        });
      } else {
        Fluttertoast.showToast(msg: 'Failed to create payment intent.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _handleStripePayment() async {
    if (_card == null || !_card!.complete) {
      Fluttertoast.showToast(msg: 'Please enter valid card details.');
      return;
    }

    await _createPaymentIntent();

    if (_paymentIntentClientSecret == null) {
      Fluttertoast.showToast(msg: 'Payment Intent not created.');
      return;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _paymentIntentClientSecret!,
          style: ThemeMode.light,
          merchantDisplayName: 'AI Medi Doctor',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(msg: 'Payment Successful');

      // Navigate to PaymentDetailsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentDetailsPage(
                amount: widget.price.toStringAsFixed(2),
                currency: _selectedCurrency == 'Dollar' ? 'USD' : 'INR',
                paymentMethod: 'Stripe',
                paymentStatus: 'Successful',
                productName: widget.planName,
                unitPrice: widget.price.toStringAsFixed(2),
                quantity: 1,
              ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Payment Failed: $e');
    }
  }


  void _handleRazorpayPayment() {
    var options = {
      // 'key': 'rzp_live_ILgsfZCZoFIKMb',
      'key': 'rzp_test_opsQSiX99QiwZd',
      'amount': (widget.price * 100).toInt(),
      'currency': 'INR',
      'name': 'AI Medi Doctor',
      'description': widget.planName,
      'prefill': {'contact': '', 'email': ''},

    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: 'Payment Successful: ${response.paymentId}');

    // Navigate to PaymentDetailsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentDetailsPage(
              amount: widget.price.toStringAsFixed(2),
              currency: _selectedCurrency == 'Dollar' ? 'USD' : 'INR',
              paymentMethod: 'Razorpay',
              paymentStatus: 'Successful',
              productName: widget.planName,
              unitPrice: widget.price.toStringAsFixed(2),
              quantity: 1,
            ),
      ),
    );
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed: ${response.message}');
  }

  void _handlePayment() {
    if (_selectedCurrency == 'Dollar') {
      _handleStripePayment();
    } else if (_selectedCurrency == 'Rupee') {
      _handleRazorpayPayment();
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Release resources used by Razorpay
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Gateway',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Flat app bar
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Selector Dropdown
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: DropdownButton<String>(
                value: _selectedCurrency,
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedCurrency == 'Rupee'
                        ? Icon(Icons.currency_rupee, color: Colors.blueAccent)
                        : Icon(Icons.attach_money, color: Colors.green),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                    // Dropdown arrow
                  ],
                ),
                underline: SizedBox(),
                // Remove default underline
                items: ['Dollar', 'Rupee'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          value == 'Rupee'
                              ? Icons.currency_rupee
                              : Icons.attach_money,
                          color: value == 'Rupee' ? Colors.blueAccent : Colors
                              .green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          value,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                  });
                },
              ),
            ),


            // Plan Details Section
            Text(
              'Plan Details:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildDetailCard('Plan', widget.planName),
            SizedBox(height: 10),
            _buildDetailCard(
                'Price',
                _selectedCurrency == 'Dollar'
                    ? '\$${widget.price.toStringAsFixed(2)}'
                    : '₹${widget.price.toStringAsFixed(2)}'
            ),

            SizedBox(height: 20),

            // Card Input Field
            Text(
              'Enter Card Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CardField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              },
            ),

            SizedBox(height: 30),

            // Pay Now Button
            Center(
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
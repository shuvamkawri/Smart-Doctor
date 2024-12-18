
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart';
import '../payment_gateway/payment_screen.dart';

class SubscriptionPlan {
  final String id;
  final String userType;
  final String subscribeType;
  final double price;
  final String discountPrice;
  final String planName;
  final String title;
  final String imageUrl;
  final List<Feature> features;

  SubscriptionPlan({
    required this.id,
    required this.userType,
    required this.subscribeType,
    required this.price,
    required this.discountPrice,
    required this.planName,
    required this.title,
    required this.imageUrl,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',  // Default to an empty string if null
      userType: json['user_type'] ?? '', // Default to an empty string if null
      subscribeType: json['subscribe_type'] ?? '', // Default to an empty string if null
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0, // Safely parse to double
      discountPrice: json['discount_price'] ?? '', // Default to an empty string if null
      planName: json['plan_name'] ?? '', // Default to an empty string if null
      title: json['title'] ?? '', // Default to an empty string if null
      imageUrl: imageUrlBase + (json['images'] ?? ''),  // Ensure 'images' is not null
      features: (json['featuresSchema'] as List? ?? [])
          .map((featureJson) => Feature.fromJson(featureJson['features'] ?? {}))
          .toList(),
    );
  }
}

Future<String?> getFullName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('full_name');
}

class Feature {
  final String id;
  final String type;
  final String title;
  final String imageUrl;
  final String url;

  Feature({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.url,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['_id'] ?? '',  // Default to an empty string if null
      type: json['type'] ?? '',  // Default to an empty string if null
      title: json['title'] ?? '',  // Default to an empty string if null
      imageUrl: imageUrlBase + (json['images'] ?? ''),  // Ensure 'images' is not null
      url: json['url'] ?? '',  // Default to an empty string if null
    );
  }
}

// API Fetch Function
Future<List<SubscriptionPlan>> fetchSubscriptionPlans() async {
  final response = await get('subscribe/list'); // Using the common function
  final List<dynamic> jsonResponse = jsonDecode(response)['details'];
  print("Response body$jsonResponse");
  return jsonResponse.map((json) => SubscriptionPlan.fromJson(json)).toList();
}

// UI Page
class SubscriptionPlansPage extends StatefulWidget {
  final String planName;

  const SubscriptionPlansPage({Key? key, required this.planName}) : super(key: key);

  @override
  _SubscriptionPlansPageState createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  bool allButtonsDisabled = false;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  void _checkSubscriptionStatus() async {
    // Fetch the plans and check if all buttons are disabled
    final plans = await fetchSubscriptionPlans();
    final isEnterpriseSelected = widget.planName.toLowerCase() == 'enterprise';

    bool areAllDisabled = plans.every((plan) =>
    isEnterpriseSelected || plan.planName.toLowerCase() == 'starter');

    setState(() {
      allButtonsDisabled = areAllDisabled;
    });

    // If all buttons are disabled, show a dialog
    if (allButtonsDisabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog();
      });
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Updated'),
        content: const Text('Your plan has been updated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _subscribeNow(BuildContext context, String planName, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(planName: planName, price: price),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NavDrawer(),
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selected Plan: ${widget.planName.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SubscriptionPlan>>(
                future: fetchSubscriptionPlans(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final plans = snapshot.data!;
                  final isEnterpriseSelected =
                      widget.planName.toLowerCase() == 'enterprise';

                  return ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];

                      String description = '';
                      if (plan.planName.toLowerCase() == 'moderate') {
                        description = 'Includes all features from Starter. +';
                      } else if (plan.planName.toLowerCase() == 'intermediate') {
                        description = 'Includes all features from Moderate. +';
                      } else if (plan.planName.toLowerCase() == 'enterprise') {
                        description = 'Includes all features from Intermediate. +';
                      }

                      return Card(
                        margin: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      plan.imageUrl,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.planName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          plan.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    plan.price == 0.0 ? 'Free' : '\$${plan.price}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: const Text(
                                  'Features:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              ...plan.features.map((feature) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      feature.imageUrl.isNotEmpty
                                          ? Image.network(
                                        feature.imageUrl,
                                        width: 18,
                                        height: 18,
                                      )
                                          : const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature.title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(),
                              Center(
                                child: ElevatedButton(
                                  onPressed: isEnterpriseSelected ||
                                      plan.planName.toLowerCase() == 'starter'
                                      ? null
                                      : () => _subscribeNow(
                                      context, plan.planName, plan.price),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEnterpriseSelected ||
                                        plan.planName.toLowerCase() == 'starter'
                                        ? Colors.grey
                                        : Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.thumb_up, size: 16, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Subscribe Now',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

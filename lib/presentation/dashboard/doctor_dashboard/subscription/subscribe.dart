import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/common_fuction_api.dart';
import '../../../../widgets/nav_drawer.dart'; // Your API function import
import '../payment_gateway/payment_screen.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<dynamic> subscriptionPlans = [];
  String? selectedPlanId = '';
  String? selectedPlanName = '';
  double? selectedPlanPrice;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      final response = await get('subscribe/list');
      final responseData = json.decode(response);

      if (responseData['errorCode'] == 200) {
        setState(() {
          subscriptionPlans = responseData['details'];
        });
      } else {
        print(
            'Failed to load subscription plans, Error: ${responseData['errorCode']}');
      }
    } catch (e) {
      print('Error fetching subscription plans: $e');
    }
  }

  void _subscribeNow() {
    if (selectedPlanId != null && selectedPlanPrice != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           PaymentScreen(
    //             planName: selectedPlanName!,
    //             planPrice: selectedPlanPrice!,
    //           ),
    //     ),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content: Text('Please select a subscription plan to proceed.')),
    //   );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    FutureBuilder<String?>(
                      future: getFullName(),
                      builder: (context, snapshot) {
                        String firstLetter =
                        snapshot.data?.isNotEmpty ?? false
                            ? snapshot.data![0]
                            : '';
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: Text(
                            firstLetter.toUpperCase(),
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Doctor",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<String?>(
                            future: getFullName(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Unknown",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Subscription Plans
            Expanded(
              child: subscriptionPlans.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: subscriptionPlans.length,
                itemBuilder: (context, index) {
                  var plan = subscriptionPlans[index];
                  var planImage = plan['images'] ?? '';
                  var planName = plan['subscribe_type'] ?? 'No Name';
                  var planTitle = plan['title'] ?? 'No Title';
                  var planPrice = double.tryParse(plan['price'].toString()) ?? 0.0;
                  var planId = plan['plan_id'] ?? '';

                  // Check if the current plan is selected
                  bool isSelected = selectedPlanId!.isNotEmpty
                      ? selectedPlanId == planId
                      : selectedPlanName == planName;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Update selection based on planId or planName
                        selectedPlanId = planId.isNotEmpty ? planId : '';
                        selectedPlanName = planName;
                        selectedPlanPrice = planPrice;
                      });
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // Apply color based on selection status
                      color: isSelected ? Colors.green[100] : Colors.white,
                      child: Column(
                        children: [
                          // Feature List
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: plan['featuresSchema']?.length ?? 0,
                              itemBuilder: (context, featureIndex) {
                                var feature =
                                plan['featuresSchema'][featureIndex]['features'];
                                var featureTitle = feature['title'] ?? 'Feature';
                                var featureImage = feature['images'] ?? '';

                                return Container(
                                  width: 120,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.blue[50],
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          featureImage.isNotEmpty
                                              ? Image.network(
                                            '$imageUrlBase$featureImage',
                                            width: 50,
                                            height: 30,
                                            fit: BoxFit.contain,
                                          )
                                              : Icon(Icons.star, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text(
                                            featureTitle,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          ListTile(
                            leading: planImage.isNotEmpty
                                ? Image.network(
                              '$imageUrlBase$planImage',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                            ),
                            title: Text(
                              planName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.green : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              planTitle,
                              style: TextStyle(
                                color: isSelected ? Colors.green : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            ),

            // Subscribe Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _subscribeNow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thumb_up, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Subscribe Now',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/nav_drawer.dart';



class SubscriptionnPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionnPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  String? selectedPlan; // This will hold the selected plan name


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      body: Column(
        children: [
          // Gradient Header
          Container(
            height: 150,
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
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Profile Avatar
                            FutureBuilder<String?>(
                              future: getFullName(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white.withOpacity(0.5),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                } else if (snapshot.hasError || !snapshot.hasData) {
                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white.withOpacity(0.5),
                                    child: Icon(Icons.person, color: Colors.white),
                                  );
                                } else {
                                  String? fullName = snapshot.data;
                                  String firstLetter = fullName != null && fullName.isNotEmpty
                                      ? fullName[0]
                                      : '';
                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white.withOpacity(0.5),
                                    child: Text(
                                      firstLetter.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(width: 10),
                            // Welcome Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Doctor",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FutureBuilder<String?>(
                                  future: getFullName(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator(
                                        color: Colors.white,
                                      );
                                    } else if (snapshot.hasError || !snapshot.hasData) {
                                      return Text(
                                        "Unknown",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Menu Button
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.white, size: 30),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  SubscriptionOption(
                    planName: 'Moderate Plan',
                    price: '\$9.99/month',
                    description: 'Access to basic information only.\nPerfect for informational use.',
                    onTap: () {
                      setState(() {
                        selectedPlan = 'Moderate Plan'; // Update selected plan
                      });
                    },
                    icon: Icons.medical_information_sharp,
                    color: Colors.purple[300]!,
                    features: [
                      {'name': 'Profile', 'icon': 'assets/images/user.png'},
                      {'name': 'Patient Appointment', 'icon': 'assets/images/medical-appointment.png'},
                      {'name': 'Pharmacy', 'icon': 'assets/images/capsules.png'},
                      {'name': 'Laboratory', 'icon': 'assets/images/flask.png'},
                      {'name': 'Patient Diagnosis', 'icon': 'assets/images/diagnosis.png'},
                    ],
                    discount: 5, // 5% discount
                  ),

                  SizedBox(height: 15),
                  SubscriptionOption(
                    planName: 'Intermediate Plan',
                    price: '\$19.99/month',
                    description: 'Share doctor-patient information securely.\nIdeal for basic interactions.',
                    onTap: () {
                      setState(() {
                        selectedPlan = 'Intermediate Plan'; // Update selected plan
                      });
                    },
                    icon: Icons.mobile_screen_share_sharp,
                    color: Colors.orange[500]!,
                    features: [
                      {'name': 'Profile', 'icon': 'assets/images/user.png'},
                      {'name': 'Create Appointment', 'icon': 'assets/images/medical-appointment.png'},
                      {'name': 'Smart Data', 'icon': 'assets/images/smart_data.png'},
                      {'name': 'Patient Appointment', 'icon': 'assets/images/medical-appointment.png'},
                      {'name': 'Pharmacy', 'icon': 'assets/images/capsules.png'},
                      {'name': 'Laboratory', 'icon': 'assets/images/flask.png'},
                      {'name': 'Patient Diagnosis', 'icon': 'assets/images/diagnosis.png'},
                    ],
                    discount: 10, // 10% discount
                  ),

                  SizedBox(height: 15),
                  SubscriptionOption(
                    planName: 'Enterprise Plan',
                    price: '\$49.99/month',
                    description: 'Includes chat and video call features for direct doctor-patient communication.\nAll features unlocked.',
                    onTap: () {
                      setState(() {
                        selectedPlan = 'Enterprise Plan'; // Update selected plan
                      });
                    },
                    icon: Icons.video_call,
                    color: Colors.green[500]!,
                    features: [
                      {'name': 'Profile', 'icon': 'assets/images/user.png'},
                      {'name': 'Prescription', 'icon': 'assets/images/pills.png'},
                      {'name': 'Reports Analytics', 'icon': 'assets/images/analysis.png'},
                      {'name': 'Billing & Invoice', 'icon': 'assets/images/bill.png'},
                      {'name': 'Finance', 'icon': 'assets/images/accounting.png'},
                    ],
                    discount: 15, // 15% discount
                  ),

                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedPlan == null) {
                          // Show a dialog or Snackbar to let the user know they need to select a plan
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select a plan before subscribing.")),
                          );
                        } else {
                          // Navigate to the payment page
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => PaymentScreen(plan: selectedPlan!)),
                          // );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
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
          ),
        ],
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String planName;
  final String price;
  final String description;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final List<Map<String, String>> features;
  final double? discount; // Discount in percentage (e.g., 10 for 10%)

  const SubscriptionOption({
    required this.planName,
    required this.price,
    required this.description,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.features,
    this.discount, // Optional discount parameter
  });

  @override
  Widget build(BuildContext context) {
    double originalPrice = double.parse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
    double discountedPrice = discount != null
        ? originalPrice - (originalPrice * (discount! / 100))
        : originalPrice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 36, color: color),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Name
                      Row(
                        children: [
                          Text(
                            planName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (discount != null && discount! > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${discount!.toStringAsFixed(0)}% OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      // Price and Discounted Price
                      if (discount != null && discount! > 0) ...[
                        Text(
                          '\$${originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '\$${discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      SizedBox(height: 8),
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            // Features List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: features
                    .map(
                      (feature) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: [
                        Image.asset(feature['icon']!, width: 40, height: 40),
                        SizedBox(height: 5),
                        Text(
                          feature['name']!,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


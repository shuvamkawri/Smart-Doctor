
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts/colors.dart';

import '../presentation/authentication/login_page.dart';
import '../presentation/dashboard/doctor_dashboard/subscription/subscribe.dart';
import '../presentation/location_pages/country_list_page.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

String selectedOption = 'simple';
bool _showOptions = false;

Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Do you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Logout'),
            onPressed: () {
              // User confirmed logout, perform logout action
              Navigator.of(context).pop(); // Close the dialog
              _performLogout(context);
            },
          ),
        ],
      );
    },
  );
}

Future<Map<String, String?>> _fetchLocationData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? country = prefs.getString('selectedCountry');
  String? state = prefs.getString('selectedState');
  String? city = prefs.getString('cityName');
  return {
    'country': country,
    'state': state,
    'city': city,
  };
}

void _performLogout(BuildContext context) async {
  // Clear user session data
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var rememberMe = prefs.getString("rememberMeStatus");

  if (rememberMe == "true") {
    String? mobileNumber = prefs.getString("mobile_no");
    String? password = prefs.getString("Password");

    print("Mobile number:$mobileNumber ");
    print("Password:$password ");
    prefs.remove('user_id');
    await prefs.clear();
    prefs.setString("mobile_number_remember", mobileNumber!);
    prefs.setString("password_remember", password!);
  } else {
    prefs.remove('user_id');
    await prefs.clear();
  }

  // Navigate back to the sign-in page
  PersistentNavBarNavigator.pushNewScreen(
    context,
    screen: LoginPage(planName: '',),
    withNavBar: false,
  );
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('full_name')),
              builder: (context, nameSnapshot) {
                if (nameSnapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Loading...", // Display a placeholder text while loading
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: darkblueColor),
                  );
                } else if (nameSnapshot.hasError) {
                  return Text(
                    'Error: ${nameSnapshot.error}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: darkblueColor),
                  );
                } else {
                  String? fullName = nameSnapshot.data;
                  String firstLetter = fullName != null && fullName.isNotEmpty
                      ? fullName[0].toUpperCase()
                      : '';
                  return Text(
                    fullName ?? "", // Display the full name
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: darkblueColor),
                  );
                }
              },
            ),
            accountEmail: FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('email')),
              builder: (context, emailSnapshot) {
                if (emailSnapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Loading...", // Display a placeholder text while loading
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: darkblueColor),
                  );
                } else if (emailSnapshot.hasError) {
                  return Text(
                    'Error: ${emailSnapshot.error}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: darkblueColor),
                  );
                } else {
                  String? email = emailSnapshot.data;
                  return Text(
                    email ?? "", // Display the email
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: darkblueColor),
                  );
                }
              },
            ),
            currentAccountPicture: FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('full_name')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    backgroundColor: darkblueColor,
                    radius: 30,
                    child:
                        CircularProgressIndicator(), // Display a loading indicator while loading
                  );
                } else if (snapshot.hasError) {
                  return CircleAvatar(
                    backgroundColor: darkblueColor,
                    radius: 30,
                    child: Text(
                      "A", // Display a default letter if there's an error
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                } else {
                  String? fullName = snapshot.data;
                  String firstLetter = fullName != null && fullName.isNotEmpty
                      ? fullName[0].toUpperCase()
                      : '';
                  return CircleAvatar(
                    backgroundColor: darkblueColor,
                    radius: 30,
                    child: Text(
                      firstLetter,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                }
              },
            ),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              image: DecorationImage(
                image: AssetImage("assets/images/drawer_back_img.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.subscriptions_outlined),
            title: FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('subscribeType')), // Replace 'plan_name' with your actual key
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error loading plan',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                } else {
                  String? planName = snapshot.data ?? 'No Plan Available';
                  return Text(
                    planName,
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  );
                }
              },
            ),
            onTap: () {
              // Define your desired behavior when tapping on the ListTile
            },
          ),

          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Subscribe'),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: SubscriptionPage(),
                withNavBar: false,
              );
            },
          ),
          //
          // ListTile(
          //   leading: Icon(Icons.message_rounded),
          //   title: Text('Messages'),
          //   onTap: () {
          //   },
          // ),


          //
          ListTile(
            leading: Icon(Icons.location_on_rounded),
            title: Text('Change location'),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CountryListPage(),
                withNavBar: false,
              );
            },
          ),


          FutureBuilder<Map<String, String?>>(
            future: _fetchLocationData(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, String?>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: Icon(Icons.location_on_rounded),
                  title: Text('Loading...'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Error loading location'),
                );
              } else {
                var data = snapshot.data;
                // String country = data?['country'] ?? 'Unknown Country';
                // String state = data?['state'] ?? 'Unknown State';
                String city = data?['city'] ?? 'Unknown City';

                return ListTile(
                  leading: Icon(Icons.location_on_rounded),
                  title: Text('$city'),
                  onTap: () {
                    // Add your onTap functionality here
                  },
                );
              }
            },
          ),


          // Column(
          //   children: [
          //     ListTile(
          //       leading: Icon(Icons.navigation),
          //       title: Text('Navigation'),
          //       onTap: () {
          //         setState(() {
          //           _showOptions = !_showOptions;
          //         });
          //       },
          //     ),
          //     if (_showOptions) ...[
          //       ListTile(
          //         title: const Text('Simple Icons'),
          //         leading: Radio<String>(
          //           value: 'Simple Icons',
          //           groupValue: selectedOption,
          //           onChanged: (String? value) {
          //             setState(() {
          //               selectedOption = value!;
          //             });
          //           },
          //         ),
          //       ),
          //       ListTile(
          //         title: const Text('Moderate Icons'),
          //         leading: Radio<String>(
          //           value: 'Moderate Icons',
          //           groupValue: selectedOption,
          //           onChanged: (String? value) {
          //             setState(() {
          //               selectedOption = value!;
          //             });
          //           },
          //         ),
          //       ),
          //       ListTile(
          //         title: const Text('Expert Icons'),
          //         leading: Radio<String>(
          //           value: 'Expert Icons',
          //           groupValue: selectedOption,
          //           onChanged: (String? value) {
          //             setState(() {
          //               selectedOption = value!;
          //             });
          //           },
          //         ),
          //       ),
          //     ],
          //   ],
          // ),


          // ListTile(
          //   leading: Icon(Icons.navigation),
          //   title: Text('Navigation'),
          //   onTap: () {
          //     showModalBottomSheet(
          //       context: context,
          //       builder: (BuildContext context) {
          //         String selectedOption = 'simple';
          //
          //         return StatefulBuilder(
          //           builder: (BuildContext context, StateSetter setState) {
          //             return Padding(
          //               padding: const EdgeInsets.all(16.0),
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: <Widget>[
          //                   ListTile(
          //                     title: const Text('Simple Icons'),
          //                     leading: Radio<String>(
          //                       value: 'simple',
          //                       groupValue: selectedOption,
          //                       onChanged: (String? value) {
          //                         setState(() {
          //                           selectedOption = value!;
          //                         });
          //                       },
          //                     ),
          //                   ),
          //                   ListTile(
          //                     title: const Text('Moderate Icons'),
          //                     leading: Radio<String>(
          //                       value: 'moderate',
          //                       groupValue: selectedOption,
          //                       onChanged: (String? value) {
          //                         setState(() {
          //                           selectedOption = value!;
          //                         });
          //                       },
          //                     ),
          //                   ),
          //                   ListTile(
          //                     title: const Text('Expert Icons'),
          //                     leading: Radio<String>(
          //                       value: 'expert',
          //                       groupValue: selectedOption,
          //                       onChanged: (String? value) {
          //                         setState(() {
          //                           selectedOption = value!;
          //                         });
          //                       },
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             );
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),


          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

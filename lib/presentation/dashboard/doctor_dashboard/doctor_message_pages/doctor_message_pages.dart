import 'package:ai_medi_doctor/presentation/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../../../consts/colors.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../doctor_model_pages/messages_model_pages.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<chatUserModel> chatUserList = [
    chatUserModel(
        chatUserName: 'You', chatUserImage: 'assets/images/y.jpg'),
    chatUserModel(
        chatUserName: 'Riya', chatUserImage: 'assets/images/ri.jpg'),
    chatUserModel(
        chatUserName: 'Rupma', chatUserImage: 'assets/images/ro.jpg'),
    chatUserModel(
        chatUserName: 'Daisy', chatUserImage: 'assets/images/daisy.jpg'),
    chatUserModel(
        chatUserName: 'Sully', chatUserImage: 'assets/images/sully.jpg'),
    chatUserModel(
        chatUserName: 'John', chatUserImage: 'assets/images/john.jpg'),
  ];

  List<chatDoctorModel> chatDoctorList = [
    chatDoctorModel(
        chatDoctorName: 'Dr. Carol',
        chatDoctorInfo: "I am cardio patient. I need your help",
        chatDoctorImage: 'assets/images/d1.jpg'),
    chatDoctorModel(
        chatDoctorName: 'Dr. Asshish',
        chatDoctorInfo: "I am cardio patient. I need your help",
        chatDoctorImage: 'assets/images/d3.jpg'),
    chatDoctorModel(
        chatDoctorName: 'Dr. Rooma ',
        chatDoctorInfo: "I am cardio patient. I need your help",
        chatDoctorImage: 'assets/images/d4.jpg'),
    chatDoctorModel(
        chatDoctorName: 'Dr. Iker Bureau',
        chatDoctorInfo: "I am cardio patient. I need your help",
        chatDoctorImage: 'assets/images/d2.jpg'),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: lightWhite,
      body: Column(
        children: [
          Container(
            height: 280,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.blue,
                                ),
                                color: Colors.black54,
                                onPressed: () {
                                  // Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DashboardScreen(),
                                      ));
                                },
                              ),
                            ),
                            Container(
                              child: Text(
                                "Message",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              margin: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.message_rounded),
                                color: Colors.blue,
                                onPressed: () {
                                  // Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.dehaze_outlined),
                                color: Colors.blue,
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            errorText: null,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue,
                            ), // Use prefixIcon instead of prefix
                            hintText: 'Search Chat',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  width: 0.3,
                                  color:
                                  Colors.white), // Set border width to 0.3
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chatUserList.length,
                          itemBuilder: (context, index) {
                            final user = chatUserList[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    height: 50,
                                    width: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CircleAvatar(
                                        backgroundImage:
                                        AssetImage(user.chatUserImage),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(user.chatUserName),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 340,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    margin: EdgeInsets.all(20),
                    child: ListView.builder(
                      // shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: chatDoctorList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        height: 50,
                                        width: 50,
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(25),
                                          child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                              chatDoctorList[index]
                                                  .chatDoctorImage,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                chatDoctorList[index]
                                                    .chatDoctorName,
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                chatDoctorList[index]
                                                    .chatDoctorInfo,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 0.1,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

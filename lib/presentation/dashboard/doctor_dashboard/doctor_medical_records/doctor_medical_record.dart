

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../../../consts/colors.dart';
import '../../../../widgets/nav_drawer.dart';
import '../../dashboard_screen.dart';
import 'doctor_medical_records_details_page.dart';

class DoctorMedicalRecords extends StatefulWidget {
  const DoctorMedicalRecords({super.key});

  @override
  State<DoctorMedicalRecords> createState() => _DoctorMedicalRecordsState();
}

class _DoctorMedicalRecordsState extends State<DoctorMedicalRecords> {
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Ashto Yamal',
      'specialty': 'Cardiologist',
      'contact': 'yamal.ashto@example.com',
      'image': 'https://t4.ftcdn.net/jpg/02/60/04/09/360_F_260040900_oO6YW1sHTnKxby4GcjCvtypUCWjnQRg5.jpg',
      'biography': 'Dr. John Doe is a leading cardiologist with over 20 years of experience...',
      'qualifications': 'MD, PhD in Cardiology',
      'consultationTimes': 'Mon-Fri: 9am - 5pm',
      'department': 'Cardiology',
      'medicalHistory': [
        '2015: Treated 100+ patients with heart issues',
        '2017: Published research on heart disease prevention'
      ],
      'patientRecords': [
        {'patientName': 'Alice', 'condition': 'Hypertension', 'lastVisit': '2023-06-01'},
        {'patientName': 'Bob', 'condition': 'Arrhythmia', 'lastVisit': '2023-07-15'}
      ]
    },
    {
      'name': 'Dr. Kane Will',
      'specialty': 'Neurologist',
      'contact': 'kane.will@example.com',
      'image': 'https://static.vecteezy.com/system/resources/thumbnails/026/375/249/small_2x/ai-generative-portrait-of-confident-male-doctor-in-white-coat-and-stethoscope-standing-with-arms-crossed-and-looking-at-camera-photo.jpg',
      'biography': 'Dr. Jane Smith specializes in neurological disorders and has a decade of experience...',
      'qualifications': 'MD in Neurology',
      'consultationTimes': 'Tue-Thu: 10am - 4pm',
      'department': 'Neurology',
      'medicalHistory': [
        '2018: Treated 200+ patients with neurological disorders',
        '2020: Conducted a study on Alzheimer’s disease'
      ],
      'patientRecords': [
        {'patientName': 'Charlie', 'condition': 'Epilepsy', 'lastVisit': '2023-05-20'},
        {'patientName': 'Dave', 'condition': 'Parkinson’s disease', 'lastVisit': '2023-06-18'}
      ]
    },

    {
      "name": "Dr. Sarah Collins",
      "specialty": "Cardiologist",
      "contact": "sarah.collins@example.com",
      "image": "https://img.freepik.com/free-photo/cheerful-young-medic-hospital_23-2147763852.jpg?size=626&ext=jpg&ga=GA1.1.2008272138.1721001600&semt=ais_user",
      "biography": "Dr. Sarah Collins specializes in cardiology with a focus on heart disease prevention and treatment...",
      "qualifications": "MD in Cardiology",
      "consultationTimes": "Mon-Fri: 9am - 5pm",
      "department": "Cardiology",
      "medicalHistory": [
        "2018: Established a cardiac rehabilitation program",
        "2021: Published study on heart failure treatments"
      ],
      "patientRecords": [
        {"patientName": "Sophia", "condition": "Hypertension", "lastVisit": "2023-05-12"},
        {"patientName": "Ethan", "condition": "Coronary artery disease", "lastVisit": "2023-06-28"}
      ]
    },

    {
      "name": "Dr. Lisa Chen",
      "specialty": "Pediatrician",
      "contact": "lisa.chen@example.com",
      "image": "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      "biography": "Dr. Lisa Chen specializes in pediatric care, focusing on child development and infectious diseases...",
      "qualifications": "MD in Pediatrics",
      "consultationTimes": "Mon-Wed: 1pm - 6pm",
      "department": "Pediatrics",
      "medicalHistory": [
        "2019: Launched community immunization initiative",
        "2022: Conducted research on childhood asthma"
      ],
      "patientRecords": [
        {"patientName": "Olivia", "condition": "Chickenpox", "lastVisit": "2023-04-02"},
        {"patientName": "Mason", "condition": "Autism spectrum disorder", "lastVisit": "2023-06-21"}
      ]
    },

    {
      "name": "Dr. Michael Lee",
      "specialty": "Orthopedic Surgeon",
      "contact": "michael.lee@example.com",
      "image": "https://online-learning-college.com/wp-content/uploads/2023/01/Qualifications-to-Become-a-Doctor--scaled.jpg",
      "biography": "Dr. Michael Lee specializes in orthopedic surgery, with expertise in joint replacements and sports injuries...",
      "qualifications": "MD in Orthopedics",
      "consultationTimes": "Tue-Fri: 9am - 3pm",
      "department": "Orthopedics",
      "medicalHistory": [
        "2016: Established sports injury clinic",
        "2020: Pioneered minimally invasive joint replacement techniques"
      ],
      "patientRecords": [
        {"patientName": "Liam", "condition": "ACL tear", "lastVisit": "2023-03-10"},
        {"patientName": "Ava", "condition": "Hip osteoarthritis", "lastVisit": "2023-06-14"}
      ]
    },

    {
      "name": "Dr. Emma Baker",
      "specialty": "Dermatologist",
      "contact": "emma.baker@example.com",
      "image": "https://st2.depositphotos.com/4431055/11871/i/450/depositphotos_118715118-stock-photo-attractive-young-female-doctor.jpg",
      "biography": "Dr. Emma Baker specializes in dermatology, focusing on skin cancer detection and treatment...",
      "qualifications": "MD in Dermatology",
      "consultationTimes": "Mon-Wed: 10am - 4pm",
      "department": "Dermatology",
      "medicalHistory": [
        "2017: Co-authored study on melanoma detection",
        "2021: Developed personalized skincare regimen"
      ],
      "patientRecords": [
        {"patientName": "Noah", "condition": "Psoriasis", "lastVisit": "2023-05-05"},
        {"patientName": "Isabella", "condition": "Acne treatment", "lastVisit": "2023-06-25"}
      ]
    },

    {
      "name": "Dr. Jason Patel",
      "specialty": "Ophthalmologist",
      "contact": "jason.patel@example.com",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnNTtLdzbaLO9tiV5qUGce9nAGSDkbqlSCF0inlFzX00-wfEbkVBN6TWMDvBwnEiAFawQ&usqp=CAU",
      "biography": "Dr. Jason Patel specializes in ophthalmology, with a focus on cataract surgery and retinal diseases...",
      "qualifications": "MD in Ophthalmology",
      "consultationTimes": "Thu-Sat: 8am - 2pm",
      "department": "Ophthalmology",
      "medicalHistory": [
        "2019: Implemented telemedicine for eye care",
        "2023: Conducted clinical trial on glaucoma treatments"
      ],
      "patientRecords": [
        {"patientName": "Lily", "condition": "Macular degeneration", "lastVisit": "2023-04-18"},
        {"patientName": "James", "condition": "Refractive surgery", "lastVisit": "2023-06-30"}
      ]
    }

    ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _editDoctor(int index) {
    Map<String, dynamic> editedDoctor = Map<String, dynamic>.from(doctors[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: editedDoctor['name']);
        TextEditingController specialtyController = TextEditingController(text: editedDoctor['specialty']);
        TextEditingController contactController = TextEditingController(text: editedDoctor['contact']);
        TextEditingController biographyController = TextEditingController(text: editedDoctor['biography']);
        TextEditingController qualificationsController = TextEditingController(text: editedDoctor['qualifications']);
        TextEditingController consultationTimesController = TextEditingController(text: editedDoctor['consultationTimes']);

        return AlertDialog(
          title: Text('Edit Doctor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    editedDoctor['name'] = value;
                  },
                ),
                TextField(
                  controller: specialtyController,
                  decoration: InputDecoration(labelText: 'Specialty'),
                  onChanged: (value) {
                    editedDoctor['specialty'] = value;
                  },
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact'),
                  onChanged: (value) {
                    editedDoctor['contact'] = value;
                  },
                ),
                TextField(
                  controller: biographyController,
                  decoration: InputDecoration(labelText: 'Biography'),
                  onChanged: (value) {
                    editedDoctor['biography'] = value;
                  },
                ),
                TextField(
                  controller: qualificationsController,
                  decoration: InputDecoration(labelText: 'Qualifications'),
                  onChanged: (value) {
                    editedDoctor['qualifications'] = value;
                  },
                ),
                TextField(
                  controller: consultationTimesController,
                  decoration: InputDecoration(labelText: 'Consultation Times'),
                  onChanged: (value) {
                    editedDoctor['consultationTimes'] = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  doctors[index] = editedDoctor;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Doctor details updated'),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDoctor(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this doctor?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  doctors.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Doctor deleted'),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: lightWhite,
      body: Column(
        children: [
          Container(
            height: 110,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                offset: Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.blue),
                            onPressed: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: DashboardScreen(),
                                withNavBar: false,
                              );
                            },
                          ),
                        ),
                        Text(
                          "Medical Records",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
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
                                offset: Offset(0, 1), // changes position of shadow
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
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = doctors[index];
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(doctor['image']!),
                                ),
                                title: Text(doctor['name']!),
                                subtitle: Text(doctor['specialty']!),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editDoctor(index);
                                    } else if (value == 'delete') {
                                      _deleteDoctor(index);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['edit', 'delete'].map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(choice == 'edit' ? 'Edit' : 'Delete'),
                                      );
                                    }).toList();
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetailPage(doctor: doctor),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

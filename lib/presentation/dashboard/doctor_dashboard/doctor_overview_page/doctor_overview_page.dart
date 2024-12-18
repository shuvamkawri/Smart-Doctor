import 'package:flutter/material.dart';

class DoctorOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            SizedBox(height: 40,),
            // Top Section
            _buildTopSection(),
            SizedBox(height: 20.0),

            // Middle Section
            _buildMiddleSection(),
            SizedBox(height: 20.0),

            // Bottom Section
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60.0,
          backgroundImage: NetworkImage('https://t4.ftcdn.net/jpg/02/60/04/09/360_F_260040900_oO6YW1sHTnKxby4GcjCvtypUCWjnQRg5.jpg'),
        ),
        SizedBox(height: 10.0),
        Text(
          'Dr. Abhi, MD',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 24.0),
            Icon(Icons.star, color: Colors.yellow, size: 24.0),
            Icon(Icons.star, color: Colors.yellow, size: 24.0),
            Icon(Icons.star, color: Colors.yellow, size: 24.0),
            Icon(Icons.star_border, color: Colors.yellow, size: 24.0),
            SizedBox(width: 5.0),
            Text(
              '(123 Reviews)',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiddleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'About Me',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          'Dr. Abhi is a board-certified pediatrician with over 15 years of experience. He specializes in child healthcare and is passionate about providing compassionate care to all patients.',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 20.0),
        Text(
          'Conditions Treated',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildConditionChip('Fever'),
            _buildConditionChip('Allergies'),
            _buildConditionChip('Pediatric Care'),
            _buildConditionChip('Immunizations'),
          ],
        ),
        SizedBox(height: 20.0),
        Text(
          'Insurance Accepted',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        _buildInsuranceLogos(),
      ],
    );
  }

  Widget _buildConditionChip(String condition) {
    return Chip(
      label: Text(condition),
      backgroundColor: Colors.blueAccent,
      labelStyle: TextStyle(color: Colors.white),
    );
  }

  Widget _buildInsuranceLogos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.network('https://d1csarkz8obe9u.cloudfront.net/posterpreviews/insurance-company-logo-design-template-c4d9a50f19f47cda2623bab391df4193_screen.jpg?ts=1610149913', height: 60.0),
        Image.network('https://i.pinimg.com/736x/85/d8/54/85d8546d2c3a591cbbf5b64aad76efec.jpg', height: 60.0),
        Image.network('https://static.vecteezy.com/system/resources/previews/012/068/245/non_2x/insurance-logo-design-vector.jpg', height: 60.0),
        Image.network('https://cdn5.vectorstock.com/i/1000x1000/03/24/home-insurance-logo-vector-4700324.jpg', height: 60.0),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // Handle appointment booking
            // Replace with your navigation logic
          },
          child: Text('Book Appointment'),
        ),
        SizedBox(height: 10.0),
        Text(
          'Telehealth Availability: Available for telehealth consultations.',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 20.0),
        Text(
          'Patient Reviews',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        _buildReviewCard('Dr. Doe is amazing! He really cares about his patients.', '★★★★★'),
        SizedBox(height: 10.0),
        _buildReviewCard('Very knowledgeable and friendly. Highly recommended.', '★★★★☆'),
        SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () {
            // Navigate to view all reviews page
            // Replace with your navigation logic
          },
          child: Text('View All Reviews'),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String reviewText, String rating) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              reviewText,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  rating,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
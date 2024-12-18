import 'package:flutter/material.dart';

import '../../../../consts/colors.dart';
import '../../../../widgets/nav_drawer.dart';

class DoctorBillingInvoicing extends StatefulWidget {
  const DoctorBillingInvoicing({super.key});

  @override
  State<DoctorBillingInvoicing> createState() => _DoctorBillingInvoicingState();
}

class _DoctorBillingInvoicingState extends State<DoctorBillingInvoicing> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _billingItems = [];
  double _totalAmount = 0.0;

  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();
  String? _selectedPatient;

  final List<String> _patients = ['John Doe', 'Jane Smith', 'Alice Johnson']; // Example patients

  void _addItem() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _billingItems.add({
          'name': _itemNameController.text,
          'price': double.parse(_itemPriceController.text),
        });
        _totalAmount += double.parse(_itemPriceController.text);
        _itemNameController.clear();
        _itemPriceController.clear();
      });
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      backgroundColor: lightWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
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
                              icon: Icon(Icons.arrow_back, color: Colors.blue),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          // Page Title
                          Flexible(
                            child: Text(
                              "Billing",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Drawer Button
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
                  ],
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Patient',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedPatient,
                        items: _patients.map((String patient) {
                          return DropdownMenuItem<String>(
                            value: patient,
                            child: Text(patient),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPatient = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a patient';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      // Item Name Field
                      TextFormField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      // Item Price Field
                      TextFormField(
                        controller: _itemPriceController,
                        decoration: InputDecoration(
                          labelText: 'Item Price',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      // Add Item Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: Icon(Icons.add),
                          label: Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Billing Items List
                      ListView.builder(
                        shrinkWrap: true, // Ensures the ListView does not take up all the space
                        physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside this ListView
                        itemCount: _billingItems.length,
                        itemBuilder: (context, index) {
                          final item = _billingItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(item['name']),
                              trailing: Text(
                                '\$${item['price'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      // Total Amount Display
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total Amount: \$${_totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
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

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:rentalapp/screens/home_page.dart';

import '../utils/routers.dart';

class UserVerificationPage extends StatefulWidget {
  final String uid;
  final String pdi;

  const UserVerificationPage({Key? key, required this.uid, required this.pdi})
      : super(key: key);

  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _selectedDocument;
  LocationData? _currentLocation;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _aadharNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDocument() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedDocument = File(pickedFile.path);
      });
    }
  }

  Future<LocationData?> _getCurrentLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request location service
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // Request location permission
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get the current location
    return await location.getLocation();
  }

  String _dateRangeText = 'Select Date Range';
  Future<void> _selectDateRange(BuildContext context) async {
    final currentDate = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: currentDate,
      end: currentDate,
    );
    final selectedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: currentDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDateRange != null) {
      setState(() {
        _selectedDateRange = selectedDateRange;
        _dateRangeText =
            'Selected Date Range: ${selectedDateRange.start.toLocal().toString().split(' ')[0]} to ${selectedDateRange.end.toLocal().toString().split(' ')[0]}';
      });
    }
  }

  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      final locationData = await _getCurrentLocation();
      final latitude = locationData?.latitude;
      final longitude = locationData?.longitude;

      // Upload document image to Firebase Storage
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('verification_documents/${DateTime.now()}.jpg');
      final firebase_storage.UploadTask uploadTask =
          storageRef.putFile(_selectedDocument!);
      final firebase_storage.TaskSnapshot snapshot =
          await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Store verification details in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid; // Access the uid from the widget
        final ownerUid = widget.uid; // Print the UID for testing purposes
        final productUid = widget.pdi;
        print('UID: $ownerUid');
        print('PDI: $productUid');

        await FirebaseFirestore.instance.collection('verification').add({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text,
          'aadharNumber': _aadharNumberController.text,
          'email': _emailController.text,
          'documentUrl': downloadUrl,
          'latitude': latitude,
          'longitude': longitude,
          'status': 'Available',
          'dateRange': {
            'start': _selectedDateRange?.start,
            'end': _selectedDateRange?.end,
          },
          "uid": FirebaseAuth.instance.currentUser!.uid,
          'senduid': ownerUid,
          'pdi': productUid, // Store the product UID (pdi)
        });
      }

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verification Request Submitted'),
            content: Text(
                'Your verification request has been submitted successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  nextPageOnly(
                      context: context,
                      page: HomePage()); // Navigate to the desired page
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while submitting your verification request. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('User Verification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number.';
                    } else if (value.length != 10) {
                      return 'Phone number should be 10 digits.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your address.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _aadharNumberController,
                  decoration: InputDecoration(labelText: 'Aadhar Number'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Aadhar number.';
                    } else if (value.length != 12) {
                      return 'Aadhar number should be 12 digits.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email address.';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _selectDocument,
                  child: Text(
                    'Select Document',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    _dateRangeText,
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                _selectedDocument != null
                    ? Image.file(
                        _selectedDocument!,
                        height: 200.0,
                      )
                    : Container(),
                SizedBox(height: 16.0),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitVerificationRequest,
                        child: Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalapp/screens/products_Page.dart';
import 'package:rentalapp/screens/profile_Page.dart';
import 'package:rentalapp/screens/user_approve_page.dart';

import '../services/firebase_services.dart';
import '../utils/routers.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'login_page.dart';




class ApprovedPage extends StatefulWidget {
  final String verificationId;

  ApprovedPage({required this.verificationId});

  @override
  _ApprovedPageState createState() => _ApprovedPageState();
}

class _ApprovedPageState extends State<ApprovedPage> {
  bool isEditable = false;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Approved Product Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verification')
            .doc(widget.verificationId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Extract the necessary fields from the data
          final name = data['name'] as String?;
          final phoneNumber = data['phoneNumber'] as String?;
          final aadharNumber = data['aadharNumber'] as String?;
          final address = data['address'] as String?;
          final documentUrl = data['documentUrl'] as String?;
          final userId = FirebaseAuth.instance.currentUser!.uid;

          // Display the details with the desired UI
          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'Name: $name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Phone Number: $phoneNumber',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Aadhar Number: $aadharNumber',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Address: $address',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Image.network(
                  documentUrl ?? '',
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                if (isEditable)
                  Column(
                    children: [
                      TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          labelText: 'Comment',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Save the comment to Firestore
                          saveComment(userId, commentController.text);

                          // Disable editing after saving the comment
                          setState(() {
                            isEditable = false;
                          });
                        },
                        child: Text('Save Comment',
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditable = true;
                    });
                  },
                  child: Text('Edit Details',
                    style: TextStyle(fontSize: 15),),
                    style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),

                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void saveComment(String userId, String comment) {
    FirebaseFirestore.instance
        .collection('approved_products',
        )
        .doc(userId)
        .set({'comment': comment});
  }
}

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

class BookingRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              "R e n t o",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              "assets/drawer.svg",
              height: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Container(
                height: 2.0,
                width: 50,
                color: Colors.amber,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(
                "Home",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: HomePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text(
                "Products",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(
                  context: context,
                  page: ProductPage(
                    selectedCategory: "",
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text(
                "Cart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: const CartPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: true,
              onTap: () {
                nextPageOnly(context: context, page: const ProfileScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                "LogOut",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () async {
                await FirebaseServices().SignOut();
                nextPageOnly(context: context, page: const LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('verification').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs;

          if (docs == null || docs.isEmpty) {
            return const Center(
              child: Text(
                "",
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['name'] as String?;
              final phoneNumber = data['phoneNumber'] as String?;
              final aadharNumber = data['aadharNumber'] as String?;
              final address = data['address'] as String?;
              final documentUrl = data['documentUrl'] as String?;
               final sendUid = data['senduid'] as String?;
// Compare sendUid with the current user's UID
    // Compare sendUid with the current user's UID
 if (sendUid != FirebaseAuth.instance.currentUser!.uid) {
  // Skip this verification request if sendUid is not equal to the current user's UID
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100,),
          Text(
            'Uh-oh! Nothing to display',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SvgPicture.asset(
            "assets/lol.svg",
            height: 300,
          ),
        ],
      ),
    ),
  );
}
  
              return Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $name',
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone Number: $phoneNumber',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aadhar Number: $aadharNumber',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Address: $address',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Implement zoom functionality for the document image
                        
                      },
                      child: Image.network(
                        documentUrl ?? '',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Handle approval functionality
                        // You can update the status field in the verification collection to mark it as approved
                        final verificationId =
                            docs[index].id; // Get the verification document ID
                        approveVerification(context, verificationId);

                        // Navigate to the approved page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ApprovedPage(verificationId: verificationId),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          "Approve",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
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
          );
        },
      ),
    );
  }
}

void approveVerification(BuildContext context, String verificationId) async {
  try {
    // Check if the product is already approved
    final verificationSnapshot = await FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .get();

    final data = verificationSnapshot.data() as Map<String, dynamic>?;
    if (data != null && data['status'] == 'approved') {
      // Product is already approved, show a message or perform any desired action
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Already Approved'),
            content: const Text('This product is already approved.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Update the verification document in Firestore
    await FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .update({'status': 'approved'});

    // Get the user's ID
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Create a new document in the "approved_products" collection inside the user's collection
    await FirebaseFirestore.instance
        .collection(
            'your_approval') // Change "your_approval" to the desired collection name
        .doc(userId)
        .set({'verificationId': verificationId});

    // Show success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Approved'),
          content:
              const Text('The verification request has been approved successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Navigate to the approved page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovedPage(verificationId: verificationId),
      ),
    );
  } catch (error) {
    // Show error message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while approving the verification request. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

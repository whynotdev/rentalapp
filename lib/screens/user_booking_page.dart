import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalapp/pages/products_Page.dart';
import 'package:rentalapp/pages/profile_Page.dart';
import '../services/firebase_services.dart';
import '../utils/routers.dart';
import '../pages/cart_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';

class BookingRequestPage extends StatelessWidget {
  final TextEditingController commentController = TextEditingController();

  void showCommentDialog(BuildContext context, String verificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Enter your comment...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Save the comment to Firestore
                saveComment(verificationId, commentController.text);

                // Clear the text field after saving the comment
                commentController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void saveComment(String verificationId, String comment) {
    FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .update({'comment': comment});
  }

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
          final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

          // Filter verification requests based on the current user's UID
          final verificationRequests = docs?.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final sendUid = data['senduid'] as String?;
            return sendUid == currentUserUid;
          }).toList();

          if (verificationRequests == null || verificationRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
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
            );
          }

          return ListView.builder(
            itemCount: verificationRequests.length,
            itemBuilder: (BuildContext context, int index) {
              final data =
                  verificationRequests[index].data() as Map<String, dynamic>;
              final name = data['name'] as String?;
              final phoneNumber = data['phoneNumber'] as String?;
              final aadharNumber = data['aadharNumber'] as String?;
              final address = data['address'] as String?;
              final documentUrl = data['documentUrl'] as String?;
              final sendUid = data['senduid'] as String?;
              final email = data['email'] as String?;
              final dateRangeStart = (data['dateRange'] as Map?)
                  ?.cast<String, dynamic>()?['start'] as Timestamp?;
              final dateRangeEnd = (data['dateRange'] as Map?)
                  ?.cast<String, dynamic>()?['end'] as Timestamp?;
              final formattedStartDate = dateRangeStart != null
                  ? DateFormat('MMMM d, y')
                      .format(dateRangeStart.toDate().toLocal())
                  : 'Not Available';
              final formattedEndDate = dateRangeEnd != null
                  ? DateFormat('MMMM d, y')
                      .format(dateRangeEnd.toDate().toLocal())
                  : 'Not Available';
              // Compare sendUid with the current user's UID
              if (sendUid != FirebaseAuth.instance.currentUser!.uid) {
                // Skip this verification request if sendUid is not equal to the current user's UID
                return SizedBox();
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
                    Text(
                      'Email: $email',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Date Range: $formattedStartDate to $formattedEndDate',
                      style: const TextStyle(fontSize: 14),
                    ),
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
                    TextFormField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Enter Remark...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Handle approval functionality
                        final verificationId = verificationRequests[index]
                            .id; // Get the verification document ID
                        approveVerification(context, verificationId);
                        print(verificationId);
                        // Save the comment to Firestore
                        saveComment(verificationId, commentController.text);

                        // Clear the text field after saving the comment
                        commentController.clear();
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
                    SizedBox(height: 10),
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

    await FirebaseFirestore.instance
        .collection('rents')
        .doc(verificationId)
        .update({'status': 'approved'});

    // Show success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Approved'),
          content: const Text(
              'The verification request has been approved successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to the Profile page
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

void saveComment(String verificationId, String comment) {
  FirebaseFirestore.instance
      .collection('verification')
      .doc(verificationId)
      .update({'comment': comment});
}

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
  final TextEditingController remarkController = TextEditingController();
Future<void> cancelRequest(
  BuildContext context,
  String verificationId,
  String remarks,
) async {
  try {
    // Fetch the verification data
    final verificationSnapshot = await FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .get();

    if (!verificationSnapshot.exists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('The verification request was not found.'),
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

    // Get the "pdi" from the verification data
    final verificationData = verificationSnapshot.data() as Map<String, dynamic>?;
    final pdi = verificationData?['pdi'] as String?;

    if (pdi == null) {
      // "pdi" not found in verification data, handle the error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('The "pdi" value was not found in verification data.'),
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

    // Update the verification status to "Available"
    await FirebaseFirestore.instance
        .collection('verification')
        .doc(verificationId)
        .update({'status': 'Available'});

    // Update the "status" in the "rents" collection for the product with the matching "pdi"
    final rentsQuerySnapshot = await FirebaseFirestore.instance
        .collection('rents')
        .where('pdi', isEqualTo: pdi)
        .get();

    final rentsDocs = rentsQuerySnapshot.docs;
    if (rentsDocs.isNotEmpty) {
      final rentDocId = rentsDocs[0].id; // Assuming there's only one matching document
      await FirebaseFirestore.instance
          .collection('rents')
          .doc(rentDocId)
          .update({'status': 'Available'});
    }
// Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Request Cancelled'),
            content: const Text('The verification request has been cancelled.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Pops back to the previous screen
                },
              ),
            ],
          );
        },
      );

    // Rest of your cancellation logic...

  } catch (error) {
    // Show error message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred while cancelling the request. Please try again.'),
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


  final String approved = 'approved';
  final String notApproved = 'not approved';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
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
                  const SizedBox(height: 100),
                  const Text(
                    'Uh-oh! Nothing to display',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
              final borrowerId = data['uid']
                  as String?; // Fetching the "uid" field and naming it as "borrowerId"
              //  print('Borrower ID: $borrowerId');
              /* if (sendUid != FirebaseAuth.instance.currentUser!.uid) {
                return SizedBox();
              }*/
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
                      controller: remarkController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enter Remark...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final verificationId = verificationRequests[index].id;
                        final remark = remarkController.text;

                        if (remark.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Ayoo!'),
                                content: const Text(
                                    'Please enter a remark before proceeding.'),
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
                        final sendUid = data['senduid'] as String;
                        final borrowerId = data['uid'] as String;
                        approveVerification(context, verificationId);
                        saveRemark(verificationId, remark, sendUid, borrowerId,
                            approved); // Save the remark to Firestore
                        remarkController.clear();
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
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () async {
                        final verificationId = verificationRequests[index].id;
                        final remark = remarkController.text;
                        if (remark.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Ayyo!'),
                                content: const Text(
                                    'Please enter a remark before proceeding.'),
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

                        final sendUid = data['senduid'] as String;
                        final borrowerId = data['uid'] as String;
                        cancelRequest(context, verificationId, remark);
                        saveRemark(verificationId, remark, sendUid, borrowerId,
                            notApproved); // Save the remark to Firestore
                        remarkController.clear();
                      },
                      child: const Center(
                        child: Text(
                          "Cancel Request",
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
    // Update the status in the "rents" collection for the product with the matching "pdi"

    final verificationData =
        verificationSnapshot.data() as Map<String, dynamic>?;
    if (verificationData != null) {
      final pdi = verificationData['pdi'] as String?;

      if (pdi != null) {
        final rentsQuerySnapshot = await FirebaseFirestore.instance
            .collection('rents')
            .where('pdi', isEqualTo: pdi)
            .get();

        final rentsDocs = rentsQuerySnapshot.docs;
        if (rentsDocs.isNotEmpty) {
          final rentDocId =
              rentsDocs[0].id; // Assuming there's only one matching document
          await FirebaseFirestore.instance
              .collection('rents')
              .doc(rentDocId)
              .update({'status': 'approved'});
        }
      }
    }

    // Update the approvalStatus in the borrower collection
    await FirebaseFirestore.instance
        .collection('borrower')
        .doc(verificationId)
        .update({'approvalStatus': 'approved'});

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

// Add the saveRemark function to save the remark in Firestore
void saveRemark(String verificationId, String remark, String sendUid,
    String borrowerId, String approvalStatus) {
  FirebaseFirestore.instance.collection('borrower').add({
    'verificationId': verificationId,
    'remarks': remark,
    'uid': borrowerId,
    'senduid': sendUid,
    'approvalStatus': approvalStatus,
  });
}

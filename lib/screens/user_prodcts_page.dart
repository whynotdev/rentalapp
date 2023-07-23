import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentalapp/pages/products_Page.dart';
import 'package:rentalapp/screens/view_product_page.dart';
import 'package:rentalapp/pages/profile_Page.dart';
import 'package:rentalapp/services/firebase_services.dart';
import '../utils/routers.dart';
import '../pages/cart_page.dart';
import 'edit_product_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class YourProducts extends StatelessWidget {
  final String selectedCategory;

  YourProducts({required this.selectedCategory});

  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProductsStream(selectedCategory, currentUserUid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs;

          if (docs == null || docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Uh-oh! Nothing to display',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  SvgPicture.asset(
                    "assets/ghost.svg",
                    height: 300,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final id = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] as String?;
              final productName = data['productName'] as String?;
              final price = data['price'] as double?;
              final uploaderUid = data['uid'].toString();

              print(uploaderUid);
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: imageUrl != null
                          ? Center(
                              child: Image.network(imageUrl, fit: BoxFit.cover))
                          : Center(child: Text('Image not available')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        productName ?? 'Product Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        price != null
                            ? '\$${price.toStringAsFixed(2)}/day'
                            : 'Price not available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: 'Edit the product',
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              DocumentReference productRef = FirebaseFirestore
                                  .instance
                                  .collection('rents')
                                  .doc(id);

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProductPage(productRef: productRef),
                                ),
                              );
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Delete the product',
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.purple,
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confirm Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this product?',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection("rents")
                                              .doc(id)
                                              .delete();
                                          Navigator.of(context).pop();
                                          Fluttertoast.showToast(
                                            msg: 'Deleted successfully',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.grey[600],
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        },
                                      ),
                                    ],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 5,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewProducts(
                                productId: id,
                              ),
                            ),
                          );
                        },
                        child: Center(
                            child: Text(
                          'View Details',
                          style: TextStyle(fontSize: 15),
                        )),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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

  Stream<QuerySnapshot> getProductsStream(
      String selectedCategory, String currentUserUid) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('rents');

    if (selectedCategory.isNotEmpty) {
      return collection
          .where('type', isEqualTo: selectedCategory)
          .where('uid', isEqualTo: currentUserUid)
          .snapshots();
    } else {
      return collection.where('uid', isEqualTo: currentUserUid).snapshots();
    }
  }
}

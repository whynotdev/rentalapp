import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ViewIndividual extends StatefulWidget {
  const ViewIndividual({super.key, required this.data});
  
 final QueryDocumentSnapshot<Object?>? data;
  @override
  
  State<ViewIndividual> createState() => _ViewIndividualState();
}

class _ViewIndividualState extends State<ViewIndividual> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            
            children: [Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.data!.get('imageUrl') != null
                            ? Image.network(
                                widget.data!.get('imageUrl'),
                                fit: BoxFit.cover,
                              )
                            : Placeholder(fallbackHeight: 200),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Owner: ${widget.data!.get('ownerName') ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Product Name: ${widget.data!.get('productName') ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Price: \Rs${widget.data!.get('price')?.toStringAsFixed(2) ?? 'Unknown'}/day',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Description: ${widget.data!.get('description') ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Deposit: \Rs${widget.data!.get('deposit')?.toStringAsFixed(2) ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
        
                        // Add availability button //this temp
        
                        //add to cart button
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                addToCart(widget.data!.data() as Map<String, dynamic>
);
                              },
                              child: Text('Add to Cart'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
          ),
        ),
      ),

    );
  }
  void addToCart(Map<String, dynamic> product) {
    print(product['productId']);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final ownerUid = product['uid'];
      final cartItemsCollection = FirebaseFirestore.instance
          .collection('cartitems')
          .doc(userId)
          .collection('products');

      // Check if the product is already in the user's cart
      cartItemsCollection
          .where('productId', isEqualTo: product['productId'])
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // Product already exists in cart
          Fluttertoast.showToast(
            msg: "Product already exists in cart",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[600],
            textColor: Colors.black,
            fontSize: 16.0,
          );
        } else {
          // Check if the owner UID is the same as the current user UID
          if (ownerUid != userId) {
            // Add the product to the user's cart
            cartItemsCollection.add(product);
            Fluttertoast.showToast(
              msg: "Added Successfully to Cart",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[600],
              textColor: Colors.black,
              fontSize: 16.0,
            );
          } else {
            // The owner is the current user
            Fluttertoast.showToast(
              msg: "You are the owner of this product",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[600],
              textColor: Colors.black,
              fontSize: 16.0,
            );
          }
        }
      }).catchError((error) {
        // Error occurred while checking for product in cart
        Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[600],
          textColor: Colors.black,
          fontSize: 16.0,
        );
      });
    }
  }

}
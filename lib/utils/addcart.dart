import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void addToCart(Map<String, dynamic> product) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userId = user.uid;
    final ownerUid = product['uid'];
    final cartItemsCollection = FirebaseFirestore.instance
        .collection('cartitems')
        .doc(userId)
        .collection('products');

    final productId = product['productId'];

    // Query the cart items collection to check if a product with the same productId exists
    cartItemsCollection
        .where('productId', isEqualTo: productId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Product already exists in cart, show a message to the user
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

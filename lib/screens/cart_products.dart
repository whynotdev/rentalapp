import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentalapp/screens/cart_page.dart';
import '../services/firebase_services.dart';
import 'login.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({Key? key});

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('R e n t o'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () async {
              await FirebaseServices().SignOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProductsStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs;

          if (products == null || products.isEmpty) {
            return Center(child: Text('No products found'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final data = products[index].data() as Map<String, dynamic>;

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data['imageUrl'] != null
                        ? Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                          )
                        : Placeholder(fallbackHeight: 200),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Owner: ${data['ownerName'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Product Name: ${data['productName'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Price: \$${data['price']?.toStringAsFixed(2) ?? 'Unknown'}/month',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Description: ${data['description'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Deposit: \$${data['deposit']?.toStringAsFixed(2) ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    
                    //add to cart button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            addToCart(data);
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
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getProductsStream() {
    return FirebaseFirestore.instance.collection('rents').snapshots();
  }

  void addToCart(Map<String, dynamic> product) {
    FirebaseFirestore.instance.collection('cartitems').add(product);
    Fluttertoast.showToast(
      msg: "Added Succefully! to Cart",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}

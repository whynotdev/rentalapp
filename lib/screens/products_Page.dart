import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/screens/cart_products.dart';
import 'package:rentalapp/services/firebase_services.dart';
import 'login.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('R e n t o'),
        actions: [
                  IconButton(
                  icon: Icon(Icons.logout,
                  color: Colors.black,),
                  onPressed: () async{
                  await FirebaseServices().SignOut();
                  Navigator.push(context,
                   MaterialPageRoute(builder: (context) => LoginScreen(),));
                    
                  // TODO: Logout functionality here
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

          final docs = snapshot.data?.docs;

          if (docs == null || docs.isEmpty) {
            return Center(child: Text('No products found'));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] as String?;
              final productName = data['productName'] as String?;
              final price = data['price'] as double?;

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            )
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
                        price != null ? '\$${price.toStringAsFixed(2)}/month' : 'Price not available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle view details button click
                          // You can navigate to another page or show a dialog with the details
                          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProducts(),
                  ));

                          /*showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Product Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Product Name: ${productName ?? ''}'),
                                    SizedBox(height: 8),
                                    Text('Price: ${price != null ? '\$${price.toStringAsFixed(2)}/month' : 'N/A'}'),
                                    // Add more details as needed
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );*/
                        },
                        child: Text('View Details'),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
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

              return imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Center(child: Text('Image not available'));
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

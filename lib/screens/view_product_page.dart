import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/addcart.dart';

class ViewProducts extends StatefulWidget {
  final String productId;
  const ViewProducts({Key? key, required this.productId}) : super(key: key);

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('C a r t'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProductsStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs;

          if (products == null || products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final data = products[index].data() as Map<String, dynamic>;

                return Card(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        data['imageUrl'] != null
                            ? Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                              )
                            : const Placeholder(fallbackHeight: 200),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Owner: ${data['ownerName'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Product Name: ${data['productName'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Price: \Rs${data['price']?.toStringAsFixed(2) ?? 'Unknown'}/day',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Description: ${data['description'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Deposit: \Rs${data['deposit']?.toStringAsFixed(2) ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                addToCart(data);
                                //utils inside defined
                              },
                              child: const Text('Add to Cart'),
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('rents')
        .where(FieldPath.documentId, isEqualTo: widget.productId)
        .snapshots();
  }
}

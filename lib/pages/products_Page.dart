import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentalapp/screens/view_product_page.dart';
import 'package:rentalapp/pages/profile_Page.dart';
import 'package:rentalapp/services/firebase_services.dart';
import '../utils/routers.dart';
import 'cart_page.dart';
import '../screens/edit_product_page.dart';
import '../screens/home_page.dart';
import '../screens/login_page.dart';

class ProductPage extends StatelessWidget {
  final String selectedCategory;

  ProductPage({required this.selectedCategory});

  String currUSer = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        centerTitle: true,
        title: Text('P r o d u c t s'),
        //automaticallyImplyLeading: false,
        /* actions: [
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
                  ));

              // TODO: Logout functionality here
            },
          ),
        ],*/
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "R e n t o",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              "assets/drawer3.svg",
              height: 200,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Container(
                height: 2.0,
                width: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                "Home",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: HomePage());
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(
                "Products",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: true,
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
              leading: Icon(Icons.shopping_basket),
              title: Text(
                "Cart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: CartPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: ProfileScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                "LogOut",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: false,
              onTap: () async {
                await FirebaseServices().SignOut();
                nextPageOnly(context: context, page: LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProductsStream(selectedCategory),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs;

          CollectionReference dr =
              FirebaseFirestore.instance.collection("rents");

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
                    "assets/ghost2.svg",
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
              final status = data['status'] as String? ?? 'Available';
              final ownerName = data['ownerName'] as String?;
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
                            ? '\Rs${price.toStringAsFixed(2)}/day'
                            : 'Price not available',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ownerName ?? 'Owner Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              status == 'Available' ? Colors.green : Colors.red,
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Edit and delete icons
                    //if (true) // Replace this condition with your logic to determine if the user can edit/delete the product
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        uploaderUid == currUSer
                            ? Tooltip(
                                message: 'Edit the product',
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    // Get the document reference for the product
                                    DocumentReference productRef =
                                        FirebaseFirestore.instance
                                            .collection('rents')
                                            .doc(id);

                                    // Navigate to the edit product page and pass the product reference
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductPage(
                                            productRef: productRef),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(),
                        //ternary operator
                        uploaderUid == currUSer
                            ? Tooltip(
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
                                                  //color: Colors.grey,
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
                                                  //  color: Colors.red,
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
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                              },
                                            ),
                                          ],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 5,
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle view details button click
                          String productId =
                              id; // Get the productId from the current product's id
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewProducts(productId: productId),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'Detailed view',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
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

  Stream<QuerySnapshot> getProductsStream(String selectedCategory) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('rents');

    if (selectedCategory.isNotEmpty) {
      return collection.where('type', isEqualTo: selectedCategory).snapshots();
    } else {
      return collection.snapshots();
    }
  }
}

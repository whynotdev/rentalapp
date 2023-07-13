import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalapp/screens/user_verification_page.dart';
import 'package:rentalapp/screens/view_product_page.dart';
import 'package:rentalapp/screens/login_page.dart';
import 'package:rentalapp/screens/payment_page.dart';
import 'package:rentalapp/screens/products_Page.dart';
import 'package:rentalapp/screens/profile_Page.dart';
import 'package:rentalapp/services/firebase_services.dart';
import '../utils/routers.dart';
import 'home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> cartItems = [];
    

  @override
  void initState() {
    super.initState();
    getCartItems();
  }

  void getCartItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final cartItemsCollection = _firestore
            .collection('cartitems')
            .doc(userId)
            .collection('products');

        QuerySnapshot cartSnapshot = await cartItemsCollection.get();

        List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final id = doc.id;
          final uid = data['uid']; // Fetch the uid field from the document
          print('Product UID: $uid'); // Print the UID for testing purposes
          return {...data, 'id': id};
        }).toList();

        setState(() {
          cartItems = items;
        });
      }
    } catch (error) {
      print('Error retrieving cart items: $error');
    }
  }

  void _removeFromCart(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final cartItemsCollection =
          _firestore.collection('cartitems').doc(userId).collection('products');
      final cartItemDoc = cartItemsCollection.doc(productId);
      cartItemDoc.delete();

      setState(() {
        cartItems.removeWhere((item) => item['id'] == productId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('R e n t o'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseServices().SignOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
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
              "assets/drawer.svg",
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
                color: Colors.amber,
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
              leading: Icon(Icons.shopping_basket),
              title: Text(
                "Cart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              selected: true,
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
        // Drawer content
        // ...
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/Empty.svg",
                    width: 250,
                    height: 300,
                  ),
                  SizedBox(height: 30),
                  Text(
                    " Oops! Your cart is empty.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      nextPageOnly(context: context, page: ViewProducts());
                    },
                    child: Text('Go back to products'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final product = cartItems[index];
                final ownerName = product['ownerName'] as String?;
                final productName = product['productName'] as String?;
                final price = product['price'] as double?;
                //  final description = product['description'] as String?;
                final deposit = product['deposit'] as double?;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text(productName ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Owner: ${ownerName ?? ''}'),
                          Text('Price: \Rs${price ?? ''}/day'),
                          // Text('Description: ${description ?? ''}'),
                          Text('Deposit: \$${deposit ?? ''}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _removeFromCart(product['id']);
                            },
                            child: Text('Remove'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _showBuyDialog(index);
                            },
                            child: Text('Request'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showBuyDialog(int currentIndex) {
  final selectedProduct = cartItems[currentIndex];
  final productUid = selectedProduct['uid'] as String?;
  print('Product UID: $productUid'); // Print the UID for testing purposes

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Requesting product for Booking!'),
        actions: [
          TextButton(
            onPressed: () {
              if (productUid != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserVerificationPage(uid: productUid),
                  ),
                );
              }
            },
            child: Text('Send a Request'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

}

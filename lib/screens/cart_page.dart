import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalapp/screens/login.dart';
import 'package:rentalapp/services/firebase_services.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> cartItems = []; // Example cart items, replace it with your own cart items

  @override
  void initState() {
    super.initState();
    getCartItems();
  }
  void getCartItems() async {
    try {
      // Retrieve cart items from Firestore
      QuerySnapshot cartSnapshot =
          await FirebaseFirestore.instance.collection('cartitems').get();
      
      // Convert documents to cart items list
      List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) => doc.data()! as Map<String, dynamic>).toList();


      setState(() {
        cartItems = items;
      });
    } catch (error) {
      print('Error retrieving cart items: $error');
    }
  }
  //temporary removing has to change
  void _removeFromCart(int index) {
  setState(() {
    cartItems.removeAt(index); // Remove the item from the cartItems list
  });
}

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('R e n t o'),
          automaticallyImplyLeading: false, // This line removes the back button
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/Empty_cart.svg",
              width: 250,height: 300,),
                          /* Image.asset(
                              "assets/emty-cart.png",
                width: 350,
                height: 400,
                fit: BoxFit.fill,
                                       ),*/
              SizedBox(height: 30),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go back to products'),
                
              ),
            ],
          ),
        ),
      );
    }

    double totalPrice = 0;
    double totalDeposit = 0;

    for (var item in cartItems) {
      totalPrice += item['price'] as double;
      totalDeposit += item['deposit'] as double;
    }

    return Scaffold(
      appBar: AppBar(
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
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (BuildContext context, int index) {
          final product = cartItems[index];
          final ownerName = product['ownerName'] as String?;
          final productName = product['productName'] as String?;
          final price = product['price'] as double?;
          final description = product['description'] as String?;
          final deposit = product['deposit'] as double?;

          return Card(
            child: ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(productName ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Owner: ${ownerName ?? ''}'),
                  Text('Price: \$${price ?? ''}/month'),
                  Text('Description: ${description ?? ''}'),
                  Text('Deposit: \$${deposit ?? ''}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implement remove from cart functionality
                  _removeFromCart(index); //change in upcoming
                },
                child: Text('Remove'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              _showBuyDialog(totalPrice, totalDeposit);
            },
            child: Text('Buy Now'),
          ),
        ),
      ],
    );
  }

  void _showBuyDialog(double totalPrice, double totalDeposit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
              Text('Total Deposit: \$${totalDeposit.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Handle payment processing
              },
              child: Text('Proceed to Payment'),
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

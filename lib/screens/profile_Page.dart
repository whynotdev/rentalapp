import 'package:flutter/material.dart';
import 'package:rentalapp/screens/home_page.dart';
import 'package:rentalapp/screens/products_Page.dart';

import '../services/firebase_services.dart';
import 'cart_page.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _firstLetter = '';
  int _selectedIndex = 0;

  final TextEditingController _nameController = TextEditingController();

  final List<Widget> _pages = [
    HomePage(),
    ProductPage(),    
    CartPage(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Card(
              elevation: 5,
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: CircleAvatar(
                radius: 70,
                child: Text(
                  _firstLetter,
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Hi, $_name',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Enter your name'),
                    content: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                          _firstLetter = value.isNotEmpty
                              ? value.substring(0, 1).toUpperCase()
                              : '';
                        });
                      },
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Edit Name'),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),

      //navigation bar
/*
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor:
            Colors.black, // <-- Set unselected item color to black
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            // Navigate to the ProfileScreen when the profile icon is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
      ),*/
    );
  }
}

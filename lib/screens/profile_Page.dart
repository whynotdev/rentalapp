import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        ],
      ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: SvgPicture.asset("assets/profile_data.svg",
        width: 200,height: 200,
        ),
      ),

      //navigation bar

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
      ),
    );
  }
}

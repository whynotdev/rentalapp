import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalapp/screens/home_page.dart';
import 'package:rentalapp/screens/products_Page.dart';
import 'package:rentalapp/screens/user_booking_page.dart';
import 'package:rentalapp/screens/user_prodcts_page.dart';
import 'package:rentalapp/screens/user_profile_page.dart';

import '../services/firebase_services.dart';
import '../utils/routers.dart';
import 'cart_page.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
String userName = '';

  final List<Widget> _pages = [
    HomePage(),
    ProductPage(selectedCategory: ''),
    CartPage(),
    ProfileScreen(),
  ];

  void _navigateToPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _pages[index],
      ),
    );
  }
  Future<void> fetchUserProfileData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    final profileSnapshot = await FirebaseFirestore.instance
        .collection('userprofile')
        .doc(uid)
        .get();

    final profileData = profileSnapshot.data();
    if (profileData != null) {
      setState(() {
        userName = profileData['name'] ?? '';
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text("Home",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: HomePage());
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Products",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
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
              title: Text("Cart",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              selected: false,
              onTap: () {
                nextPageOnly(context: context, page: CartPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              selected: true,
              onTap: () {
                nextPageOnly(context: context, page: ProfileScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("LogOut",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              selected: false,
              onTap: () async {
                await FirebaseServices().SignOut();
                nextPageOnly(context: context, page: LoginScreen());
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
              "P r o f i l e",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
          
 SizedBox(height: 30),
Text(
  userName.isNotEmpty ? 'Hi $userName' : 'Hi',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

          SvgPicture.asset("assets/profile79.svg",
          height: 200,),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                leading: Icon(
                  Icons.person,
                  color: Colors.amber,
                ),
                title: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 18,
                ),
                onTap: () {
                   nextPageOnly(context: context, page: UserProfilePage());
                  // Navigate to Profile page
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                leading: Icon(
                  Icons.home,
                  color: Colors.amber,
                ),
                title: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Your Products",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 18,
                ),
                onTap: () {
                   nextPageOnly(context: context, page:YourProducts(selectedCategory: ""));// Navigate to "Your Products" page
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                leading: Icon(
                  Icons.bookmark,
                  color: Colors.amber,
                ),
                title: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Booking Requests",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 18,
                ),
                onTap: () {
                  // Navigate to "Booking Requests" page

                   nextPageOnly(context: context, page: BookingRequestPage());
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                leading: Icon(
                  Icons.shopping_cart,
                  color: Colors.amber,
                ),
                title: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Approved Products",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 18,
                ),
                onTap: () {
                  // Navigate to "Approved Products" page
                   nextPageOnly(context: context, page: BookingRequestPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

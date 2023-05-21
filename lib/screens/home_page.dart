import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentalapp/screens/cart_page.dart';
import 'package:rentalapp/screens/login.dart';
import 'package:rentalapp/screens/products_Page.dart';
import 'package:rentalapp/screens/profile_Page.dart';
import 'package:rentalapp/services/firebase_services.dart';
import '../helperWidget/category.dart';
import 'rent_page.dart';
import 'borrow_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Load the images from the assets folder
  List<AssetImage> images = [
    AssetImage('assets/adv3.png'),
    AssetImage('assets/adv2.png'),
    AssetImage('assets/adv4.png'),
    AssetImage('assets/adv5.png'),
  ];

  final List<Widget> _pages = [
    HomePage(),
    ProductPage(),    
    //CartPage(),    
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
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          // Add the CarouselSlider widget to the homepage
          CarouselSlider(
            options: CarouselOptions(
              height: 210,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              enlargeCenterPage: true,
            ),
            items: images.map((image) {
              return Container(
                margin: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                    width: 1150,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          //categories diplay on top to product categories
        Container(
  padding: EdgeInsets.symmetric(vertical: 10),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: CategoryWidget(category: categories[0])),
          Expanded(child: CategoryWidget(category: categories[1])),
          Expanded(child: CategoryWidget(category: categories[2])),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: CategoryWidget(category: categories[3])),
          Expanded(child: CategoryWidget(category: categories[4])),
          Expanded(child: CategoryWidget(category: categories[5])),
        ],
      ),
    ],
  ),
),


        SizedBox(height: 20),
          // Rent Now button
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.amber,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      
                      // Navigate to the RentPage when the button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RentPage()),
                      );
                    },
                    child: Text(
                      "Rent Yours Now !",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      primary: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
  unselectedItemColor: Colors.black,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to the HomePage when the home icon is pressed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      // Navigate to the ProductPage when the products icon is pressed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductPage()),
      );
    } else if (index == 2) {
      // Navigate to the CartPage when the cart icon is pressed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      );
    } else if (index == 3) {
      // Navigate to the ProfileScreen when the profile icon is pressed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  },
),

    );
  }
}

  
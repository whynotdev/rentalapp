import 'package:flutter/material.dart';
import '../screens/products_Page.dart';

class Category {
  final String name;
  final String imagePath;

  Category({required this.name, required this.imagePath});
}

List<Category> categories = [
  Category(name: 'Gears', imagePath: 'assets/ctgry5.png'),
  Category(name: 'DSLRs', imagePath: 'assets/ctgry3.jpg'),
  Category(name: 'Laptops', imagePath: 'assets/ctgry2.png'),
  Category(name: 'Music', imagePath: 'assets/ctgry4.jpg'),
  Category(name: 'SmartPhones', imagePath: 'assets/ctgry1.jpg'),
  Category(name: 'Others', imagePath: 'assets/ctgry6.png'),
];

class CategoryWidget extends StatelessWidget {
  final Category category;

  CategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ProductsPage with the category name
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(/*category: category.name*/),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: 100,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(category.imagePath),
              height: 70,
              width: 70,
            ),
            SizedBox(height: 10),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryGroup extends StatelessWidget {
  final List<Category> categories;

  CategoryGroup({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: GridView.count(
          crossAxisCount: 2,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: categories
              .map((category) => CategoryWidget(category: category))
              .toList(),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProductPage extends StatefulWidget {
  final DocumentReference productRef;

  EditProductPage({required this.productRef});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _depositController = TextEditingController();

  String? _selectedType;

  @override
  void initState() {
    super.initState();

    // Retrieve the current product data from Firestore and populate the text fields
    widget.productRef.get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _productNameController.text = snapshot['productName'] ?? '';
          _priceController.text = (snapshot['price'] ?? 0).toString();
          _descriptionController.text = snapshot['description'] ?? '';
          _depositController.text = (snapshot['deposit'] ?? 0).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('E d i t   P r o d u c t'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productNameController.text = value!;
                },
                controller: _productNameController,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _priceController.text = value!;
                },
                controller: _priceController,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  if (value.trim().length > 200) {
                    return 'Maximum character limit (including spaces) exceeded';
                  }
                  return null;
                },
                onSaved: (value) {
                  _descriptionController.text = value!;
                },
                controller: _descriptionController,
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Deposit',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the deposit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid deposit';
                  }
                  return null;
                },
                onSaved: (value) {
                  _depositController.text = value!;
                },
                controller: _depositController,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Update the product details in Firestore
                      updateProduct();
                    },
                    child: Text('Save Changes'),
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
      ),
    );
  }

  void updateProduct() async {
    String productName = _productNameController.text.trim();
    double price = double.parse(_priceController.text.trim());
    String description = _descriptionController.text.trim();
    double deposit = double.parse(_depositController.text.trim());
    String type;
    _selectedType;
    try {
      await widget.productRef.update({
        'productName': productName,
        'price': price,
        'description': description,
        'deposit': deposit,
      });

      Fluttertoast.showToast(
        msg: 'Product updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to update product',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

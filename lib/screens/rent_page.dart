import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RentPage extends StatefulWidget {
  const RentPage({Key? key}) : super(key: key);

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _depositController = TextEditingController();

  List<File?> _selectedImages = [];

  File? _image;

  void _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("R e n t o"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the owner name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _ownerNameController.text = value!;
                  },
                  controller: _ownerNameController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _descriptionController.text = value!;
                  },
                  controller: _descriptionController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
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
                SizedBox(
                  height: 05,
                ),
                //Upload Images button
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: GestureDetector(
                      onTap: () async {
                        final source = await showDialog<ImageSource>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Select image!"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, ImageSource.camera),
                                child: Text("Camera"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, ImageSource.gallery),
                                child: Text("Album"),
                              ),
                            ],
                          ),
                        );
                        if (source != null) {
                          _getImage(source);
                        }
                      },
                      child: Center(
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_rounded,
                                    color: Colors.amber,
                                    size: 36.0,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Upload image!",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 05),
                //Submit button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        try {
                          // Upload the image to Firebase Storage
                          if (_image != null) {
                            Reference ref = FirebaseStorage.instance
                                .ref()
                                .child('rents')
                                .child(DateTime.now().toString());
                            UploadTask uploadTask = ref.putFile(_image!);
                            TaskSnapshot taskSnapshot =
                                await uploadTask.whenComplete(() => null);
                            String imageUrl =
                                await taskSnapshot.ref.getDownloadURL();

                            // Save the data to Firestore
                            await FirebaseFirestore.instance
                                .collection('rents')
                                .add({
                              'ownerName': _ownerNameController.text,
                              'productName': _productNameController.text,
                              'price': double.parse(_priceController.text),
                              'description': _descriptionController.text,
                              'deposit': double.parse(_depositController.text),
                              'imageUrl': imageUrl,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rent data submitted'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Clear the text fields and image
                            _ownerNameController.clear();
                            _productNameController.clear();
                            _priceController.clear();
                            _descriptionController.clear();
                            _depositController.clear();
                            setState(() {
                              _image = null;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select an image'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          print(e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to submit rent data'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(200, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

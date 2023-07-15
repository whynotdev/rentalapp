import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentalapp/screens/home_page.dart';

import '../utils/routers.dart';

class RentPage extends StatefulWidget {
  const RentPage({Key? key}) : super(key: key);

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final _formKey = GlobalKey<FormState>(); //for validation

  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _depositController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  List<File?> _selectedImages = []; //selecting images

  File? _image;
  String? _selectedType; //Type_Declartion
  //function call for get image
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
        centerTitle: true,
        title: const Text("R e n t o"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //textfield for name
                TextFormField(
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16.0),

                //Get product name field
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
                const SizedBox(height: 16.0),
                //Get price field
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
                const SizedBox(height: 16.0),
                //Get deposit field

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
                //Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: 'Film & Photography',
                      child: Text('Film & Photography'),
                    ),
                    DropdownMenuItem(
                      value: 'Laptop',
                      child: Text('Laptop'),
                    ),
                    DropdownMenuItem(
                      value: 'Musical Inst',
                      child: Text('Musical Instrument '),
                    ),
                    DropdownMenuItem(
                      value: 'Drone',
                      child: Text('Drone'),
                    ),
                    DropdownMenuItem(
                      value: 'Electronic',
                      child: Text('Electronics'),
                    ),
                    DropdownMenuItem(
                      value: 'Lenses',
                      child: Text('Lenses'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16.0),
                //Get description of product

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

                const SizedBox(
                  height: 10,
                ),

              /*  TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contact No',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please provide contact details";
                    }

                    // Regular expression pattern for Indian mobile numbers
                    final RegExp mobileRegExp = RegExp(r'^[6-9]\d{9}$');

                    if (!mobileRegExp.hasMatch(value)) {
                      return "Please enter a valid mobile number";
                    }
                  },
                  onSaved: (Value) {
                    _contactController.text = Value!;
                  },
                  controller: _contactController,
                ),*/
                  SizedBox(height: 10,),
                
                  
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
                            title: const Text("Select image!"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, ImageSource.camera),
                                child: const Text("Camera"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, ImageSource.gallery),
                                child: const Text("Album"),
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
                                children: const [
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
                const SizedBox(height: 05),

                //Submit button of all fields to Firestore
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
                              'type': _selectedType,
                              'usrcontact': _contactController.text,
                              'imageUrl': imageUrl,
                              "uid": FirebaseAuth.instance.currentUser!.uid,
                              'status': 'Available',
                            }).whenComplete(() => nextPageOnly(
                                    context: context, page: HomePage()));

                            Fluttertoast.showToast(
                              msg: 'Succefully! submitted',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.grey[600],
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Please select an image',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[600],
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        } catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(
                            msg: 'Failed to submit rent data',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(200, 50),
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

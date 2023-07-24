import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../services/firebase_services.dart';
import '../utils/routers.dart';
import '../pages/cart_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import '../pages/products_Page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  String imageUrl = '';
  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
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
          _nameController.text = profileData['name'] ?? '';
          _aboutController.text = profileData['about'] ?? '';
          _phoneController.text = profileData['phone'] ?? '';
          _locationController.text = profileData['location'] ?? '';
          imageUrl = profileData['profileImage'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<String> uploadProfileImage(File image) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final storage = firebase_storage.FirebaseStorage.instance;

    if (uid != null) {
      final storageRef = storage.ref().child('user_profile_images/$uid.jpg');
      final uploadTask = storageRef.putFile(image);

      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == firebase_storage.TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();
        return downloadURL;
      } else {
        // Handle error during image upload
        throw 'Image upload failed. Please try again.';
      }
    } else {
      // User is not authenticated
      throw 'User is not authenticated. Please log in again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Select Image"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text("Camera"),
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Gallery"),
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : AssetImage('assets/profile.png')) as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _aboutController,
                decoration: InputDecoration(
                  labelText: 'About',
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_image != null) {
                  // Show a loading indicator while saving the profile
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    // Call a function to upload and save the image
                    final imageUrl = await uploadProfileImage(_image!);

                    // Update the profile data in Firestore
                    final uid = FirebaseAuth.instance.currentUser?.uid;

                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('userprofile')
                          .doc(uid)
                          .set({
                        'profileImage': imageUrl,
                        'name': _nameController.text,
                        'about': _aboutController.text,
                        'phone': _phoneController.text,
                        'location': _locationController.text,
                      }, SetOptions(merge: true));

                      // Reset the _image variable to null after successful upload
                      setState(() {
                        _image = null;
                      });

                      // Show a toast/notification indicating profile update success
                      Fluttertoast.showToast(
                        msg: 'Profile updated successfully',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  } catch (error) {
                    // Handle error during profile update
                    Fluttertoast.showToast(
                      msg: 'An error occurred. Please try again.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } finally {
                    // Hide the loading indicator
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } else {
                  // Handle case when no image is selected
                }
              },
              child: Text(
                'Save Profile',
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Future<String> uploadProfileImage(File image) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final storage = firebase_storage.FirebaseStorage.instance;

  if (uid != null) {
    final storageRef = storage.ref().child('user_profile_images/$uid.jpg');
    final uploadTask = storageRef.putFile(image);

    final snapshot = await uploadTask.whenComplete(() {});
    if (snapshot.state == firebase_storage.TaskState.success) {
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } else {
      // Handle error during image upload
      throw 'Image upload failed. Please try again.';
    }
  } else {
    // User is not authenticated
    throw 'User is not authenticated. Please log in again.';
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/homepage.dart';

import 'package:glint/utils/sharedpreffs.dart';
import 'package:image_picker/image_picker.dart';

class UserinfoScreen extends StatefulWidget {
  const UserinfoScreen({super.key, required this.verifiedPhonenumber});
  final String verifiedPhonenumber;

  @override
  State<UserinfoScreen> createState() => _UserinfoScreenState();
}

class _UserinfoScreenState extends State<UserinfoScreen> {
  String initValue = "Select your Birth Date";
  bool isDateSelected = false;
  DateTime birthDate = DateTime.now();
  String birthDateInString = DateTime.now().toString();

  final TextEditingController namecontroller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    namecontroller.dispose();
  }

  Color beige = const Color(0xFFF7F2E7);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: beige,
        automaticallyImplyLeading: false,
        title: Center(
            child: Text(
          'Glint.',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        )),
      ),
      backgroundColor: beige,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Tell us about you',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 50.h,
                ),
                const Text('What you Look Like'),
                SizedBox(
                  height: 20.h,
                ),
                GestureDetector(
                  onTap: _showPickerOptions,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : AssetImage('assets/OIP.jpeg') as ImageProvider,
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                const Text('What\'s your friends call you'),
                TextField(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                  controller: namecontroller,
                  decoration: InputDecoration(
                      hintText: 'First Name',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                      border: InputBorder.none),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text('Enter your Birthday'),
                GestureDetector(
                    child: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final datePick = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                      if (datePick != null && datePick != birthDate) {
                        setState(() {
                          birthDate = datePick;
                          isDateSelected = true;
                          birthDateInString =
                              "${birthDate.month}/${birthDate.day}/${birthDate.year}";
                        });
                      }
                    }),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  birthDateInString.length > 11 ? '' : birthDateInString,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 100.h,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 135.w, vertical: 12.h),
                        elevation: 0,
                        backgroundColor: Colors.lightBlue[200],
                        foregroundColor: Colors.black),
                    onPressed: () async {
                      String userid = await addUserToFirestore();

                      uploadProfilePicture(_imageFile!, userid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Homepage(
                                  phoneNumberToUseAsUserId:
                                      widget.verifiedPhonenumber,
                                  username: namecontroller.text,
                                  userGroups: [],
                                  userid: userid,
                                )),
                      );
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  addUserToFirestore() async {
    String name = namecontroller.text.trim();
    String dateOfbirth = birthDateInString;

    if (name.isNotEmpty && dateOfbirth.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').add({
          'name': name,
          'Birthdate': dateOfbirth,
          'Verified PhoneNumber': widget.verifiedPhonenumber
        });
        await UserPreferences.setUserDetails(
            name, widget.verifiedPhonenumber, '');
      } catch (e) {
        print(e);
      }
    }
    String? documentId =
        await getDocumentIdByuserPhone(widget.verifiedPhonenumber);
    return documentId;
  }

  Future<String?> getDocumentIdByuserPhone(String userPhone) async {
    try {
      // Query the 'groups' collection for a document with the specific group name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Verified PhoneNumber', isEqualTo: userPhone)
          .get();

      // Check if the document exists in the query result
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document and retrieve its ID
        String documentId = querySnapshot.docs.first.id;
        return documentId;
      } else {
        print('No document found with the specified group name.');
        return null; // No document found
      }
    } catch (e) {
      print('Error retrieving document ID: $e');
      return null;
    }
  }

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  //to pick the image

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  //to show user the source of picking image

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

//upload pic to database

  Future<void> uploadProfilePicture(File imageFile, String userid) async {
    try {
      // Step 1: Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('userProfilePictures')
          .child('$userid.jpg'); // Save as `groupId.jpg`

      await storageRef.putFile(imageFile);

      // Step 2: Get the download URL
      final userprofilePictureUrl = await storageRef.getDownloadURL();

      // Step 3: Save the URL in the group document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userid).update({
        'userprofilePictureUrl': userprofilePictureUrl,
      });

      print("Profile picture uploaded and URL saved successfully.");
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }
}

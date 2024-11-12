import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/onbordeing.dart';
import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/builUserProfilePics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSettings extends StatefulWidget {
  final String name;
  final String phone;
  final String userid;

  const ScreenSettings(
      {super.key,
      required this.name,
      required this.phone,
      required this.userid});

  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: beige,
        title: const Center(
            child: Text(
          'Profile',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        )),
      ),
      backgroundColor: beige,
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Stack(children: [
                SizedBox(
                    height: 100.h,
                    width: 100.h,
                    child: BuilUserProfilePics(
                      userid: widget.userid,
                    )),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                        width: 25.h,
                        height: 25.h,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100)),
                        child: const Icon(Icons.edit)))
              ]),
              SizedBox(
                height: 20.h,
              ),
              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(17)),
              //         padding:
              //             EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
              //         elevation: 0,
              //         backgroundColor: Colors.lightBlue[200],
              //         foregroundColor: Colors.black),
              //     onPressed: () {
              //       uploadProfilePicture(_imageFile!, widget.userid);
              //       Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) =>
              //                 SplashScreen(phonenumberToCheck: widget.phone),
              //           ));
              //     },
              //     child: const Text('Apply')),
              Text(
                'Name:${widget.name}',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Phone:${widget.phone}',
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 200.h,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 150.w, vertical: 12.h),
                      elevation: 0,
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    logout();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onbordeing(),
                        ));
                  },
                  child: const Text('LogOut'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    FirebaseAuth.instance.signOut();
  }

  //Code for uploading profile pic

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
      const SnackBar(
        content: Text('No images selected'),
      );
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
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
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
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  Future<void> changeGroupName(String groupid, String newgroupname) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupid).update({
      'Groupname': newgroupname,
    });
  }
}

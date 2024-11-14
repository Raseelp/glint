import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/SettingsPages/appSettings.dart';

import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/builUserProfilePics.dart';
import 'package:glint/utils/colorPallet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSettings extends StatefulWidget {
  final String name;
  final String phone;
  final String userid;
  final List<Map<String, dynamic>> usergroups;

  const ScreenSettings(
      {super.key,
      required this.name,
      required this.phone,
      required this.userid,
      required this.usergroups});

  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: widget.name);

    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Appsettings(
                        userphone: widget.phone,
                        userId: widget.userid,
                        userGroups: widget.usergroups,
                      ),
                    ));
              },
              icon: const Icon(
                Icons.settings,
                color: AppColors.whiteText,
              ))
        ],
        backgroundColor: AppColors.secondaryBackground,
        title: const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Center(
              child: Text(
            'Profile',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteText),
          )),
        ),
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
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
                    child: GestureDetector(
                      onTap: () {
                        _showPickerOptions();
                      },
                      child: Container(
                        width: 25.h,
                        height: 25.h,
                        decoration: BoxDecoration(
                          color: AppColors.mediumLightGray,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child:
                            const Icon(Icons.edit, color: AppColors.whiteText),
                      ),
                    ),
                  )
                ]),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  width: 400,
                  height: 150,
                  decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(17)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                                color: AppColors.lightGrayText, fontSize: 30),
                            controller: nameController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: widget.name,
                                hintStyle: const TextStyle(
                                    color: AppColors.lightGrayText,
                                    fontSize: 30),
                                border: InputBorder.none),
                          ),
                        ),
                        Text(
                          widget.phone,
                          style: const TextStyle(
                              color: AppColors.lightGrayText, fontSize: 25),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 220.h,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 150.w, vertical: 12.h),
                        elevation: 0,
                        backgroundColor: AppColors.blurple,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      if (_imageFile != null) {
                        uploadProfilePicture(_imageFile!, widget.userid);
                      } else {
                        print('nullll');
                      }

                      changeUserName(widget.userid, widget.phone,
                          nameController.text, widget.usergroups);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SplashScreen(phonenumberToCheck: widget.phone),
                          ));
                    },
                    child: const Text('Apply')),
              ],
            ),
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

  Future<void> changeUserName(String userid, String userPhone,
      String newusername, List<Map<String, dynamic>> usergroups) async {
    await FirebaseFirestore.instance.collection('users').doc(userid).update({
      'name': newusername,
    });

    for (var group in usergroups) {
      String groupId = group['id'];

      DocumentReference groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      try {
        // Step 1: Get the current members array
        DocumentSnapshot groupSnapshot = await groupRef.get();
        List<dynamic> members = groupSnapshot.get('members');

        // Step 2: Modify the member's name in the array if the phone number matches
        for (var member in members) {
          if (member['phone'] == userPhone) {
            member['name'] = newusername;
            break;
          }
        }

        // Step 3: Update the modified members array back to Firestore
        await groupRef.update({'members': members});
        print("Updated username in group: $groupId");
      } catch (e) {
        print("Error updating username in group $groupId: $e");
      }
    }
  }
}

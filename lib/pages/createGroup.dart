import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/groupfeed.dart';
import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/sharedpreffs.dart';
import 'package:image_picker/image_picker.dart';

class Creategroup extends StatefulWidget {
  final phonenumberasuserid;
  final String username;
  final String userid;
  const Creategroup(
      {super.key,
      this.phonenumberasuserid,
      required this.username,
      required this.userid});

  @override
  State<Creategroup> createState() => _CreategroupState();
}

class _CreategroupState extends State<Creategroup> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _themeController = TextEditingController();
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(
                        phonenumberToCheck: widget.phonenumberasuserid),
                  ));
            },
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: beige,
        title: Center(
            child: Padding(
          padding: EdgeInsets.only(right: 25.h),
          child: Text(
            'Glint.',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        )),
      ),
      backgroundColor: beige,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create Group',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.h,
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
                  height: 10.h,
                ),
                TextField(
                  style: TextStyle(fontSize: 30, color: Colors.black),
                  textAlign: TextAlign.center,
                  controller: _groupNameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'GroupName',
                      hintStyle: TextStyle(fontSize: 30, color: Colors.grey)),
                ),
                TextField(
                  style: TextStyle(fontSize: 30, color: Colors.black),
                  textAlign: TextAlign.center,
                  controller: _themeController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Todays Theme',
                      hintStyle: TextStyle(fontSize: 30, color: Colors.grey)),
                ),
                SizedBox(
                  height: 200.h,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 120.w, vertical: 12.h),
                        elevation: 0,
                        backgroundColor: darkBlue,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      String codeToShare = await addUserToFirestore();
                      uploadProfilePicture(_imageFile!, codeToShare);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Groupfeed(
                              userid: widget.userid,
                              username: widget.username,
                              groupname: _groupNameController.text,
                              theme: _themeController.text,
                              code: codeToShare,
                              phoneNumberAsUserId: widget.phonenumberasuserid,
                            ),
                          ));
                    },
                    child: const Text(
                      'Genarate code',
                      style: TextStyle(fontSize: 16),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addUserToFirestore() async {
    String groupname = _groupNameController.text;
    String theme = _themeController.text;
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    String userName = userDetails['name'] ?? 'Unknown User';
    String userPhone = userDetails['phone'] ?? 'Unknown Phone';

    if (groupname.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('groups').add({
          'Groupname': groupname,
          'todaystheme': theme,
          'themesetterindex': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastthemeupdatedat': null,
          'countdownEndTime': 2,
          'members': [
            {
              'name': userName,
              'phone': userPhone,
            },
          ],
        });
        const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Yaaay!',
            message: 'Group created successfully!',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } catch (e) {}
    } else {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops',
          message: "Please Enter the complete Details",
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }

    String? documentId = await getDocumentIdByGroupName(groupname);
    return documentId;
  }

  Future<String?> getDocumentIdByGroupName(String groupName) async {
    try {
      // Query the 'groups' collection for a document with the specific group name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('Groupname', isEqualTo: groupName)
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

  Future<void> uploadProfilePicture(File imageFile, String groupid) async {
    try {
      // Step 1: Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('groupProfilePictures')
          .child('$groupid.jpg'); // Save as `groupId.jpg`

      await storageRef.putFile(imageFile);

      // Step 2: Get the download URL
      final profilePictureUrl = await storageRef.getDownloadURL();

      // Step 3: Save the URL in the group document in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .update({
        'profilePictureUrl': profilePictureUrl,
      });
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}

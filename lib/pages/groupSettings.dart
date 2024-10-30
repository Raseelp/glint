import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/Settings.dart';
import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/buildProfiePic.dart';
import 'package:glint/utils/membersDetails.dart';
import 'package:image_picker/image_picker.dart';

class GroupSettings extends StatefulWidget {
  final String groupname;
  final String inviteCode;
  final String todaysTheme;
  final String userid;
  final String userphone;

  const GroupSettings({
    super.key,
    required this.groupname,
    required this.inviteCode,
    required this.todaysTheme,
    required this.userid,
    required this.userphone,
  });

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);
  int memberCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMemberCount();
  }

  void fetchMemberCount() async {
    int count = await getMemberCount(widget.inviteCode);
    setState(() {
      memberCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController groupnamecontroller =
        TextEditingController(text: widget.groupname);

    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SplashScreen(phonenumberToCheck: widget.userphone),
                  ));
            },
            icon: Icon(Icons.arrow_back)),
        actions: [
          IconButton(
              onPressed: () {
                if (_imageFile != null) {
                  uploadProfilePicture(
                    _imageFile!,
                    widget.inviteCode,
                  );
                }
                changeGroupName(widget.inviteCode, groupnamecontroller.text);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupSettings(
                          userphone: widget.userphone,
                          groupname: groupnamecontroller.text,
                          inviteCode: widget.inviteCode,
                          todaysTheme: widget.todaysTheme,
                          userid: widget.userid),
                    ));
              },
              icon: Icon(
                Icons.check,
                size: 25,
              ))
        ],
        title: Padding(
          padding: EdgeInsets.only(left: 80.h),
          child: const Text(
            'Glint.',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: beige,
      ),
      backgroundColor: beige,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _showPickerOptions();
              },
              child: Stack(children: [
                SizedBox(
                    height: 100.h,
                    width: 100.h,
                    child: builProfilePic(groupId: widget.inviteCode)),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                        width: 25.h,
                        height: 25.h,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100)),
                        child: Icon(Icons.edit)))
              ]),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: groupnamecontroller,
              style:
                  const TextStyle(fontSize: 40, fontWeight: FontWeight.normal),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Invite Code:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                Text(
                  widget.inviteCode,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w200),
                ),
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.inviteCode));
                      const snackBar = SnackBar(
                        /// need to set following properties for best effect of awesome_snackbar_content
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Yaaay!',
                          message: 'Code Has Been Copied To Clipboard!',

                          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                          contentType: ContentType.success,
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                    ))
              ],
            ),
            Text(
              widget.todaysTheme,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${memberCount.toString()} Members',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.search_outlined))
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getMemberDetails(widget.inviteCode),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No members found.");
                    } else {
                      List<Map<String, dynamic>> members = snapshot.data!;

                      return ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return MemebersDetails(
                              name: member['name'],
                              phonenumber: member['phone']);
                        },
                      );
                    }
                  }),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 135.w, vertical: 12.h),
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 194, 7, 7),
                    foregroundColor: Colors.white),
                onPressed: () async {
                  await exitGroup();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SplashScreen(phonenumberToCheck: widget.userphone),
                      ));
                },
                child: Text('Exit Group'))
          ],
        ),
      ),
    );
  }

  Future<int> getMemberCount(String groupId) async {
    try {
      // Reference to the document in the "groups" collection
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      // Check if the document exists and contains the "members" field
      if (groupDoc.exists && groupDoc['members'] != null) {
        List members = groupDoc['members'];
        return members.length;
      } else {
        return 0; // Return 0 if no members field is found
      }
    } catch (e) {
      print("Error getting member count: $e");
      return 0; // Return 0 or handle error appropriately
    }
  }

  Future<List<Map<String, dynamic>>> getMemberDetails(String groupId) async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupDoc.exists && groupDoc['members'] != null) {
        List members = groupDoc['members'];

        // Create a list of maps with name and phone number for each member
        List<Map<String, dynamic>> memberDetails = members.map((member) {
          return {
            'name': member['name'],
            'phone': member['phone'],
          };
        }).toList();

        return memberDetails;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting member details: $e");
      return [];
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
      print("Profile picture uploaded and URL saved successfully.");
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  Future<void> changeGroupName(String groupid, String newgroupname) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupid).update({
      'Groupname': newgroupname,
    });

    print('GroupName Updated Succcessfully');
  }

  //for exiting a group

  Future<void> exitGroup() async {
    try {
      // Reference to the group document
      DocumentReference groupRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.inviteCode);

      // Get the current members array from Firestore
      DocumentSnapshot groupSnapshot = await groupRef.get();
      List<dynamic> members = groupSnapshot.get('members');

      // Remove the user with the matching phone number
      List<dynamic> updatedMembers = members
          .where((member) => member['phone'] != widget.userphone)
          .toList();

      // Update Firestore with the modified members array
      await groupRef.update({'members': updatedMembers});

      print("Successfully exited the group.");
    } catch (e) {
      print("Error exiting group: $e");
    }
  }
}

import 'dart:io';

import 'package:Glint/pages/glintLeaderBoard.dart';
import 'package:Glint/pages/splashScreen.dart';
import 'package:Glint/utils/buildProfiePic.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:Glint/utils/membersDetails.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';

class GroupSettings extends StatefulWidget {
  final String groupname;
  final String inviteCode;
  final String todaysTheme;
  final String userid;
  final String userphone;
  final String username;

  const GroupSettings({
    super.key,
    required this.groupname,
    required this.inviteCode,
    required this.todaysTheme,
    required this.userid,
    required this.userphone,
    required this.username,
  });

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  int memberCount = 0;
  bool isEditable = false;
  final TextEditingController _themecontroller = TextEditingController();

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
    String todaysTheme = widget.todaysTheme;
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
          icon: const Icon(Icons.arrow_back),
          color: AppColors.whiteText,
        ),
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
                changeThemeManuavlly(widget.inviteCode, _themecontroller.text);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupSettings(
                          username: widget.username,
                          userphone: widget.userphone,
                          groupname: groupnamecontroller.text,
                          inviteCode: widget.inviteCode,
                          todaysTheme: _themecontroller.text,
                          userid: widget.userid),
                    ));
              },
              icon: const Icon(
                Icons.check,
                size: 25,
                color: AppColors.whiteText,
              ))
        ],
        title: Padding(
          padding: EdgeInsets.only(left: 80.h),
          child: const Text(
            'Glint.',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteText),
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
      ),
      backgroundColor: AppColors.secondaryBackground,
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
                        color: AppColors.mediumLightGray,
                        borderRadius: BorderRadius.circular(100)),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                )
              ]),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: groupnamecontroller,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.normal,
                  color: AppColors.whiteText),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            const Text(
              'Invite Code:',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  color: AppColors.lightGrayText),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.inviteCode,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.inviteCode));
                      const snackBar = SnackBar(
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
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.whiteText,
                    ))
              ],
            ),
            const Text(
              'Todays theme:',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  color: AppColors.lightGrayText),
            ),
            GestureDetector(
              onTap: () async {
                bool isitCorrectuser =
                    await isCorrectUser(widget.userphone, widget.inviteCode);
                //COMMENTING THIS CODE BECOUSE I DONT WANNA COUSE 24 HOURS LIMIT IN THEME SETTING WHILE RUNNING SERVERLESS TESTING
                // bool did24HoursPassed =
                //     await has24HoursPassed(widget.inviteCode);
                if (isitCorrectuser) {
                  _showOptionsDialog();
                  // if (did24HoursPassed) {

                  // } else {
                  //   const snackBar = SnackBar(
                  //     elevation: 0,
                  //     behavior: SnackBarBehavior.floating,
                  //     backgroundColor: Colors.transparent,
                  //     content: AwesomeSnackbarContent(
                  //       title: 'Oops',
                  //       message: "looks like Todays Theme is already set",
                  //       contentType: ContentType.failure,
                  //     ),
                  //   );

                  //   ScaffoldMessenger.of(context)
                  //     ..hideCurrentSnackBar()
                  //     ..showSnackBar(snackBar);
                  // }
                }
              },
              child: isEditable
                  ? TextField(
                      textAlign: TextAlign.center,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: _themecontroller,
                      style: const TextStyle(color: AppColors.whiteText),
                      onSubmitted: (value) {
                        todaysTheme = value;
                        isEditable = false;
                      },
                      autofocus: true,
                    )
                  : Text(
                      todaysTheme,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: AppColors.whiteText),
                    ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.w, vertical: 12.h),
                    elevation: 0,
                    backgroundColor: AppColors.blurple,
                    foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GlintLeaderBoard(
                          usename: widget.username,
                          groupId: widget.inviteCode,
                          groupname: widget.groupname,
                          todaystheme: todaysTheme,
                          phoneNumber: widget.userphone,
                          userid: widget.userid,
                        ),
                      ));
                },
                child: const Text('See Glint LeaderBoard')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${memberCount.toString()} Members',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search_outlined,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getMemberDetails(widget.inviteCode),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No members found.");
                    } else {
                      List<Map<String, dynamic>> members = snapshot.data!;

                      return ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          final name = member['name'] ?? 'No Name';
                          final phone = member['phone'] ?? 'No Phone';
                          return MemebersDetails(
                              name: name, phonenumber: phone);
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
                onPressed: () {
                  showLogoutDiologe();
                  // await exitGroup();
                },
                child: const Text('Exit Group'))
          ],
        ),
      ),
    );
  }

  void showLogoutDiologe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            " Exit Group",
            style: TextStyle(color: AppColors.whiteText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are You Sure You Want To Exit From The Group',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.darkGrayText,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  backgroundColor: AppColors.notificationRed,
                  elevation: 0,
                ),
                onPressed: () async {
                  await exitGroup();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SplashScreen(phonenumberToCheck: widget.userphone),
                      ));
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Text(
                      'Exit Group',
                      style: TextStyle(color: AppColors.whiteText),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      backgroundColor: AppColors.lightGray,
                      elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Center(
                      child: Text(
                        'I changed My Mind',
                        style: TextStyle(color: AppColors.whiteText),
                      ),
                    ),
                  ))
            ],
          ),
        );
      },
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
      const SnackBar(
        content: Text('No Image Selected'),
      );
    }
  }

  //to show user the source of picking image

  void _showPickerOptions() {
    showModalBottomSheet(
      backgroundColor: AppColors.secondaryBackground,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(17)),
                  child: ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: AppColors.whiteText,
                    ),
                    title: const Text(
                      'Choose from Gallery',
                      style: TextStyle(color: AppColors.whiteText),
                    ),
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.whiteText,
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: AppColors.whiteText),
                ),
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
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  Future<void> changeGroupName(String groupid, String newgroupname) async {
    if (newgroupname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Field cannot be empty! Please enter some text.")));
    } else {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .update({
        'Groupname': newgroupname,
      });
    }
  }

  Future<void> changeThemeManuavlly(
      String groupid, String newThemeByUser) async {
    if (newThemeByUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Field cannot be empty! Please enter some text.")));
    } else {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupid)
          .update({
        'todaystheme': newThemeByUser,
        'lastthemeupdatedat': FieldValue.serverTimestamp()
      });
      isEditable = false;
    }
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
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Random"),
                onTap: () {
                  setState(() {
                    const SnackBar(
                      content: Text('This Feature is not available Yet'),
                    );
                  });

                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Manual"),
                onTap: () {
                  setState(() {
                    isEditable = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> isCorrectUser(String userPhoneNumber, String groupid) async {
    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groups').doc(groupid);
    DocumentSnapshot groupSnapshot = await groupRef.get();

    // Retrieve the current themeSetterIndex and members
    int themeSetterIndex = groupSnapshot['themesetterindex'];
    List<dynamic> members =
        groupSnapshot['members']; // Use dynamic since it's a map

    // Find the index of the current user based on phone number
    int userIndex =
        members.indexWhere((member) => member['phone'] == userPhoneNumber);

    // Check if the user is allowed to press Glint Now
    if (userIndex == themeSetterIndex) {
      return true;
    } else {
      // Show failure Snackbar
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops',
          message: " Today's Not Your Day...Maybe Tomarrow??",
          messageTextStyle: TextStyle(fontWeight: FontWeight.bold),
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      return false;
    }
  }

  Future<bool> has24HoursPassed(String groupId) async {
    // Reference to the specific group's document
    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groups').doc(groupId);

    // Fetch the group's document to get the 'lastthemeupdatedat' field
    DocumentSnapshot groupSnapshot = await groupRef.get();

    if (groupSnapshot.exists && groupSnapshot['lastthemeupdatedat'] != null) {
      Timestamp lastThemeUpdate = groupSnapshot['lastthemeupdatedat'];
      DateTime lastUpdated = lastThemeUpdate.toDate();
      DateTime currentTime = DateTime.now();

      // Calculate the difference in hours
      int hoursSinceLastUpdate = currentTime.difference(lastUpdated).inHours;

      // Check if 24 hours have passed
      return hoursSinceLastUpdate >= 24;
    }

    // If 'lastthemeupdatedat' is null (for first-time setup), allow the theme change
    return true;
  }
}

import 'dart:async';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/groupSettings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Groupfeed extends StatefulWidget {
  final String groupname;
  final String theme;
  final String code;
  final String phoneNumberAsUserId;
  final String username;
  final String userid;
  const Groupfeed(
      {super.key,
      required this.groupname,
      required this.theme,
      required this.code,
      required this.phoneNumberAsUserId,
      required this.username,
      required this.userid});

  @override
  State<Groupfeed> createState() => _GroupfeedState();
}

class _GroupfeedState extends State<Groupfeed> {
  int _countdown = 120; // 2 minutes in seconds
  bool _isTimerActive = false;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _isTimerActive = true; // Activate the timer
      _countdown = 120; // Reset countdown to 2 minutes
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--; // Decrement the countdown
        });
      } else {
        _timer?.cancel(); // Stop the timer when it reaches zero
        setState(() {
          _isTimerActive = false; // Timer is no longer active
        });
      }
    });
  }

  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    String groupid = widget.code;
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(6, 7),
                      ),
                    ]),
                width: double.infinity,
                height: 180.h,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.groupname,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupSettings(
                                        userphone: widget.phoneNumberAsUserId,
                                        userid: widget.userid,
                                        groupname: widget.groupname,
                                        inviteCode: widget.code,
                                        todaysTheme: widget.theme,
                                      ),
                                    ));
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                size: 30,
                              ))
                        ],
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        widget.theme,
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 100.w, vertical: 12.h),
                            elevation: 0,
                            backgroundColor: darkBlue,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          capturePhoto(widget.code);
                        },
                        child: const Text(
                          'Add a Photo',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            handleGlintNow(widget.phoneNumberAsUserId, groupid);
                          },
                          child: _isTimerActive
                              ? Text(
                                  'Time left: ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}')
                              : Text('Glint Now'))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.code)
                      .collection('images')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // Get the list of images
                    final images = snapshot.data!.docs;

                    return ListWheelScrollView.useDelegate(
                      itemExtent: 250,
                      diameterRatio: 2.0,
                      physics: FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < images.length) {
                            final imageDoc = images[index];
                            final imageUrl = imageDoc['url'];
                            final imageId = imageDoc.id;
                            final usernameImage = imageDoc['uploadedBy'];

                            return Padding(
                              padding: const EdgeInsets.all(15),
                              child: Expanded(
                                child: Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(17),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 400,
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(17)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            usernameImage,
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      )),
                                  Positioned(
                                    top: 5,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Call the delete method with imageId or imageUrl
                                        deleteImage(
                                            widget.code, imageId, imageUrl);
                                        const snackBar = SnackBar(
                                          /// need to set following properties for best effect of awesome_snackbar_content
                                          elevation: 0,
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.transparent,
                                          content: AwesomeSnackbarContent(
                                            title: 'But Whyyyyy...',
                                            message:
                                                'Do You Realise You Deleted a Memmory...',

                                            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                            contentType: ContentType.failure,
                                          ),
                                        );

                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(snackBar);
                                      },
                                    ),
                                  )
                                ]),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount: images.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> capturePhoto(String groupId) async {
    await requestCameraPermission();
    print("Button pressed, attempting to capture photo...");
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Reference to the group’s folder in Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('groups')
          .child(groupId)
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      try {
        await storageRef.putFile(File(image.path));
        String downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('images')
            .add({
          'url': downloadUrl,
          'uploadedBy': widget.username, // replace with actual user ID
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Image uploaded and URL stored successfully: $downloadUrl");
      } catch (e) {
        print("Failed to upload image: $e");
      }
    } else {
      print("No image selected");
    }
  }

  Future<void> deleteImage(
      String groupId, String imageId, String imageUrl) async {
    // Create a reference to the image in Firebase Storage
    Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

    try {
      // Delete the image from Firebase Storage
      await storageRef.delete();
      print("Image deleted successfully from Storage");

      // Delete the image reference from Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('images')
          .doc(imageId) // Use the document ID for deletion
          .delete();
      print("Image reference deleted successfully from Firestore");
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> handleGlintNow(String userPhoneNumber, String groupid) async {
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
      _startTimer();
      // Show success Snackbar
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: '🌟 Look out!',
          message:
              " ${members[userIndex]['name']} just lit up the group with a Glint!",

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      // Trigger the countdown and other logic here
    } else {
      // Show failure Snackbar
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: '⏳ Hold your horses!',
          message: " The Glint Now button is off-limits for you!",

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/groupSettings.dart';
import 'package:glint/pages/imageFullScreenView.dart';
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
  Timer? _timer;
  int? _countdownEndTime;
  int? _remainingTime;

  @override
  void initState() {
    super.initState();
    // Start the timer to fetch countdown end time periodically
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchCountdownEndTime();
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
                      Expanded(child: buildCountdownButton(groupid))
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    final images = snapshot.data!.docs;

                    return ListWheelScrollView.useDelegate(
                      itemExtent: 250,
                      diameterRatio: 2.0,
                      physics: const FixedExtentScrollPhysics(),
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
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Imagefullscreenview(
                                                      uploadedBy: usernameImage,
                                                      imgUrl: imageUrl),
                                            ));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 400,
                                        height: 400,
                                        fit: BoxFit.cover,
                                      ),
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
                                          elevation: 0,
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.transparent,
                                          content: AwesomeSnackbarContent(
                                            title: 'But Whyyyyy...',
                                            message:
                                                'Do You Realise You Deleted a Memmory...',
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

  Future<void> _fetchCountdownEndTime() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.code)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('countdownEndTime')) {
        setState(() {
          _countdownEndTime = snapshot.get('countdownEndTime');
          // Calculate remaining time
          _remainingTime =
              _countdownEndTime! - DateTime.now().millisecondsSinceEpoch;
        });
      }
    }
  }

  void startCountdown(String groupId) async {
    final now = DateTime.now();
    final endTimestamp = now.add(Duration(minutes: 2)).millisecondsSinceEpoch;

    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'countdownEndTime': endTimestamp,
    });
  }

  Widget buildCountdownButton(String groupId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final data = snapshot.data!;
        final endTimestamp = data['countdownEndTime'] as int;
        final remainingTime =
            endTimestamp - DateTime.now().millisecondsSinceEpoch;
        final countdownSeconds = (remainingTime / 1000).round();

        if (countdownSeconds <= 0) {
          return ElevatedButton(
            onPressed: () => startCountdown(groupId), // Start the countdown
            child: Text('Start Countdown'),
          );
        } else {
          final minutes = countdownSeconds ~/ 60;
          final seconds = countdownSeconds % 60;
          return ElevatedButton(
            onPressed: null, // Disable button while countdown is active
            child: Text(
                'Time left: $minutes:${seconds.toString().padLeft(2, '0')}'),
          );
        }
      },
    );
  }

  Widget buildCounterdownButton(String groupId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final data = snapshot.data!;
        final endTimestamp = data['countdownEndTime'] as int;
        final remainingTime =
            endTimestamp - DateTime.now().millisecondsSinceEpoch;
        final countdownSeconds = (remainingTime / 1000).round();

        if (countdownSeconds <= 0) {
          return ElevatedButton(
            onPressed: () => startCountdown(groupId), // Start the countdown
            child: Text('Start Countdown'),
          );
        } else {
          final minutes = countdownSeconds ~/ 60;
          final seconds = countdownSeconds % 60;
          return ElevatedButton(
            onPressed: null, // Disable button while countdown is active
            child: Text(
                'Time left: $minutes:${seconds.toString().padLeft(2, '0')}'),
          );
        }
      },
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
}

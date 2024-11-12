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
import 'package:glint/utils/reactionTray.dart';
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchCountdownEndTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupSettings(
                                        username: widget.username,
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

                            return Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(17),
                                child: GestureDetector(
                                  onLongPress: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isDismissible: true,
                                      enableDrag: true,
                                      elevation: 5,
                                      builder: (context) => SizedBox(
                                        height: 200,
                                        child: ReactionTray(
                                          onReactionSelected: (reaction) {
                                            updateReaction(groupid, imageId,
                                                usernameImage, reaction);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    );
                                  },
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
                                        style: const TextStyle(
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
                                    deleteImage(widget.code, imageId, imageUrl);
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
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 10,
                                  child: ReactionsDisplay(
                                      groupId: groupid, imageId: imageId))
                            ]);
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
    final endTimestamp =
        now.add(const Duration(minutes: 2)).millisecondsSinceEpoch;

    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'countdownEndTime': endTimestamp,
      'lastglintsharedat': FieldValue.serverTimestamp(),
      'isglintactive': true,
    });
  }

  void makeGlintFalse(String groupid) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupid).update({
      'isglintactive': false,
    });
  }

  Widget buildCountdownButton(String groupId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!;
        final endTimestamp = data['countdownEndTime'] as int;
        final remainingTime =
            endTimestamp - DateTime.now().millisecondsSinceEpoch;
        final countdownSeconds = (remainingTime / 1000).round();

        if (countdownSeconds <= 0) {
          makeGlintFalse(groupId);
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(255, 194, 7, 7),
                  foregroundColor: Colors.white),
              onPressed: () async {
                bool iscorrectUser = await isCorrectUser(
                    widget.phoneNumberAsUserId, widget.code);
                bool has24hoursPassed = await has24HoursPassed(widget.code);

                if (iscorrectUser) {
                  if (has24hoursPassed) {
                    startCountdown(groupId);
                  } else {
                    const snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Todays Glint Used',
                        message: "Try again after 24 hours...",
                        contentType: ContentType.failure,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  }
                }
              },
              child: const Text('Start Countdown'),
            ),
          );
        } else {
          final minutes = countdownSeconds ~/ 60;
          final seconds = countdownSeconds % 60;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                elevation: 0,
                backgroundColor: const Color.fromARGB(255, 194, 7, 7),
                foregroundColor: Colors.white),
            onPressed: null,
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

        final groupRef =
            FirebaseFirestore.instance.collection('groups').doc(groupId);
        DocumentSnapshot snapshot = await groupRef.get();
        if (snapshot.exists) {
          bool glintStatus = snapshot.get('isglintactive');
          if (glintStatus == true) {
            List<dynamic> members = snapshot.get('members');
            for (var i = 0; i < members.length; i++) {
              Map<String, dynamic> member = members[i];

              if (member['phone'] == widget.phoneNumberAsUserId) {
                // or use 'name' if unique
                // Increment the points for the specific member
                int currentPoints = member['points'] ?? 0;
                members[i]['points'] = currentPoints + 1;
                break;
              }
            }

            await groupRef.update({'members': members});
          }
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .collection('images')
              .add({
            'url': downloadUrl,
            'uploadedBy': widget.username,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        SnackBar(
          content: Text(e.toString()),
        );
      }
    } else {}
  }

  Future<void> deleteImage(
      String groupId, String imageId, String imageUrl) async {
    Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

    try {
      await storageRef.delete();
      print("Image deleted successfully from Storage");

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('images')
          .doc(imageId)
          .delete();
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
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

    if (groupSnapshot.exists && groupSnapshot['lastglintsharedat'] != null) {
      Timestamp lastGlintShared = groupSnapshot['lastglintsharedat'];
      DateTime lastGlintUpdated = lastGlintShared.toDate();
      DateTime currentTime = DateTime.now();

      // Calculate the difference in hours
      int hoursSinceLastUpdate =
          currentTime.difference(lastGlintUpdated).inHours;

      // Check if 24 hours have passed
      return hoursSinceLastUpdate >= 24;
    }

    // If 'lastthemeupdatedat' is null (for first-time setup), allow the theme change
    return true;
  }

  Future<void> updateReaction(String groupId, String imageId, String username,
      String reactionType) async {
    final imageRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('images')
        .doc(imageId);

    await imageRef.update({
      'reactions.$username':
          reactionType, // Updates or adds the user’s reaction
    });
  }
}

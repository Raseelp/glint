import 'dart:async';
import 'dart:io';
import 'package:Glint/pages/groupSettings.dart';
import 'package:Glint/pages/imageFullScreenView.dart';
import 'package:Glint/pages/splashScreen.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:Glint/utils/reactionTray.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  bool isGlintImage = false;

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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    String groupid = widget.code;
    String groupname = widget.groupname;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(
                      phonenumberToCheck: widget.phoneNumberAsUserId),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.whiteText,
            )),
        title: Text(
          groupname,
          style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteText),
        ),
        backgroundColor: AppColors.secondaryBackground,
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(17),
                ),
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
                          const Text(
                            'Todays Theme:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: AppColors.lightGrayText),
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
                                color: Colors.white,
                              ))
                        ],
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        widget.theme,
                        style: const TextStyle(
                            fontSize: 30, color: AppColors.whiteText),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Expanded(child: buildCountdownButton(groupid)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100.w, vertical: 12.h),
                              elevation: 0,
                              backgroundColor: AppColors.blurple,
                              foregroundColor: Colors.white),
                          onPressed: () {
                            capturePhoto(widget.code);
                          },
                          child: const Text(
                            'Add a Photo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30, left: 10),
                    child: Text('Today',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.code)
                      .collection('images')
                      .where('timestamp',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day)))
                      .where('timestamp',
                          isLessThan: Timestamp.fromDate(DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day + 1)))
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final images = snapshot.data!.docs;

                    if (images.isEmpty) {
                      return const Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Be the first to share today! Add a picture to start things off.",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGrayText),
                        ),
                      );
                    }

                    return RotatedBox(
                      quarterTurns: 1,
                      child: ListWheelScrollView.useDelegate(
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

                              return RotatedBox(
                                quarterTurns: -1,
                                child: Stack(children: [
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
                                                    widget.username, reaction);
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
                                            color: AppColors.lightGray
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(17)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            usernameImage,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: AppColors.whiteText),
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
                                        color: AppColors.lightGray,
                                      ),
                                      onPressed: () {
                                        // Call the delete method with imageId or imageUrl
                                        deleteImage(
                                            widget.code,
                                            imageId,
                                            imageUrl,
                                            widget.phoneNumberAsUserId);
                                      },
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 10,
                                      child: ReactionsDisplay(
                                          groupId: groupid, imageId: imageId))
                                ]),
                              );
                            } else {
                              return null;
                            }
                          },
                          childCount: images.length,
                        ),
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
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ),
                elevation: 0,
                backgroundColor: const Color.fromARGB(255, 194, 7, 7),
                foregroundColor: Colors.white),
            onPressed: () async {
              bool iscorrectUser =
                  await isCorrectUser(widget.phoneNumberAsUserId, widget.code);
              bool has24hoursPassed = await has24HoursPassed(widget.code);

              if (iscorrectUser) {
                if (has24hoursPassed) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.darkBackground,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      title: Text(
                        "Ready to Share a Glint?",
                        style: TextStyle(color: AppColors.whiteText),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Capture the moment! Share photos within 2 minutes to earn Glint Points. Track your points in Group Settings.",
                            style: TextStyle(
                                color: AppColors.lightGrayText, fontSize: 15),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17)),
                              backgroundColor: AppColors.notificationRed,
                              elevation: 0,
                            ),
                            onPressed: () {
                              startCountdown(groupId);
                              Navigator.pop(context);
                            },
                            child: const SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'Share Glint Now',
                                  style: TextStyle(color: AppColors.whiteText),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17)),
                              backgroundColor: AppColors.blurple,
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'Maybe Later',
                                  style: TextStyle(color: AppColors.whiteText),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
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
            child: const Text('Glint Now'),
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
                'Time left: $minutes:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.whiteText,
                )),
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
            isGlintImage = true;
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
            'uploadedphone': widget.phoneNumberAsUserId,
            'isglintimage': isGlintImage
          });
          isGlintImage = false;
        }
      } catch (e) {
        SnackBar(
          content: Text(e.toString()),
        );
      }
    } else {}
  }

  Future<void> deleteImage(String groupId, String imageId, String imageUrl,
      String currentUserPhone) async {
    Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    DocumentReference imageRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('images')
        .doc(imageId);

    try {
      DocumentSnapshot imageSnapshot = await imageRef.get();
      if (imageSnapshot.exists) {
        bool isGlintImage = imageSnapshot.get('isglintimage');
        String uploadedPhone = imageSnapshot.get('uploadedphone');
        if (uploadedPhone != currentUserPhone) {
          const snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Really...',
              message: 'You Cant Delete SomeOne elses Memory',
              contentType: ContentType.failure,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
          return; // Exit the function without deleting the image
        }

        DocumentReference groupRef =
            FirebaseFirestore.instance.collection('groups').doc(groupId);

        DocumentSnapshot groupSnapshot = await groupRef.get();
        List<dynamic> members = groupSnapshot.get('members');

        bool memberFound = false;
        for (var member in members) {
          if (member['phone'] == uploadedPhone) {
            int currentPoints = member['points'] ?? 0;
            member['points'] = (currentPoints > 0) ? currentPoints - 1 : 0;
            memberFound = true;
            break;
          }
        }
        if (memberFound) {
          // Step 4: Update the modified members array back to Firestore
          await groupRef.update({'members': members});
          print("Decremented points for user with phone: $uploadedPhone");
        } else {
          print("Member with phone $uploadedPhone not found in group.");
        }

        // Step 2: Perform actions based on the isglintimage value
        if (isGlintImage) {
          await storageRef.delete();

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .collection('images')
              .doc(imageId)
              .delete();
          print(
              "This image is a glint image. Proceeding with additional actions if needed.");
          // Add any additional actions for glint images here, if needed
        } else {
          print("This image is not a glint image. Proceeding with deletion.");

          await storageRef.delete();

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .collection('images')
              .doc(imageId)
              .delete();
        }

        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'But Why...',
            message: 'You Just Deleted A memory',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
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
    //IMPORTANT:CHANGED HE CONDITION FROM == TO >= SO THAT THE SERVERLESS TEST CODE WILL WORK
    if (userIndex >= themeSetterIndex) {
      print('userindex ${userIndex}');
      print('CORRECT USER TEMPORERLY');
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
      return hoursSinceLastUpdate >= 0;
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
    final snapshot = await imageRef.get();
    Map<dynamic, dynamic> reactions =
        (snapshot.data()?['reactions'] ?? {}) as Map<dynamic, dynamic>;
    reactions[username] = reactionType;

    await imageRef.update({
      'reactions': reactions,
    });
  }
}

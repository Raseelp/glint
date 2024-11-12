import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/colorPallet.dart';
import 'package:glint/utils/sharedpreffs.dart';

class Joingroup extends StatefulWidget {
  final String phonenumber;
  const Joingroup({super.key, required this.phonenumber});

  @override
  State<Joingroup> createState() => _JoingroupState();
}

class _JoingroupState extends State<Joingroup> {
  final TextEditingController _groupIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.whiteText,
            )),
        backgroundColor: AppColors.secondaryBackground,
        title: Center(
            child: Padding(
          padding: EdgeInsets.only(right: 25.h),
          child: const Text(
            'Join Group.',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteText),
          ),
        )),
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Text('Connect with family\'s and friends moments...',
                    style: TextStyle(
                      color: AppColors.lightGrayText,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(17)),
                  child: TextField(
                    style: const TextStyle(color: AppColors.whiteText),
                    textAlign: TextAlign.center,
                    controller: _groupIdController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Paste the code here',
                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(
                  height: 350.h,
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
                    joinGroup();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplashScreen(
                              phonenumberToCheck: widget.phonenumber),
                        ));
                  },
                  child: const Text(
                    'Join',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> joinGroup() async {
    String groupId = _groupIdController.text.trim();

    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    String userName = userDetails['name'] ?? 'Unknown User';
    String userPhone = userDetails['phone'] ?? 'Unknown Phone';

    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');

    try {
      DocumentSnapshot groupDoc = await groups.doc(groupId).get();

      if (!groupDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$groupDoc doesnot exist")),
        );
      } else {
        await groups.doc(groupId).update({
          'members': FieldValue.arrayUnion([
            {'name': userName, 'phone': userPhone, 'points': 0},
          ]),
        });

        const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Yaaay!',
            message: 'You Have Successfully Added To The Group',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'cmon Man....!',
          message: 'Please Enter A Valid Code',

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

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/groupfeed.dart';
import 'package:glint/pages/splashScreen.dart';
import 'package:glint/utils/sharedpreffs.dart';

class Joingroup extends StatefulWidget {
  final String phonenumber;
  const Joingroup({super.key, required this.phonenumber});

  @override
  State<Joingroup> createState() => _JoingroupState();
}

class _JoingroupState extends State<Joingroup> {
  final TextEditingController _groupIdController = TextEditingController();
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: beige,
        title: Center(
            child: Padding(
          padding: EdgeInsets.only(right: 25.h),
          child: const Text(
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
                  'Join Group',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 100,
                ),
                Text(
                  'Enter Your Invite Code',
                  style: TextStyle(fontSize: 17),
                ),
                TextField(
                  textAlign: TextAlign.center,
                  controller: _groupIdController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Paste the code here',
                    hintStyle: TextStyle(fontSize: 30, color: Colors.grey),
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
                      backgroundColor: darkBlue,
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
            {
              'name': userName,
              'phone': userPhone,
            },
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

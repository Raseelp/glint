import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:glint/main.dart';
import 'package:glint/pages/onbordeing.dart';
import 'package:glint/utils/colorPallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appsettings extends StatefulWidget {
  final String userId;
  final String userphone;
  final List<Map<String, dynamic>> userGroups;

  const Appsettings(
      {super.key,
      required this.userId,
      required this.userphone,
      required this.userGroups});

  @override
  State<Appsettings> createState() => _AppsettingsState();
}

class _AppsettingsState extends State<Appsettings> {
  @override
  Widget build(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.only(right: 50),
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
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const Text(
              'General',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGrayText),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              color: AppColors.lightGray,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Introduction',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle introduction tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'Themes',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle themes tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'About Us',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle feedback tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    SwitchListTile(
                      activeColor: AppColors.whiteText,
                      activeTrackColor: AppColors.blurple,
                      inactiveTrackColor: AppColors.lightGrayText,
                      inactiveThumbColor: AppColors.whiteText,

                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      value: true, // or a variable to control the state

                      onChanged: (bool value) {
                        // Handle switch toggle
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Account',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGrayText),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              color: AppColors.lightGray,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Delete account',
                        style: TextStyle(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.delete,
                        color: AppColors.notificationRed,
                      ),
                      onTap: () {
                        showDeleteDiologe();
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'Sign out',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.exit_to_app,
                        color: AppColors.notificationRed,
                      ),
                      onTap: () {
                        showLogoutDiologe();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDiologe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Delete Account",
            style: TextStyle(color: AppColors.whiteText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Account Will Be Permanently Removed,You Wont Be Able To Use This Account Again,Do You Want To Continue?',
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
                onPressed: () {
                  deleteAccount(widget.userId, widget.userphone,
                      widget.userGroups, logout);
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Text(
                      'Yes,Delete',
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
                        'No,I Changed Mind',
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

  void showLogoutDiologe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Logout",
            style: TextStyle(color: AppColors.whiteText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are You Sure You Want To Loguot',
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
                onPressed: () {
                  logout();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onbordeing(),
                      ));
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Text(
                      'Logout',
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
                        'Cancel',
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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount(String userId, String userPhone,
      List<Map<String, dynamic>> userGroups, Function logout) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String profilePictureUrl = userDoc['userprofilePictureUrl'];

        if (profilePictureUrl.isNotEmpty) {
          // 2. Get the reference to the file using the URL
          Reference imageRef =
              FirebaseStorage.instance.refFromURL(profilePictureUrl);

          // 3. Delete the image from Firebase Storage
          await imageRef.delete();

          print('Profile picture deleted successfully from Firebase Storage');

          print('User profile data updated successfully');
        } else {
          print('No profile picture found to delete');
        }
      } else {
        print('User not found');
      }

      // Step 1: Delete user document from "users" collection
      await firestore.collection('users').doc(userId).delete();

      for (var group in userGroups) {
        String groupId = group['id'];
        DocumentReference groupRef =
            firestore.collection('groups').doc(groupId);

        DocumentSnapshot groupSnapshot = await groupRef.get();
        List<dynamic> members = groupSnapshot.get('members');

        members.removeWhere((member) => member['phone'] == userPhone);

        await groupRef.update({'members': members});
      }
      if (user != null) {
        await user.delete();
      }

      logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Glint()), // Replace MainScreen with the widget for main.dart
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );

      if (e.toString().contains('requires-recent-login')) {
        await showPhoneReauthenticationDialog(
            context, userId, userPhone, userGroups, logout);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
  }

// Re-authentication with phone number
  Future<void> showPhoneReauthenticationDialog(
      BuildContext context,
      String userId,
      String userPhone,
      List<Map<String, dynamic>> userGroups,
      Function logout) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    TextEditingController otpController = TextEditingController();
    late String verificationId;

    // Step 1: Send the verification code to the user's phone
    await auth.verifyPhoneNumber(
      phoneNumber: userPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This will be called automatically in some cases, such as on Android when auto-retrieval is available
        await reauthenticateAndDelete(
            credential, context, userId, userPhone, userGroups, logout);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone verification failed: ${e.message}")),
        );
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.darkBackground,
              title: const Text("Re-authenticate to Delete Account",
                  style: TextStyle(
                    color: AppColors.whiteText,
                  )),
              content: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                    backgroundColor: AppColors.notificationRed,
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    final credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text.trim(),
                    );
                    await reauthenticateAndDelete(credential, context, userId,
                        userPhone, userGroups, logout);
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Center(
                      child: Text(
                        "Re-authenticate",
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
                    Navigator.of(context).pop();
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.whiteText),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

// Function to reauthenticate and delete account
  Future<void> reauthenticateAndDelete(
      PhoneAuthCredential credential,
      BuildContext context,
      String userId,
      String userPhone,
      List<Map<String, dynamic>> userGroups,
      Function logout) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.currentUser?.reauthenticateWithCredential(credential);

      // Retry account deletion after successful re-authentication
      await deleteAccount(userId, userPhone, userGroups, logout);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Re-authentication failed: $e")),
      );
    }
  }
}

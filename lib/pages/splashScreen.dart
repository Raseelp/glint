import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glint/pages/homepage.dart';
import 'package:glint/pages/userinfo.dart';
import 'package:glint/utils/sharedpreffs.dart';

class SplashScreen extends StatefulWidget {
  final String phonenumberToCheck;
  const SplashScreen({super.key, required this.phonenumberToCheck});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    Color beige = const Color(0xFFF7F2E7);
    return Scaffold(
      backgroundColor: beige,
      body: const Center(
          child: Text(
        'Glint.',
        style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
      )),
    );
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      print("Checking for phone number in field: $phoneNumber");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Verified PhoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = snapshot.docs.first;
        String userid = snapshot.docs.first.id;

        String userName = userDoc['name'];

        await UserPreferences.setUserDetails(
            userName, widget.phonenumberToCheck, userid);
      }

      print("Documents found: ${snapshot.docs.isNotEmpty}");
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      return false;
    }
  }

  void checkUser() async {
    bool userExists = await checkUserExists(widget.phonenumberToCheck);

    String username = await getname();
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    String userid = userDetails['userid'] ?? 'Unknown User';

    if (userExists) {
      List<Map<String, dynamic>> userGroups =
          await fetchUserGroups(widget.phonenumberToCheck);

      print("User groups: $userGroups");
      // User exists, proceed to home screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(
              phoneNumberToUseAsUserId: widget.phonenumberToCheck,
              userGroups: userGroups,
              username: username,
              userid: userid,
            ),
          ));
    } else {
      // User doesn't exist, proceed to user info screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserinfoScreen(verifiedPhonenumber: widget.phonenumberToCheck),
          ));
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserGroups(String phoneNumber) async {
    List<Map<String, dynamic>> userGroups = [];

    try {
      // Fetch all groups from the groups collection
      QuerySnapshot groupSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      for (DocumentSnapshot groupDoc in groupSnapshot.docs) {
        // Check if the user's phone number is in the members list
        List<dynamic> members =
            groupDoc['members']; // This should be a list of maps
        bool isMember = members.any((member) =>
            member['phone'] == phoneNumber); // Check for user's phone

        if (isMember) {
          // If the user is a member, store group info
          userGroups.add({
            'id': groupDoc.id, // Unique ID of the group
            'groupname': groupDoc['Groupname'], // Group
            'grouptheme': groupDoc['todaystheme'],
          });
        }
      }
    } catch (e) {
      print("Error fetching user groups: $e");
    }

    return userGroups;
  }

  Future<String> getname() async {
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    String userName = userDetails['name'] ?? 'Unknown User';

    return userName;
  }
}

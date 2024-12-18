import 'package:Glint/pages/userinfo.dart';
import 'package:Glint/utils/bottomeNavBar.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:Glint/utils/sharedpreffs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String phonenumberToCheck;
  const SplashScreen({super.key, required this.phonenumberToCheck});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
    deleteEmptyGroups();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
          child: Text(
        'Glint.',
        style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteText),
      )),
    );
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    try {
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

      return snapshot.docs.isNotEmpty;
    } catch (e) {
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

      // User exists, proceed to home screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Bottomenavbar(
                  username: username,
                  userid: userid,
                  userphone: widget.phonenumberToCheck,
                  usergroups: userGroups)));
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
            'isglintactive': groupDoc['isglintactive']
          });
        }
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }

    return userGroups;
  }

  Future<String> getname() async {
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    String userName = userDetails['name'] ?? 'Unknown User';

    return userName;
  }

  Future<void> deleteEmptyGroups() async {
    // Reference to your Firestore collection
    final CollectionReference groupsCollection =
        FirebaseFirestore.instance.collection('groups');

    // Fetch all groups
    QuerySnapshot querySnapshot = await groupsCollection.get();

    // Iterate through the groups
    for (DocumentSnapshot doc in querySnapshot.docs) {
      // Get the members list
      List<dynamic> members = doc['members'];

      // Check if the members length is zero
      if (members.isEmpty) {
        CollectionReference imagesCollection =
            doc.reference.collection('images');
        QuerySnapshot imageQuerySnapshot = await imagesCollection.get();
        for (DocumentSnapshot imageDoc in imageQuerySnapshot.docs) {
          try {
            // Get the image URL from the 'url' field
            String imageUrl = imageDoc['url'];

            // Get a reference to the image in Firebase Storage using the image URL
            Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);

            // Delete the image from Firebase Storage
            await imageRef.delete();

            // Delete the image document from Firestore
            await imageDoc.reference.delete();
          } catch (e) {
            SnackBar(
              content: Text(e.toString()),
            );
          }
        }

        DocumentSnapshot groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(doc.id)
            .get();

        String profilePictureUrl = groupDoc['profilePictureUrl'];
        if (profilePictureUrl.isNotEmpty) {
          // 4. Delete the profile picture from Firebase Storage using refFromURL
          Reference imageRef =
              FirebaseStorage.instance.refFromURL(profilePictureUrl);

          // Delete the image
          await imageRef.delete();
          print(
              'Group profile picture deleted successfully from Firebase Storage');
        }

        // Delete the group
        await groupsCollection.doc(doc.id).delete();
      }
    }
  }
}

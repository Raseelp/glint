import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glint/pages/imageFullScreenView.dart';

class BuilUserProfilePics extends StatefulWidget {
  final String userid;
  const BuilUserProfilePics({super.key, required this.userid});

  @override
  State<BuilUserProfilePics> createState() => _BuilUserProfilePicsState();
}

class _BuilUserProfilePicsState extends State<BuilUserProfilePics> {
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchProfileImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Imagefullscreenview(imgUrl: profileImageUrl, uploadedBy: ''),
            ));
      },
      child: CircleAvatar(
        radius: 50, // Adjust size as needed
        backgroundImage: profileImageUrl.isNotEmpty
            ? CachedNetworkImageProvider(
                profileImageUrl) // Display the image from Firestore URL
            : const AssetImage('assets/OIP.jpeg')
                as ImageProvider, // Placeholder if no image
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Future<void> fetchProfileImageUrl() async {
    try {
      // Reference to Firestore document for the group
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .get();

      // Check if the field exists and retrieve the URL
      if (userDoc.exists && userDoc['userprofilePictureUrl'] != null) {
        setState(() {
          profileImageUrl = userDoc['userprofilePictureUrl'];
        });
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }
}

import 'package:Glint/pages/imageFullScreenView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class builProfilePic extends StatefulWidget {
  final String groupId;
  const builProfilePic({super.key, required this.groupId});

  @override
  State<builProfilePic> createState() => _builProfilePicState();
}

class _builProfilePicState extends State<builProfilePic> {
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
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      // Check if the field exists and retrieve the URL
      if (groupDoc.exists && groupDoc['profilePictureUrl'] != null) {
        setState(() {
          profileImageUrl = groupDoc['profilePictureUrl'];
        });
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
    }
  }
}

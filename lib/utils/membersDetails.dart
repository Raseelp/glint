import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/utils/builUserProfilePics.dart';

class MemebersDetails extends StatefulWidget {
  final String name;
  final String phonenumber;

  const MemebersDetails({
    super.key,
    required this.name,
    required this.phonenumber,
  });

  @override
  State<MemebersDetails> createState() => _MemebersDetailsState();
}

class _MemebersDetailsState extends State<MemebersDetails> {
  String? userid;
  @override
  void initState() {
    _fetchuserid(widget.phonenumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 50.h,
            height: 50.h,
            child: BuilUserProfilePics(
              userid: userid!,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                widget.phonenumber,
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetchuserid(String phonenumber) async {
    String? id = await fetchUserIdByPhoneNumber(phonenumber);
    setState(() {
      userid = id;
    });
  }

  Future<String?> fetchUserIdByPhoneNumber(String phoneNumber) async {
    try {
      // Reference to the Firestore collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Query the collection for the document with the matching phone number
      QuerySnapshot querySnapshot = await usersCollection
          .where('Verified PhoneNumber', isEqualTo: phoneNumber)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document ID
        return querySnapshot.docs.first.id; // Document ID
      } else {
        print("No user found with that phone number.");
        return null; // No document found
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null; // Handle error
    }
  }
}

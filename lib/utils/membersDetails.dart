import 'package:Glint/utils/builUserProfilePics.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(17)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 50.h,
                height: 50.h,
                child: userid != null
                    ? BuilUserProfilePics(
                        userid: userid!,
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                          fontSize: 20, color: AppColors.whiteText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.phonenumber,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.lightGrayText),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
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
        return 'Loading...'; // No document found
      }
    } catch (e) {
      SnackBar(
        content: Text(e.toString()),
      );
      return null; // Handle error
    }
  }
}

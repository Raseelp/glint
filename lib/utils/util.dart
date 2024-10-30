import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
  ));
}




//  DocumentSnapshot userDoc = await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(widget.phonenumber)
//                   .get();

//               if (userDoc.exists) {
//                 // User exists, retrieve their details
//                 userName = userDoc['name'];
//                 userPhone = userDoc['phone'];

//                 // Store details in SharedPreferences
//                 await UserPreferences.setUserDetails(userName!, userPhone!);

//                 // Navigate to the main app screen
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Homepage(),
//                     ));

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Welcome Back $userName")),
//                 );
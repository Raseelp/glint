import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glint/pages/Settings.dart';
import 'package:glint/pages/createGroup.dart';
import 'package:glint/pages/joinGroup.dart';

import 'package:glint/utils/groupsCard.dart';

class Homepage extends StatefulWidget {
  final List<Map<String, dynamic>> userGroups;
  final String phoneNumberToUseAsUserId;
  final String username;
  final String userid;
  const Homepage(
      {super.key,
      required this.userGroups,
      required this.phoneNumberToUseAsUserId,
      required this.username,
      required this.userid});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenSettings(
                        name: widget.username,
                        phone: widget.phoneNumberToUseAsUserId,
                        userid: widget.userid,
                      ),
                    ));
              },
              icon: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: FaIcon(FontAwesomeIcons.userGear),
              ))
        ],
        backgroundColor: beige,
        automaticallyImplyLeading: false,
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 40.h),
            child: const Text(
              'Glint.',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      backgroundColor: beige,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(17),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3), // Shadow color with opacity
                      spreadRadius: 3, // Spread of the shadow
                      blurRadius: 5, // Blur intensity
                      offset: Offset(
                          6, 7), // Horizontal and vertical shadow position
                    ),
                  ]),
              width: double.infinity,
              height: 180.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hey,${widget.username}',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                  ),
                  const Text(
                    'Dont\'t forget to share your Daily moment\'s',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return Creategroup(
                                userid: widget.userid,
                                username: widget.username,
                                phonenumberasuserid:
                                    widget.phoneNumberToUseAsUserId,
                              );
                            },
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: darkBlue,
                          ),
                          width: 130.h,
                          height: 50.h,
                          child: const Center(
                            child: Text(
                              'Create',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return Joingroup(
                                phonenumber: widget.phoneNumberToUseAsUserId,
                              );
                            },
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: darkBlue,
                          ),
                          width: 130.h,
                          height: 50.h,
                          child: const Center(
                            child: Text(
                              'Join',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Groups',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          widget.userGroups.length == 0
              ? Expanded(
                  child: Container(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Join or Create Groups with your friends to Starts the Train of memories',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: widget.userGroups.length,
                      itemBuilder: (context, index) {
                        final group = widget.userGroups[index];
                        final groupname = group['groupname'];
                        final grouptheme = group['grouptheme'];
                        final groupid = group['id'];

                        return GroupCard(
                          userid: widget.userid,
                          username: widget.username,
                          groupName: groupname,
                          todayTheme: grouptheme,
                          groupid: groupid,
                          phoneNumberAsUserId: widget.phoneNumberToUseAsUserId,
                        );
                      }),
                ),
        ],
      ),
    );
  }
}

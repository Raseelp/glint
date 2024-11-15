import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glint/pages/Settings.dart';
import 'package:glint/pages/createGroup.dart';
import 'package:glint/pages/joinGroup.dart';
import 'package:glint/utils/colorPallet.dart';

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
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Glint.',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(17),
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black
                //         .withOpacity(0.3), // Shadow color with opacity
                //     spreadRadius: 3, // Spread of the shadow
                //     blurRadius: 5, // Blur intensity
                //     offset: const Offset(
                //         6, 7), // Horizontal and vertical shadow position
                //   ),
                // ]
              ),
              width: double.infinity,
              height: 180.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello,${widget.username}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                  const Text(
                    'Dont\'t forget to share your Daily moment\'s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGrayText),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
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
                            color: AppColors.blurple,
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
                            color: AppColors.blurple,
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
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          widget.userGroups.isEmpty
              ? const Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Join or Create Groups with your friends to Starts the Train of memories',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.lightGrayText),
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

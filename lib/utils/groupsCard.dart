import 'package:flutter/material.dart';
import 'package:glint/pages/groupfeed.dart';
import 'package:glint/utils/buildProfiePic.dart';

class GroupCard extends StatefulWidget {
  final String groupName;
  final String todayTheme;
  final String groupid;
  final String phoneNumberAsUserId;
  final String username;
  final String userid;

  const GroupCard({
    Key? key,
    required this.groupName,
    required this.todayTheme,
    required this.groupid,
    required this.phoneNumberAsUserId,
    required this.username,
    required this.userid,
  }) : super(key: key);

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Groupfeed(
                userid: widget.userid,
                username: widget.username,
                groupname: widget.groupName,
                theme: widget.todayTheme,
                code: widget.groupid,
                phoneNumberAsUserId: widget.phoneNumberAsUserId,
              ),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.3), // Shadow color with opacity
                spreadRadius: 3, // Spread of the shadow
                blurRadius: 5, // Blur intensity
                offset: Offset(4, 4), // Horizontal and vertical shadow position
              ),
            ]),
        height: 100,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                child: builProfilePic(
                  groupId: widget.groupid,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Today's Theme: ${widget.todayTheme}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

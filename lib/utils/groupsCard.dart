import 'package:Glint/pages/groupfeed.dart';
import 'package:Glint/utils/buildProfiePic.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  final String groupName;
  final String todayTheme;
  final String groupid;
  final String phoneNumberAsUserId;
  final String username;
  final String userid;
  final bool isGlintActive;

  const GroupCard({
    super.key,
    required this.groupName,
    required this.todayTheme,
    required this.groupid,
    required this.phoneNumberAsUserId,
    required this.username,
    required this.userid,
    required this.isGlintActive,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('isthe glin acitve${widget.isGlintActive}');
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
          color: AppColors.lightGray,
        ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            widget.groupName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteText),
                          ),
                        ),
                        widget.isGlintActive
                            ? Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Stack(children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        color: AppColors.notificationRed,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                  Positioned(
                                      right: 8,
                                      top: 2,
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                            color: AppColors.whiteText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ))
                                ]),
                              )
                            : Text('')
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Today's Theme: ${widget.todayTheme}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.lightGrayText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:Glint/pages/Settings.dart';
import 'package:Glint/pages/homepage.dart';
import 'package:Glint/pages/memories.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';

class Bottomenavbar extends StatefulWidget {
  final String username;
  final String userid;
  final String userphone;
  final List<Map<String, dynamic>> usergroups;
  const Bottomenavbar(
      {super.key,
      required this.username,
      required this.userid,
      required this.userphone,
      required this.usergroups});

  @override
  State<Bottomenavbar> createState() => _BottomenavbarState();
}

class _BottomenavbarState extends State<Bottomenavbar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Jump to corresponding page
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Homepage(
        phoneNumberToUseAsUserId: widget.userphone,
        userGroups: widget.usergroups,
        userid: widget.userid,
        username: widget.username,
      ), // First tab: Group
      MemoriesPage(userPhoneNumber: widget.userphone), // Second tab: Memories
      ScreenSettings(
        name: widget.username,
        phone: widget.userphone,
        userid: widget.userid,
        usergroups: widget.usergroups,
      ), // Third tab: Profile/Settings
    ];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Handle page swipe
        children: [
          Homepage(
            phoneNumberToUseAsUserId: widget.userphone,
            userGroups: widget.usergroups,
            userid: widget.userid,
            username: widget.username,
          ), // First tab: Group
          MemoriesPage(
              userPhoneNumber: widget.userphone), // Second tab: Memories
          ScreenSettings(
            name: widget.username,
            phone: widget.userphone,
            userid: widget.userid,
            usergroups: widget.usergroups,
          ), // Third tab: Profile/Settings
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: AppColors.darkBackground,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppColors.mediumLightGray,
          elevation: 10,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Group',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_album),
              label: 'Memories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile/Settings',
            ),
          ],
        ),
      ),
    );
  }
}

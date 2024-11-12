import 'package:flutter/material.dart';
import 'package:glint/pages/Settings.dart';
import 'package:glint/pages/homepage.dart';
import 'package:glint/pages/memories.dart';

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
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);
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
          userid: widget.userid), // Third tab: Profile/Settings
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
              userid: widget.userid), // Third tab: Profile/Settings
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: beige,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: darkBlue,
          elevation: 0,
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

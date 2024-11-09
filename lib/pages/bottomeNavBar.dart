import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
    );
  }
}

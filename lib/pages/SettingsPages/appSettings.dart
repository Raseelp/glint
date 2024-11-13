import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glint/pages/onbordeing.dart';
import 'package:glint/utils/colorPallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appsettings extends StatefulWidget {
  const Appsettings({super.key});

  @override
  State<Appsettings> createState() => _AppsettingsState();
}

class _AppsettingsState extends State<Appsettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.whiteText,
            )),
        backgroundColor: AppColors.secondaryBackground,
        title: const Padding(
          padding: EdgeInsets.only(right: 50),
          child: Center(
              child: Text(
            'Profile',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteText),
          )),
        ),
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const Text(
              'General',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGrayText),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              color: AppColors.lightGray,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Introduction',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle introduction tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'Themes',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle themes tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'About Us',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.lightGrayText,
                      ),
                      onTap: () {
                        // Handle feedback tap
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    SwitchListTile(
                      activeColor: AppColors.whiteText,
                      activeTrackColor: AppColors.blurple,
                      inactiveTrackColor: AppColors.lightGrayText,
                      inactiveThumbColor: AppColors.whiteText,

                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      value: true, // or a variable to control the state

                      onChanged: (bool value) {
                        // Handle switch toggle
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Account',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGrayText),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              color: AppColors.lightGray,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Delete account',
                        style: TextStyle(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.delete,
                        color: AppColors.notificationRed,
                      ),
                      onTap: () {
                        showDeleteDiologe();
                      },
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        'Sign out',
                        style: TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.exit_to_app,
                        color: AppColors.notificationRed,
                      ),
                      onTap: () {
                        showLogoutDiologe();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDiologe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Delete Account",
            style: TextStyle(color: AppColors.whiteText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Account Will Be Permanently Removed,You Wont Be Able To Use This Account Again,Do You Want To Continue?',
                style: TextStyle(
                  color: AppColors.darkGrayText,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  backgroundColor: AppColors.notificationRed,
                  elevation: 0,
                ),
                onPressed: () {},
                child: const SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Text(
                      'Yes,Delete',
                      style: TextStyle(color: AppColors.whiteText),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      backgroundColor: AppColors.lightGray,
                      elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Center(
                      child: Text(
                        'No,I Changed Mind',
                        style: TextStyle(color: AppColors.whiteText),
                      ),
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }

  void showLogoutDiologe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Logout",
            style: TextStyle(color: AppColors.whiteText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are You Sure You Want To Loguot',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.darkGrayText,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  backgroundColor: AppColors.notificationRed,
                  elevation: 0,
                ),
                onPressed: () {
                  logout();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onbordeing(),
                      ));
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: AppColors.whiteText),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      backgroundColor: AppColors.lightGray,
                      elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.whiteText),
                      ),
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    FirebaseAuth.instance.signOut();
  }
}

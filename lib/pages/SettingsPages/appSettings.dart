import 'package:flutter/material.dart';
import 'package:glint/utils/colorPallet.dart';

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
                        'Send feedback',
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
                        // Handle delete account
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
                        // Handle sign out
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
}

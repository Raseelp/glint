import 'package:Glint/pages/joinGroup.dart';
import 'package:Glint/pages/onbordeing.dart';
import 'package:Glint/pages/splashScreen.dart';
import 'package:Glint/provider/auth_provider.dart';
import 'package:Glint/utils/sharedpreffs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const Glint());
}

class Glint extends StatefulWidget {
  const Glint({super.key});

  @override
  State<Glint> createState() => _GlintState();
}

class _GlintState extends State<Glint> {
  bool isLoggedIn = false;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _getUserPhone();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loginStatus = prefs.getBool('isLoggedIn');

    setState(() {
      isLoggedIn = loginStatus ?? false;
    });
  }

  void _getUserPhone() async {
    Map<String, String?> userDetails = await UserPreferences.getUserDetails();
    setState(() {
      userPhone =
          userDetails['phone']; // Store the phone number in the variable
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        routes: {'/join': (context) => Joingroup(phonenumber: userPhone!)},
        home: isLoggedIn
            ? SplashScreen(phonenumberToCheck: userPhone!)
            : const Onbordeing(),
      ),
    );
  }
}

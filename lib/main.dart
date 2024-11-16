import 'package:Glint/pages/joinGroup.dart';
import 'package:Glint/pages/onbordeing.dart';
import 'package:Glint/pages/splashScreen.dart';
import 'package:Glint/provider/auth_provider.dart';
import 'package:Glint/utils/sharedpreffs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(Glint(
    hasSeenOnboarding: hasSeenOnboarding,
  ));
}

class Glint extends StatefulWidget {
  final bool hasSeenOnboarding;
  const Glint({super.key, required this.hasSeenOnboarding});

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
    bool didonbord = widget.hasSeenOnboarding;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(textTheme: GoogleFonts.albertSansTextTheme()),
        home: isLoggedIn
            ? SplashScreen(phonenumberToCheck: userPhone!)
            : Onbordeing(),
      ),
    );
  }
}

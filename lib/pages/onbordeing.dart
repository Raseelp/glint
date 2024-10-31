import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/phonenumber.dart';

class Onbordeing extends StatefulWidget {
  const Onbordeing({super.key});

  @override
  State<Onbordeing> createState() => _OnbordeingState();
}

class _OnbordeingState extends State<Onbordeing> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                padding:
                    EdgeInsets.symmetric(horizontal: 100.w, vertical: 12.h),
                elevation: 0,
                backgroundColor: Colors.lightBlue[500],
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Phonenumber()));
            },
            child: const Text(
              'Let\'s get started',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/phonenumber.dart';
import 'package:glint/utils/colorPallet.dart';

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
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                padding:
                    EdgeInsets.symmetric(horizontal: 100.w, vertical: 12.h),
                elevation: 0,
                backgroundColor: AppColors.blurple,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Phonenumber()));
            },
            child: const Text(
              'Let\'s get started',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }
}

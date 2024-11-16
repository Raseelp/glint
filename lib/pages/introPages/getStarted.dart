import 'package:Glint/pages/phonenumber.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class getStarted extends StatelessWidget {
  const getStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        title: Center(
          child: Text(
            'Glint',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: AppColors.lightGray,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              SvgPicture.asset(
                'assets/images/fourth.svg',
                width: 300,
                height: 300,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Are You Ready',
                style: TextStyle(
                    color: AppColors.lightGrayText,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                textAlign: TextAlign.center,
                'Glint brings your crew closer! Share themed photos, spark 2-minute challenges, and rack up Glint Points while making memories that last. Ready to turn everyday moments into something magical?',
                style: TextStyle(color: AppColors.whiteText, fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 120.w, vertical: 12.h),
                      elevation: 0,
                      backgroundColor: AppColors.blurple,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    _completeOnboarding(context);
                  },
                  child: Text('Let’s do this!',
                      style:
                          TextStyle(color: AppColors.whiteText, fontSize: 18)))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Phonenumber()),
    );
    bool fordebg = prefs.getBool('hasSeenOnboarding') ?? false;
    print(fordebg);
  }
}

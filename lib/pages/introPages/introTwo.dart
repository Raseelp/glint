import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Introtwo extends StatelessWidget {
  const Introtwo({super.key});

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
              Padding(
                padding: const EdgeInsets.only(right: 23),
                child: SvgPicture.asset(
                  'assets/images/third.svg',
                  width: 300,
                  height: 300,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Share Glints Daily',
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
                'Share a Glint, start the clock, and watch the fun unfold! Invite others to share, and you’ll all earn points together!',
                style: TextStyle(color: AppColors.whiteText, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

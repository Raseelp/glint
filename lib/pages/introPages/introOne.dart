import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroOne extends StatelessWidget {
  const IntroOne({super.key});

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
                'assets/images/first.svg',
                width: 300,
                height: 300,
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Welcome to Glint!',
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
                'Glint is all about sharing moments with your group. Capture and share your photos based on daily themes',
                style: TextStyle(color: AppColors.whiteText, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

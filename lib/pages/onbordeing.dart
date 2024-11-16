import 'package:Glint/pages/introPages/getStarted.dart';
import 'package:Glint/pages/introPages/introOne.dart';
import 'package:Glint/pages/introPages/introThree.dart';
import 'package:Glint/pages/introPages/introTwo.dart';
import 'package:Glint/pages/phonenumber.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onbordeing extends StatefulWidget {
  const Onbordeing({super.key});

  @override
  State<Onbordeing> createState() => _OnbordeingState();
}

class _OnbordeingState extends State<Onbordeing> {
  bool onLastPage = false;
  PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Stack(
      children: [
        PageView(
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 2);
            });
          },
          controller: _controller,
          children: [IntroOne(), Introtwo(), IntroThree()],
        ),
        Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                        color: AppColors.lightGrayText,
                        fontSize: 20,
                        decoration: TextDecoration.none),
                  ),
                ),
                SmoothPageIndicator(controller: _controller, count: 3),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => getStarted(),
                            ),
                          );
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                              color: AppColors.lightGrayText,
                              fontSize: 20,
                              decoration: TextDecoration.none),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(
                              color: AppColors.lightGrayText,
                              fontSize: 20,
                              decoration: TextDecoration.none),
                        ),
                      )
              ],
            )),
      ],
    );
  }
}

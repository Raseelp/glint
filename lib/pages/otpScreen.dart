import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glint/pages/splashScreen.dart';

import 'package:glint/provider/auth_provider.dart';
import 'package:glint/utils/colorPallet.dart';
import 'package:glint/utils/sharedpreffs.dart';
import 'package:glint/utils/util.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen(
      {super.key, required this.verificationid, required this.phonenumber});
  final String verificationid;
  final String phonenumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        automaticallyImplyLeading: false,
        title: const Center(
            child: Text(
          'Glint.',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteText),
        )),
      ),
      backgroundColor: AppColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Verify Your PhoneNumber',
                        style: TextStyle(color: AppColors.lightGrayText),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Pinput(
                        defaultPinTheme: defaultPinTheme,
                        length: 6,
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'The Verification code sent to  ',
                            style: TextStyle(color: AppColors.lightGrayText),
                          ),
                          Text(widget.phonenumber,
                              style: const TextStyle(
                                color: AppColors.whiteText,
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Resend Code',
                        style: TextStyle(color: AppColors.blurple),
                      ),
                      SizedBox(
                        height: 330.h,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 135.w, vertical: 12.h),
                              elevation: 0,
                              backgroundColor: AppColors.blurple,
                              foregroundColor: Colors.black),
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOtp(context, otpCode!);
                            } else {
                              showSnackBar(context, "Enter 6-Digit Code");
                            }
                          },
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationid,
        userOtp: userOtp,
        onSuccess: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SplashScreen(phonenumberToCheck: widget.phonenumber)),
              (route) => false);
          UserPreferences().saveLoginState(true);
        });
  }

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.blurple),
    ),
  );
}

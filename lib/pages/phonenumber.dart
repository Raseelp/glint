import 'package:Glint/provider/auth_provider.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Phonenumber extends StatefulWidget {
  const Phonenumber({super.key});

  @override
  State<Phonenumber> createState() => _PhonenumberState();
}

class _PhonenumberState extends State<Phonenumber> {
  final TextEditingController phonecontroller = TextEditingController();

  Country selectedCountry = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: "India",
      displayName: "India ",
      displayNameNoCountryCode: "IN",
      e164Key: "");
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
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
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Whats Your Phonenumber',
                style: TextStyle(color: AppColors.lightGrayText),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.whiteText),
                          borderRadius: BorderRadius.circular(17)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                  bottomSheetHeight: 550),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            );
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                            style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.lightGrayText,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 50, bottom: 50),
                      child: TextField(
                        style: const TextStyle(
                            color: AppColors.lightGrayText,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                        controller: phonecontroller,
                        decoration: const InputDecoration(
                          hintText: '78363 63263',
                          hintStyle: TextStyle(
                              color: AppColors.mediumLightGray,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'By continuing you are agreed to our Privacy Policy and Terms and Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.lightGrayText),
              ),
              SizedBox(
                height: 330.h,
              ),
              ElevatedButton(
                  onPressed: () {
                    sendPhoneNumber();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 135.w, vertical: 12.h),
                      elevation: 0,
                      backgroundColor: AppColors.blurple,
                      foregroundColor: Colors.white),
                  child: const Text(
                    'Sent OTP',
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phonecontroller.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../constants/image_strings.dart';
import '../constants/my_colors.dart';
import '../constants/text_strings.dart';
import '../provider/my_auth_provider.dart';
import '../themes/text_themes.dart';
import '../widgets/snackbar_widget.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    // final isLoading = Provider.of<MyAuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(12.0),
        // child: isLoading == true
        //     ? const Center(
        //   child: CircularProgressIndicator(
        //     color: Colors.cyan,
        //   ),
        // )
         child : Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
            const SizedBox(height: 150, width: 150, child: Image(image: AssetImage(otpIllustration))),
            const SizedBox(height: 30),
            const Text(
              otpScreenTitle,
              style: TextStyle(
                color: MyColors.text,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Pinput(
              length: 6,
              showCursor: true,
              defaultPinTheme: PinTheme(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.cyan),
                  ),
                  textStyle: TextThemes.t3),
              onCompleted: (value) {
                setState(() {
                  otpCode = value;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (otpCode != null) {
                    verifyOtp(context, otpCode!);
                  } else {
                    showSnackBar(context, "Enter a valid OTP");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: MyColors.alter,
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Didn't receive any code?",
              style: TextStyle(
                color: MyColors.text,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Resend OTP",
              style: TextStyle(
                color: Colors.cyan,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String otp) {
    final ap = Provider.of<MyAuthProvider>(context, listen: false);
    ap.verifyOtp(context: context, verificationId: widget.verificationId, userOtp: otp, onSuccess: () {
      Navigator.pushNamedAndRemoveUntil(context, '/home_screen', (route) => false);
    });
  }

}

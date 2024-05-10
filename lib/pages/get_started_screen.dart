import 'package:flutter/material.dart';

import '../constants/image_strings.dart';
import '../constants/my_colors.dart';
import '../constants/text_strings.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              appName,
              style: TextStyle(color: MyColors.text, fontFamily: 'Futura', fontWeight: FontWeight.w400, fontSize: 24),
            ),
            const Image(image: AssetImage(welcomeIllustration)),
            const Text(
              welcomeScreenTitle,
              style: TextStyle(
                color: MyColors.text,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                    color: MyColors.alter,
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
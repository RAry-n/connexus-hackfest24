import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/image_strings.dart';
import '../constants/my_colors.dart';
import '../constants/text_strings.dart';
import '../models/user.dart';
import '../provider/my_auth_provider.dart';
import '../themes/text_themes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneEditingController = TextEditingController();
  Country selectedCountry = Country(phoneCode: "91", countryCode: "IN", e164Sc: 0, geographic: true, level: 1, name: "India", example: "India", displayName: "India", displayNameNoCountryCode: "IN", e164Key: "");

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const SizedBox(height: 250, width: 250, child: Image(image: AssetImage(registerIllustration))),
            const SizedBox(height: 30),
            const Text(
              registerScreenTitle,
              style: TextStyle(
                color: MyColors.text,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: phoneEditingController,
              cursorColor: Colors.cyan,
              style: TextThemes.t4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Enter phone number",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.cyan),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 8.0, top: 14.0, right: 8.0),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                            context: context,
                            countryListTheme: const CountryListThemeData(bottomSheetHeight: 500),
                            onSelect: (value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            });
                      },
                      child: Text(
                        "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                        style: const TextStyle(fontSize: 16, fontFamily: 'Futura', fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => sendPhoneNumber(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Send OTP",
                  style: TextStyle(
                    color: MyColors.alter,
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    setState(() {
      _isLoading = true;
    });

    final ap = Provider.of<MyAuthProvider>(context, listen: false);
    String phoneNumber = phoneEditingController.text.trim();
    UserModel userData = UserModel(id: phoneNumber, name: "name", photo: "photoUrl", email: phoneNumber);
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber", userData).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
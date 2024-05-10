import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/otp_screen.dart';

class MyAuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  MyAuthProvider() {
    // No need to call checkSignIn() here as it's already called in signInWithPhone
  }

  Future<void> checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool("is_signedIn") ?? false;
    notifyListeners();
  }

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      // Show loading screen
      _isLoading = true; // Update isLoading before starting verification
      notifyListeners();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          // Navigate to OTP screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(verificationId: verificationId)));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      // Show error message
      showSnackBar(context, e.message.toString());
    } finally {
      // Hide loading screen
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    try {
      // Show loading screen
      _isLoading = true;
      notifyListeners();

      PhoneAuthCredential credentials = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credentials);
      User? user = userCredential.user;

      if (user != null) {
        // Update sign-in status
        final SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setBool("is_signedIn", true);
        _isSignedIn = true; // Update sign-in status in-memory
        notifyListeners();

        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      // Show error message
      showSnackBar(context, e.message.toString());
    } finally {
      // Hide loading screen
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to show snackbar
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}


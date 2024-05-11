


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/utils.dart';
import '../models/user.dart';
import '../pages/otp_screen.dart';

class MyAuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? currUser;

  MyAuthProvider() {
    // No need to call checkSignIn() here as it's already called in signInWithPhone
  }

  Future<void> checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool("is_signedIn") ?? false;
    notifyListeners();
  }

  Future<void> signInWithPhone(BuildContext context, String phoneNumber, UserModel userData) async {
    try {
      // Show loading screen
      // notifyListeners();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          showSnackBar(context, error.message.toString());
          // throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          currUser = userData;
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
      // notifyListeners();

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
        // currUser?.id = user.uid;
        await userExists(id: currUser!.id).then((exist) async {
          if(exist){
            FirebaseMessaging.instance.getToken().then(
                    (token) async {
                  await usersCollection.doc(currUser!.id).update(
                      {
                        'tokens': FieldValue.arrayUnion([token])
                      }
                  );
                }
            );
            onSuccess();
          }
          else{
            createUser(user: currUser!).then(
                    (created) async {
                  if(created){
                    onSuccess();
                  }
                }
            );
          }
        });


      }
    } on FirebaseAuthException catch (e) {
      // Show error message
      showSnackBar(context, e.message.toString());
    } finally {
      // Hide loading screen

      notifyListeners();
    }
  }

  Future<bool> createUser({required UserModel user}) async {
    bool created = false;
    await FirebaseMessaging.instance.getToken().then(
          (token) async {
        await usersCollection.doc(user.id).set(
          {
            'id' : user.id,
            'name' : user.name,
            'email' : user.email,
            'photo' : user.photo,
            'tokens' : [token],
          },
        ).then((value) => created =true);
      },
    );
    return created;
  }

  Future<bool> userExists({required String id}) async {

    bool exists = false;

    await usersCollection.where('id', isEqualTo: id).get().then( (user) {
      exists = user.docs.isEmpty ? false : true;
    });

    return exists;
  }

  // Helper method to show snackbar
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}


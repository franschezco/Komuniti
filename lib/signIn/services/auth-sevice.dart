import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

   signInWithGoogle(BuildContext context) async {
    try {
      print('madrid');
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('madrid1');
        // User canceled the sign-in process
        // Close loading indicator
        Navigator.of(context).pop();
        return null;
      }

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential using the obtained auth details
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('madrid2');
      // Close loading indicator
      Navigator.of(context).pop();

      return userCredential;
    } catch (error) {
      // Handle sign-in errors
      print('Sign In with Google failed: $error');
      print('madrid3');
      // Close loading indicator
      Navigator.of(context).pop();

      return null;
    }
  }
}
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:komuniti/constant/color.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({Key? key}) : super(key: key);

  @override
  _StarterScreenState createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  late VideoPlayerController _videoPlayerController;
  late bool _isVideoInitialized = false;
  bool _isLoading = false;
  late String pushToken;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String?> requestNotificationPermission() async {
    if (!mounted) return null; // Check if the state object is still mounted

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    if (token != null) {
      setState(() {
        pushToken = token;
      });
      print('Push Token: $token');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    return pushToken;
  }



  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? gUser = await googleSignIn.signIn();

    // Obtain auth detail from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create a new credential for the user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Sign in with the credential
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Get the user's email, ID, and name
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userName = FirebaseAuth.instance.currentUser?.displayName;

    // Get the user's display image URL
    final userPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    // Reference the "users" collection
    final userRef = FirebaseFirestore.instance.collection('users');

    // Check if user exists in Firestore collection "users" based on email
    final emailQuery = await userRef.where('email', isEqualTo: userEmail).get();

    // Check if user exists in Firestore collection "users" based on ID
    final idQuery = await userRef.where('id', isEqualTo: userId).get();

    if (emailQuery.docs.isEmpty && idQuery.docs.isEmpty) {
      // User doesn't exist, create a new entry with the specified userID as document ID
      await userRef.doc(userId).set({
        'email': userEmail,
        'id': userId,
        'name': userName,
        'photoUrl': userPhotoUrl,
        'token': pushToken
      });

      // If the user has a photo URL, download the image and upload it to Firebase Storage
      if (userPhotoUrl != null) {
        final response = await http.get(Uri.parse(userPhotoUrl));

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/user_photo.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);

        final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
        final uploadTask = await storageRef.putFile(tempFile);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        await userRef.doc(userId).update({
          'photoUrl': imageUrl,

        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller
    _videoPlayerController = VideoPlayerController.asset('assets/images/starter.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      })
      ..setLooping(true)
      ..play();
    requestNotificationPermission();
  }

  @override
  void dispose() {
    // Dispose the video player controller when not needed anymore
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isVideoInitialized ?
               Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.65,
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            ),
          )
              :Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Image.asset(
              'assets/images/falback.jpg', // Replace with your fallback image path
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'KOMU',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'GFSDidot',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'NITI',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'GFSDidot',
                              fontWeight: FontWeight.bold,
                              color: bgColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Join now and Connect to millions of users around the globe',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Rufina',
                        fontWeight: FontWeight.bold,
                        color: bgDarkColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  Center(
                    child: Text(
                      'By signing up, you agree with our terms and conditions',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GFSDidot',
                        fontWeight: FontWeight.w100,
                        color: bgDarkColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        await signInWithGoogle();

                        setState(() {
                          _isLoading = false;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(bgDarkColor),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                          )
                          : SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google-logo.png',
                                height: 24,
                                width: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
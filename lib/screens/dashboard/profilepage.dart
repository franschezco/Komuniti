import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/constant/color.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentUserName = '';
  String currentUserphotoUrl = '';
  String currentUserEmail = '';
  @override
  void initState() {
    super.initState();
    getCurrentUserName();
  }
  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Handle any error that occurred during logout
      print('Error logging out: $e');
    }
  }
  void getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserName = user.displayName ?? '';
        currentUserEmail = user.email ?? '';
        currentUserphotoUrl = user.photoURL ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Profile', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Product Sans',
          fontSize: 18,
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: CachedNetworkImageProvider(
                currentUserphotoUrl,
              ),
            ),
            SizedBox(height: 16),
            Text(
              currentUserName,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Flutter Developer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(currentUserEmail, style: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Product Sans',
                fontSize: 18,
              )),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+1 123-456-7890', style: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Product Sans',
                fontSize: 18,
              )),),


            SizedBox(height: 24),
            ElevatedButton(
              onPressed:logout,
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // Add more ListTile widgets for additional information
          ],
        ),
      ),
    );
  }
}

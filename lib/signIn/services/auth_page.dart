import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komuniti/screens/dashboard/dashboard.dart';
import 'package:komuniti/starter.dart';

class AuthPage extends StatelessWidget {
   AuthPage({Key? key}) : super(key: key);
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){

            if(snapshot.hasData){
              return  DashboardPage();
            }else{
              return StarterScreen();
            }
          }
      ),
    );
  }
}
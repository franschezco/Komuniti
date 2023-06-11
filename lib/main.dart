import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:get/get.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/firebase_options.dart';
import 'package:komuniti/screens/chat/contoller.dart';
import 'package:komuniti/signIn/services/auth_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}





class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.put(ChatPageController());
      }),
      title: 'Komuniti',
      theme: ThemeData(
        primaryColor: bgColor,
        scaffoldBackgroundColor: whiteColor
      ),
      debugShowCheckedModeBanner: false,
      home:  AnimatedSplashScreen(
          duration: 4500,
          backgroundColor: bgColor ,
          splash: 'assets/images/logo.png',
          nextScreen:  AuthPage(),
          pageTransitionType: PageTransitionType.rightToLeftWithFade

      ),
    );
  }
}


_initializeFirebase() async{
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
  print(result);
}
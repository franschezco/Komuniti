// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0rcpsu966dREpG1nQUqUBPyP7VN2ggxE',
    appId: '1:792725473760:web:c9b69e6987167ee513c385',
    messagingSenderId: '792725473760',
    projectId: 'komuniti-68cad',
    authDomain: 'komuniti-68cad.firebaseapp.com',
    storageBucket: 'komuniti-68cad.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXAHWY_RwLk2vQ5TOAUE_LotWqYU2TlQk',
    appId: '1:792725473760:android:61257edbf39c8d9613c385',
    messagingSenderId: '792725473760',
    projectId: 'komuniti-68cad',
    storageBucket: 'komuniti-68cad.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsRAEwE0pk8Tm2BISNY7XRw6sMBBgXIGU',
    appId: '1:792725473760:ios:604ea9c79b2d536513c385',
    messagingSenderId: '792725473760',
    projectId: 'komuniti-68cad',
    storageBucket: 'komuniti-68cad.appspot.com',
    iosClientId: '792725473760-noqo49smt92dbhf9ghpvv6ceb7p334te.apps.googleusercontent.com',
    iosBundleId: 'com.example.komuniti',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsRAEwE0pk8Tm2BISNY7XRw6sMBBgXIGU',
    appId: '1:792725473760:ios:604ea9c79b2d536513c385',
    messagingSenderId: '792725473760',
    projectId: 'komuniti-68cad',
    storageBucket: 'komuniti-68cad.appspot.com',
    iosClientId: '792725473760-noqo49smt92dbhf9ghpvv6ceb7p334te.apps.googleusercontent.com',
    iosBundleId: 'com.example.komuniti',
  );
}

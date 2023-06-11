import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  String? getCurrentUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName;
    } else {
      return null;
    }
  }

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }
}

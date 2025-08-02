import 'package:get/get.dart';

class HomeController extends GetxController {
  int selectedIndex = 0;

  updateSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }

  onItemTapped(int index) async {
    selectedIndex = index;
    
    update();
  }

  static HomeController get i => Get.put(HomeController());
}
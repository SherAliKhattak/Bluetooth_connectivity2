import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slurvo_task/screens/bluetooth_scanning_screen.dart';
import 'package:slurvo_task/widget/common_image_view_widget.dart';
import 'package:slurvo_task/widget/my_text_widget.dart';

AppBar logoAppBar(bool isScanningPage) {
  return AppBar(
    backgroundColor: const Color(
        0xFF1A1A1A,
      ),
    centerTitle: true,
    elevation: 2.0,
    shadowColor: Colors.grey,
    leadingWidth: 40,
    toolbarHeight: 64,
    leading: Padding(
      padding: const EdgeInsets.only(left: 15),
      child: CommonImageView(
        fit: BoxFit.contain,
        assetImageColor: Colors.white,
        height: 30,
        width: 30,
        imagePath: "assets/person.png",
        radius: 25,
      ),
    ),
    title: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyText(
          text: "SLURVO",
          color: Colors.white,
          weight: FontWeight.w900,
          size: 30,
          fontFamily: GoogleFonts.cabin().fontFamily,
        ),
      ],
    ),
    actions: [
      isScanningPage == false
          ? IconButton(icon: Icon(Icons.settings, color: Colors.white,size: 30,), onPressed: () {
            Get.to(()=>BluetoothScreen());
          })
          : SizedBox.shrink(),
      SizedBox(width: 10),
    ],
  );
}

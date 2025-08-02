// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:slurvo_task/screens/bottomNavbar.dart';
import 'package:slurvo_task/screens/home.dart';

// Example usage in a complete app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
        0xFF1A1A1A,
      ),
        appBarTheme: AppBarTheme(
          color:  const Color(
        0xFF1A1A1A,
      ),
      ),),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        backgroundColor: Color.fromRGBO(23, 23, 23, 0.55),

        body: Center(child: BtmNavBar()),
      ),
    );
  }
}

Future< void> main() async{

  // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

// Request higher connection priority

// optional
FlutterBluePlus.logs.listen((String s){
    // send logs anywhere you want
});

  runApp(MyApp());
}

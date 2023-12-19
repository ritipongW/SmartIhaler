import 'package:flutter/material.dart';
import 'package:inhaler/home_page1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData.light(),
      title: "โปรแกรมบันทึกผล Smart Inhaler",
      home: const HomePage_main(title: "โปรแกรมบันทึกผล Smart Inhaler"),
    );
  }
}


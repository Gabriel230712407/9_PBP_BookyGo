import 'package:flutter/material.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/onboarding/pages/welcome_page.dart';
import 'package:frontend/features/hotel/pages/hotel_list_page.dart';
import 'package:frontend/features/room/pages/room_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookyGo',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: WelcomePage(),
    );
  }
}

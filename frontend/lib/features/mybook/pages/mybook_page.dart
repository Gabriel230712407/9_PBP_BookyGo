import 'package:flutter/material.dart';
import '../widgets/mybook_action_button.dart';
import '../widgets/mybook_header.dart';
import '../widgets/mybook_recommendation_section.dart';

class MyBookPage extends StatelessWidget {
  const MyBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F7FF);
    const darkBlue = Color(0xFF1F2A44);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const MyBookHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  const SizedBox(height: 34),

                  Image.asset(
                    'assets/images/onboarding_bag.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'No active orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: darkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  MyBookActionButton(
                    text: 'Book now',
                    onPressed: () {
                      // nanti bisa diarahkan ke page booking / hotel list
                    },
                  ),

                  const SizedBox(height: 56),

                  const MyBookRecommendationSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
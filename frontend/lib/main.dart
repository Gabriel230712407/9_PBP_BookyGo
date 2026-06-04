import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/onboarding/pages/splash_page.dart';
import 'package:frontend/features/profile/providers/reminder_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderProvider()..load(),
        ),
      ],
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BookyGo',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Arial',
          scaffoldBackgroundColor: AppColors.bgVeryLight,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryEnd,
            primary: AppColors.primaryEnd,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}

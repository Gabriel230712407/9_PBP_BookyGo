import 'package:flutter/material.dart';

import '../../../core/auth/services/auth_service.dart';
import '../pages/main_nav_page.dart';

Future<void> openMainNavTab(BuildContext context, int index) async {
  final session = await AuthService.currentSession();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => MainNavPage(
        initialIndex: index,
        isGuest: session == null,
        userEmail: session?.user.email,
        userName: session?.user.name,
      ),
    ),
    (route) => false,
  );
}

import 'package:flutter/material.dart';

import '../../navigation/utils/main_nav_launcher.dart';
import '../pages/email_auth_page.dart';

class GuestActionGuard {
  static bool ensureCanBook(BuildContext context, {required bool isGuest}) {
    if (!isGuest) return true;
    redirectToGuestPrompt(context);
    return false;
  }

  static bool ensureCanUseWishlist(
    BuildContext context, {
    required bool isGuest,
  }) {
    if (!isGuest) return true;
    redirectToGuestPrompt(context);
    return false;
  }

  static Future<void> redirectToGuestPrompt(BuildContext context) {
    return openMainNavTab(context, 3);
  }

  static Future<void> openSignIn(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailAuthPage()),
    );
  }
}

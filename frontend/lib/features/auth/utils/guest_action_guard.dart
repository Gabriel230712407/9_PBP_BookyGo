import 'package:flutter/material.dart';

import '../pages/email_auth_page.dart';

class GuestActionGuard {
  static const bookingMessage = 'Silakan login terlebih dahulu untuk booking.';
  static const wishlistMessage =
      'Silakan login terlebih dahulu untuk menambahkan wishlist.';
  static const bookingOrWishlistMessage =
      'Silakan login terlebih dahulu untuk booking / menambahkan wishlist.';

  static bool ensureCanBook(BuildContext context, {required bool isGuest}) {
    if (!isGuest) return true;
    showLoginRequired(context, bookingMessage);
    return false;
  }

  static bool ensureCanUseWishlist(
    BuildContext context, {
    required bool isGuest,
  }) {
    if (!isGuest) return true;
    showLoginRequired(context, wishlistMessage);
    return false;
  }

  static void showLoginRequired(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Sign In',
          onPressed: () => openSignIn(context),
        ),
      ),
    );
  }

  static void openSignIn(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EmailAuthPage()));
  }
}

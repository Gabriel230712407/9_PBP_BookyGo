import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import 'welcome_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _splashAsset = 'assets/images/splash-load.gif';
  static const _fallbackDuration = Duration(milliseconds: 4670);
  static const _durationTrim = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    unawaited(_playSplashThenNavigate());
  }

  Future<void> _playSplashThenNavigate() async {
    final splashDuration = await _getGifDuration();
    final effectiveDuration = splashDuration > _durationTrim
        ? splashDuration - _durationTrim
        : splashDuration;

    await Future<void>.delayed(effectiveDuration);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
    );
  }

  Future<Duration> _getGifDuration() async {
    try {
      final data = await rootBundle.load(_splashAsset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());
      final codec = await ui.instantiateImageCodecFromBuffer(buffer);

      var totalDuration = Duration.zero;
      for (var index = 0; index < codec.frameCount; index++) {
        final frame = await codec.getNextFrame();
        totalDuration += frame.duration;
        frame.image.dispose();
      }

      return totalDuration == Duration.zero ? _fallbackDuration : totalDuration;
    } catch (_) {
      return _fallbackDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(_splashAsset),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

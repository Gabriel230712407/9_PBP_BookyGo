import 'package:flutter/material.dart';

import '../utils/image_path_resolver.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (ImagePathResolver.isRemotePath(imagePath) ||
        imagePath.startsWith('storage/') ||
        imagePath.startsWith('/storage/')) {
      return Image.network(
        ImagePathResolver.toDisplayUrl(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}

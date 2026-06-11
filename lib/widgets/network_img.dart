import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class NetworkImg extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  const NetworkImg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: const Color(0xFFE2E8F0),
      child: const Icon(Icons.image_outlined, color: AppColors.muted),
    );

    Widget child;
    if (url == null || url!.isEmpty) {
      child = placeholder;
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (c, _) => Container(width: width, height: height, color: const Color(0xFFEEF2F7)),
        errorWidget: (c, _, _) => placeholder,
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

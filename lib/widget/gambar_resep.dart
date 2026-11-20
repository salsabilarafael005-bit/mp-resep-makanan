import 'dart:convert';

import 'package:flutter/material.dart';

class GambarResep extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;

  const GambarResep({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 12,
  });

  Widget _placeholder(BuildContext context) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_outlined, size: 40),
      );

  @override
  Widget build(BuildContext context) {
    Widget isi;

    if (url.isEmpty) {
      isi = _placeholder(context);
    } else if (url.startsWith('http')) {
      isi = Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (c, _, _) => _placeholder(c),
      );
    } else {
      try {
        isi = Image.memory(
          base64Decode(url),
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (c, _, _) => _placeholder(c),
        );
      } catch (_) {
        isi = _placeholder(context);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isi,
    );
  }
}
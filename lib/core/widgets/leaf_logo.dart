import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';

/// Inline SVG botanical mark used on the splash and auth headers. Kept inline
/// so it ships without external asset dependencies and renders crisply at any
/// size and in RTL.
class LeafLogo extends StatelessWidget {
  const LeafLogo({super.key, this.size = 96, this.color});

  final double size;
  final Color? color;

  static const String _svg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M50 8 C24 26 20 62 50 92 C80 62 76 26 50 8 Z"
        fill="COLOR" fill-opacity="0.18"/>
  <path d="M50 14 C30 30 28 60 50 86 C72 60 70 30 50 14 Z"
        fill="COLOR"/>
  <path d="M50 20 L50 84 M50 40 L34 32 M50 40 L66 32 M50 56 L32 50 M50 56 L68 50 M50 70 L38 66 M50 70 L62 66"
        stroke="#F5F0E8" stroke-width="2.4" stroke-linecap="round" fill="none"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.leafGreen;
    final String svg = _svg.replaceAll(
      'COLOR',
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    );
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      semanticsLabel: 'PlantSense leaf logo',
    );
  }
}

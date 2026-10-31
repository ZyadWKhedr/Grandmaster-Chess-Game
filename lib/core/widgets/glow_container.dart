import 'package:flutter/material.dart';

/// Provides a modern ambient background glow for grandmaster aesthetics.
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0x336366F1),
    this.blurRadius = 32,
    this.spreadRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}


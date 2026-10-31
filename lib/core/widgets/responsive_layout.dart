import 'package:flutter/material.dart';

/// Clean responsive builder switching between narrow and wide presentation.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) narrow;
  final Widget Function(BuildContext context)? wide;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.narrow,
    this.wide,
    this.breakpoint = 768,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint && wide != null) {
          return wide!(context);
        }
        return narrow(context);
      },
    );
  }
}


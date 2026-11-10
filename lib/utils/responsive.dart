import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static int getGridCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 750) return 3;
    return 2;
  }

  static double getGridAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 0.72;
    if (width >= 750) return 0.70;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 1100) {
      return desktop;
    } else if (width >= 650 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

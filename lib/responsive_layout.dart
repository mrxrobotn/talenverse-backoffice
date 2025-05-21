import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget tablet;
  final Widget computer;

  const ResponsiveLayout({
    super.key,
    required this.phone,
    required this.tablet,
    required this.computer,
  });

  static const int _phoneMaxWidth = 550;
  static const int _tabletMaxWidth = 800;

  static bool isPhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < _phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _phoneMaxWidth && width < _tabletMaxWidth;
  }

  static bool isComputer(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletMaxWidth;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < _phoneMaxWidth) {
      return phone;
    } else if (screenWidth < _tabletMaxWidth) {
      return tablet;
    } else {
      return computer;
    }
  }
}

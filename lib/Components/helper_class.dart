import 'package:flutter/material.dart';
class HelperClass extends StatelessWidget {
  final Widget desktop;
  final Widget tablet;
  final Widget mobile;
  final double paddingWidth;
  final Color bgColor;

  const HelperClass({
    Key? key,
    required this.desktop,
    required this.tablet,
    required this.mobile,
    required this.paddingWidth,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 800 && constraints.maxWidth < 1200) {
          return
            tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

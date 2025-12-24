import 'package:flutter/material.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const StyledCard({
    super.key,
    required this.child,
    this.elevation = 4,
    this.borderRadius = 12,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}

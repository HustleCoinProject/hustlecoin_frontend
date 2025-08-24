// lib/utils/responsive_screen.dart

import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// A responsive screen wrapper that automatically applies responsive design
/// This widget ensures all child widgets use the responsive system
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final bool enableSafeArea;
  final Color? backgroundColor;

  const ResponsiveScreen({
    super.key,
    required this.child,
    this.enableSafeArea = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context) {
        Widget content = child;

        if (enableSafeArea) {
          content = SafeArea(child: content);
        }

        return Scaffold(backgroundColor: backgroundColor, body: content);
      },
    );
  }
}

/// Extension methods for responsive design
extension ResponsiveWidgetExtensions on Widget {
  /// Wrap widget with responsive padding
  Widget responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    EdgeInsets padding;

    if (all != null) {
      padding = ResponsiveUtils.p(all);
    } else if (horizontal != null || vertical != null) {
      padding = ResponsiveUtils.pSymmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    } else {
      padding = ResponsiveUtils.pLTRB(
        left ?? 0,
        top ?? 0,
        right ?? 0,
        bottom ?? 0,
      );
    }

    return Padding(padding: padding, child: this);
  }

  /// Wrap widget with responsive margin
  Widget responsiveMargin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    EdgeInsets margin;

    if (all != null) {
      margin = EdgeInsets.all(all.s);
    } else if (horizontal != null || vertical != null) {
      margin = EdgeInsets.symmetric(
        horizontal: (horizontal ?? 0).s,
        vertical: (vertical ?? 0).s,
      );
    } else {
      margin = EdgeInsets.fromLTRB(
        (left ?? 0).s,
        (top ?? 0).s,
        (right ?? 0).s,
        (bottom ?? 0).s,
      );
    }

    return Container(margin: margin, child: this);
  }

  /// Add responsive sized box gap after this widget
  Widget withResponsiveGap({double? width, double? height}) {
    return Column(
      children: [
        this,
        SizedBox(width: width?.s, height: height?.s),
      ],
    );
  }
}

/// Responsive Text widget that automatically scales font size
class RText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;
  final List<Shadow>? shadows;

  const RText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize.f,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      ),
    );
  }
}

/// Responsive SizedBox
class RGap extends StatelessWidget {
  final double? width;
  final double? height;

  const RGap({super.key, this.width, this.height});

  const RGap.h(double height, {super.key}) : width = null, height = height;
  const RGap.w(double width, {super.key}) : width = width, height = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width?.s, height: height?.s);
  }
}

/// Responsive Container
class RContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? borderRadius;

  const RContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.s,
      height: height?.s,
      padding: padding,
      margin: margin,
      decoration:
          decoration ??
          (color != null || borderRadius != null
              ? BoxDecoration(
                  color: color,
                  borderRadius: borderRadius != null
                      ? BorderRadius.circular(borderRadius!.r)
                      : null,
                )
              : null),
      child: child,
    );
  }
}

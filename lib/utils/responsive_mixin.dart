import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// Mixin that provides commonly used responsive widgets and styles
/// This makes it easier to apply consistent responsive design across screens
mixin ResponsiveMixin {
  /// Create responsive text style
  TextStyle responsiveTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontSize: fontSize.f,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );
  }

  /// Create responsive container
  Widget responsiveContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    Border? border,
  }) {
    return Container(
      width: width?.s,
      height: height?.s,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        border: border,
      ),
      child: child,
    );
  }

  /// Create responsive padding
  EdgeInsets responsivePadding({
    double all = 0,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (horizontal != null || vertical != null) {
      return ResponsiveUtils.pSymmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    if (left != null || top != null || right != null || bottom != null) {
      return ResponsiveUtils.pLTRB(
        left ?? 0,
        top ?? 0,
        right ?? 0,
        bottom ?? 0,
      );
    }
    return ResponsiveUtils.p(all);
  }

  /// Create responsive margin
  EdgeInsets responsiveMargin({
    double all = 0,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: (horizontal ?? 0).s,
        vertical: (vertical ?? 0).s,
      );
    }
    if (left != null || top != null || right != null || bottom != null) {
      return EdgeInsets.fromLTRB(
        (left ?? 0).s,
        (top ?? 0).s,
        (right ?? 0).s,
        (bottom ?? 0).s,
      );
    }
    return EdgeInsets.all(all.s);
  }

  /// Create responsive SizedBox
  Widget responsiveGap({double? width, double? height}) {
    return SizedBox(width: width?.s, height: height?.s);
  }

  /// Create responsive BorderRadius
  BorderRadius responsiveBorderRadius({
    double all = 0,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (topLeft != null ||
        topRight != null ||
        bottomLeft != null ||
        bottomRight != null) {
      return BorderRadius.only(
        topLeft: Radius.circular((topLeft ?? 0).r),
        topRight: Radius.circular((topRight ?? 0).r),
        bottomLeft: Radius.circular((bottomLeft ?? 0).r),
        bottomRight: Radius.circular((bottomRight ?? 0).r),
      );
    }
    return BorderRadius.circular(all.r);
  }

  /// Create responsive Icon
  Widget responsiveIcon(
    IconData iconData, {
    required double size,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return Icon(iconData, size: size.s, color: color, shadows: shadows);
  }

  /// Create responsive FaIcon (FontAwesome)
  Widget responsiveFaIcon(
    IconData iconData, {
    required double size,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return Icon(iconData, size: size.s, color: color, shadows: shadows);
  }

  /// Create responsive elevated button style
  ButtonStyle responsiveElevatedButtonStyle({
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return ElevatedButton.styleFrom(
      padding: padding,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius)
          : null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }

  /// Check if current screen size is small
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen;

  /// Check if current screen size is large
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen;

  /// Check if current screen is tall
  bool get isTallScreen => ResponsiveUtils.isTallScreen;

  /// Check if current screen is short
  bool get isShortScreen => ResponsiveUtils.isShortScreen;

  /// Get current scale factor
  double get scaleFactor => ResponsiveUtils.scaleFactor;
}

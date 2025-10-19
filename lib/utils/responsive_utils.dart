import 'package:flutter/material.dart';

/// Responsive utility class that adapts sizes based on screen dimensions
/// Optimized for mobile devices with base screen size of 412x892 (your test device)
class ResponsiveUtils {
  // Base dimensions (your perfect screen size)
  static const double _baseWidth = 412.0;
  static const double _baseHeight = 892.0;

  static late MediaQueryData _mediaQuery;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _widthScale;
  static late double _heightScale;
  static late double _scale;

  /// Initialize the responsive system with current screen context
  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;

    // Calculate scale factors
    _widthScale = _screenWidth / _baseWidth;
    _heightScale = _screenHeight / _baseHeight;

    // Use a balanced scale that considers both dimensions
    // but limits extreme scaling to prevent UI from becoming too large/small
    _scale = (_widthScale + _heightScale) / 2;

    // Clamp the scale to reasonable bounds
    _scale = _scale.clamp(0.7, 1.4);
  }

  /// Get scaled width based on design width
  static double w(double width) {
    return width * _widthScale;
  }

  /// Get scaled height based on design height
  static double h(double height) {
    return height * _heightScale;
  }

  /// Get scaled size (uses balanced scale)
  static double s(double size) {
    return size * _scale;
  }

  /// Get scaled font size
  static double f(double fontSize) {
    // Font scaling should be more conservative
    final fontScale = _scale.clamp(0.85, 1.25);
    return fontSize * fontScale;
  }

  /// Get scaled radius for border radius
  static double r(double radius) {
    return radius * _scale;
  }

  /// Get scaled padding/margin
  static EdgeInsets p(double padding) {
    return EdgeInsets.all(padding * _scale);
  }

  /// Get scaled symmetric padding
  static EdgeInsets pSymmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal * _scale,
      vertical: vertical * _scale,
    );
  }

  /// Get scaled padding with specific values
  static EdgeInsets pLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(
      left * _scale,
      top * _scale,
      right * _scale,
      bottom * _scale,
    );
  }

  /// Get scaled sized box
  static SizedBox sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width != null ? w(width) : null,
      height: height != null ? h(height) : null,
    );
  }

  /// Screen width
  static double get screenWidth => _screenWidth;

  /// Screen height
  static double get screenHeight => _screenHeight;

  /// Check if screen is small (width < 375)
  static bool get isSmallScreen => _screenWidth < 375;

  /// Check if screen is large (width > 450)
  static bool get isLargeScreen => _screenWidth > 450;

  /// Check if screen is very tall (height > 850)
  static bool get isTallScreen => _screenHeight > 850;

  /// Check if screen is short (height < 700)
  static bool get isShortScreen => _screenHeight < 700;

  /// Get scale factor for debugging
  static double get scaleFactor => _scale;
}

/// Extension methods for easier usage
extension ResponsiveInt on int {
  double get w => ResponsiveUtils.w(toDouble());
  double get h => ResponsiveUtils.h(toDouble());
  double get s => ResponsiveUtils.s(toDouble());
  double get f => ResponsiveUtils.f(toDouble());
  double get r => ResponsiveUtils.r(toDouble());
}

extension ResponsiveDouble on double {
  double get w => ResponsiveUtils.w(this);
  double get h => ResponsiveUtils.h(this);
  double get s => ResponsiveUtils.s(this);
  double get f => ResponsiveUtils.f(this);
  double get r => ResponsiveUtils.r(this);
}

/// Responsive widget that rebuilds when orientation changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return builder(context);
  }
}

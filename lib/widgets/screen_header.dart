import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

/// A standardized header for most screens in the app.
///
/// It provides a centered [title], an optional back button on the left,
/// and an optional [trailingWidget] on the right. Placeholders are used
/// to ensure the title remains centered if one side is present without the other.
class ScreenHeader extends ConsumerWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Widget? trailingWidget;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          // Leading Widget (Back button or placeholder)
          _buildLeadingWidget(context),

          // Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ),

          // Trailing Widget (Custom widget or placeholder)
          _buildTrailingWidget(),
        ],
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    if (showBackButton) {
      return PressableScaleWidget(
        onTap: onBackTap ?? () => Navigator.of(context).pop(),
        child: const GlassContainer(
          borderRadius: 12,
          child: SizedBox(
            width: 54,
            height: 54,
            child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
          ),
        ),
      );
    }
    // Return a placeholder of the same size if there's a trailing widget,
    // to keep the title centered.
    return SizedBox(width: trailingWidget == null ? 0 : 54);
  }

  Widget _buildTrailingWidget() {
    if (trailingWidget != null) {
      return trailingWidget!;
    }
    // Return a placeholder of the same size if there's a back button,
    // to keep the title centered.
    return SizedBox(width: !showBackButton ? 0 : 54);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../services/access_control_service.dart';
import '../providers/user_specific_data_provider.dart';
import '../utils/responsive_utils.dart';
import '../utils/localization.dart';
import '../data/models/inventory_item_out.dart';

/// A widget that wraps a button and provides access control functionality
/// Shows a tooltip popup when access is denied
class AccessControlledWidget extends ConsumerStatefulWidget {
  final String featureId;
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const AccessControlledWidget({
    super.key,
    required this.featureId,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  @override
  ConsumerState<AccessControlledWidget> createState() => _AccessControlledWidgetState();
}

class _AccessControlledWidgetState extends ConsumerState<AccessControlledWidget> 
    with SingleTickerProviderStateMixin {
  
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hideTooltip();
    super.dispose();
  }

  bool _hasAccess(List<InventoryItemOut> inventory) {
    return AccessControlService.hasAccess(
      widget.featureId, 
      inventory,
    );
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        position: position,
        buttonSize: size,
        message: AccessControlService.getAccessDeniedMessage(widget.featureId, ref),
        headerText: ref.t(LocalizationKeys.unlockFeature),
        animation: _fadeAnimation,
        onDismiss: _hideTooltip,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      _hideTooltip();
    });
  }

  void _hideTooltip() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;

    print('DEBUG: AccessControlledWidget tap for feature: ${widget.featureId}');
    
    // Use watch to get the current state, and refresh if needed
    final inventoryAsync = ref.watch(inventoryProvider);
    
    print('DEBUG: Inventory state: ${inventoryAsync.runtimeType}');
    
    inventoryAsync.when(
      data: (inventory) {
        print('DEBUG: Inventory loaded with ${inventory.length} items, checking access...');
        if (_hasAccess(inventory)) {
          print('DEBUG: Access granted, calling onTap');
          widget.onTap?.call();
        } else {
          print('DEBUG: Access denied, showing tooltip');
          _showTooltip();
        }
      },
      loading: () {
        print('DEBUG: Inventory loading, refreshing and showing tooltip');
        // Try to refresh the inventory provider
        Future.microtask(() {
          ref.invalidate(inventoryProvider);
        });
        _showTooltip();
      },
      error: (error, stackTrace) {
        print('DEBUG: Inventory error: $error, refreshing and showing tooltip');
        // Try to refresh the inventory provider on error
        Future.microtask(() {
          ref.invalidate(inventoryProvider);
        });
        _showTooltip();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch inventory to trigger rebuilds when it changes
    final inventoryAsync = ref.watch(inventoryProvider);
    
    // Debug the current inventory state
    print('DEBUG: AccessControlledWidget build - Inventory state: ${inventoryAsync.when(
      data: (inventory) => 'loaded with ${inventory.length} items',
      loading: () => 'loading',
      error: (error, _) => 'error: $error',
    )}');
    
    return GestureDetector(
      key: _buttonKey,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

/// The actual tooltip overlay widget
class _TooltipOverlay extends StatelessWidget {
  final Offset position;
  final Size buttonSize;
  final String message;
  final String headerText;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.position,
    required this.buttonSize,
    required this.message,
    required this.headerText,
    required this.animation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate tooltip position
    // Try to place it to the right, but if it would go off-screen, place it to the left
    final maxTooltipWidth = (screenWidth * 0.6).clamp(180.s, 250.s); // 60% of screen, min 180, max 250
    final spacing = 8.s;
    
    late double tooltipLeft;
    late bool showArrowOnLeft;
    
    if (position.dx + buttonSize.width + spacing + maxTooltipWidth <= screenWidth) {
      // Place to the right
      tooltipLeft = position.dx + buttonSize.width + spacing;
      showArrowOnLeft = true;
    } else {
      // Place to the left
      tooltipLeft = (position.dx - maxTooltipWidth - spacing).clamp(spacing, screenWidth - maxTooltipWidth - spacing);
      showArrowOnLeft = false;
    }
    
    final tooltipTop = position.dy + (buttonSize.height / 2) - 40.s;

    return Positioned(
      left: tooltipLeft,
      top: tooltipTop,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * animation.value),
                child: _TooltipContent(
                  message: message,
                  headerText: headerText,
                  showArrowOnLeft: showArrowOnLeft,
                  maxWidth: maxTooltipWidth,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The styled content of the tooltip
class _TooltipContent extends StatelessWidget {
  final String message;
  final String headerText;
  final bool showArrowOnLeft;
  final double maxWidth;

  const _TooltipContent({
    required this.message,
    required this.headerText,
    required this.showArrowOnLeft,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: 150.s,
      ),
      child: IntrinsicWidth(
        child: Stack(
        children: [
          // Arrow pointing to the button
          if (showArrowOnLeft)
            Positioned(
              left: -8.s,
              top: 35.s,
              child: CustomPaint(
                painter: _ArrowPainter(pointsLeft: true),
                size: Size(8.s, 16.s),
              ),
            ),
          if (!showArrowOnLeft)
            Positioned(
              right: -8.s,
              top: 35.s,
              child: CustomPaint(
                painter: _ArrowPainter(pointsLeft: false),
                size: Size(8.s, 16.s),
              ),
            ),
          // Main tooltip content
          GlassContainer(
            borderRadius: 12,
            padding: ResponsiveUtils.p(16),
            border: Border.all(
              color: AppColors.angolaYellow.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.glowYellow.withValues(alpha: 0.2),
                blurRadius: 12.s,
                spreadRadius: 1.s,
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.s),
                      decoration: BoxDecoration(
                        color: AppColors.angolaYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.key,
                        size: 12.s,
                        color: AppColors.angolaYellow,
                      ),
                    ),
                    SizedBox(width: 8.s),
                    Flexible(
                      child: Text(
                        headerText,
                        style: TextStyle(
                          color: AppColors.angolaYellow,
                          fontSize: 13.f,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.s),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11.f,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Custom painter for the tooltip arrow
class _ArrowPainter extends CustomPainter {
  final bool pointsLeft;
  
  const _ArrowPainter({this.pointsLeft = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassBg
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.angolaYellow.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    
    if (pointsLeft) {
      // Arrow pointing left (tooltip is to the right of button)
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Arrow pointing right (tooltip is to the left of button)
      path.moveTo(size.width, size.height / 2);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
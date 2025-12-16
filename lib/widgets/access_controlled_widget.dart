import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/info_popup.dart';
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

class _AccessControlledWidgetState extends ConsumerState<AccessControlledWidget> {
  
  @override
  void dispose() {
    super.dispose();
  }

  bool _hasAccess(List<InventoryItemOut> inventory) {
    return AccessControlService.hasAccess(
      widget.featureId, 
      inventory,
    );
  }

  void _showInfoPopup() {
    InfoPopup.show(
      context: context,
      title: ref.t(LocalizationKeys.unlockFeature),
      description: AccessControlService.getAccessDeniedMessage(widget.featureId, ref),
    );
  }

  void _handleTap() {
    if (!widget.enabled) return;

    // Use watch to get the current state, and refresh if needed
    final inventoryAsync = ref.watch(inventoryProvider);
    
    inventoryAsync.when(
      data: (inventory) {
        if (_hasAccess(inventory)) {
          widget.onTap?.call();
        } else {
          _showInfoPopup();
        }
      },
      loading: () {
        // Try to refresh the inventory provider
        Future.microtask(() {
          ref.invalidate(inventoryProvider);
        });
        _showInfoPopup();
      },
      error: (error, stackTrace) {
        // Try to refresh the inventory provider on error
        Future.microtask(() {
          ref.invalidate(inventoryProvider);
        });
        _showInfoPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch inventory to trigger rebuilds when it changes
    final inventoryAsync = ref.watch(inventoryProvider);
    
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
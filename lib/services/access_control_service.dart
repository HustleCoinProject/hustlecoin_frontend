import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/inventory_item_out.dart';
import '../utils/localization.dart';

/// Represents different types of access requirements
abstract class AccessRequirement {
  String get requirementId;
  String get displayName;
  String get description;
  bool checkRequirement(List<InventoryItemOut> inventory);
}

/// Requirement for having an active item in inventory
class ActiveItemRequirement extends AccessRequirement {
  final String itemId;
  final String itemNameKey;
  final String purchaseLocationKey;

  ActiveItemRequirement({
    required this.itemId,
    required this.itemNameKey,
    required this.purchaseLocationKey,
  });

  @override
  String get requirementId => 'active_item_$itemId';

  @override
  String get displayName => itemNameKey;

  @override
  String get description => 'Localized message - use getAccessDeniedMessage with WidgetRef';

  @override
  bool checkRequirement(List<InventoryItemOut> inventory) {
    // Debug: Print all inventory items
    print('DEBUG: Checking inventory for itemId: $itemId');
    print('DEBUG: Inventory items:');
    for (final item in inventory) {
      print('  - itemId: ${item.itemId}, quantity: ${item.quantity}, expiresAt: ${item.expiresAt}');
    }
    
    // Check if user has the item and it's not expired
    try {
      final item = inventory.where((item) => item.itemId == itemId).first;
      print('DEBUG: Found matching item: ${item.itemId}, quantity: ${item.quantity}');
      
      if (item.quantity <= 0) {
        print('DEBUG: Item quantity is 0 or negative');
        return false;
      }
      
      // If item has expiration, check if it's still valid
      if (item.expiresAt != null) {
        final isValid = DateTime.now().isBefore(item.expiresAt!);
        print('DEBUG: Item expires at ${item.expiresAt}, valid: $isValid');
        return isValid;
      }
      
      print('DEBUG: Item has no expiration, access granted');
      return true;
    } catch (e) {
      // Item not found
      print('DEBUG: Item not found in inventory: $e');
      return false;
    }
  }
}

/// Service to check access requirements for various features
/// 
/// Usage:
/// 1. Add new requirements to _featureRequirements map
/// 2. Wrap your feature widgets with AccessControlledWidget
/// 3. The system handles checking inventory and showing tooltips automatically
/// 
/// Example for future features:
/// ```dart
/// 'premium_shop': ActiveItemRequirement(
///   itemId: 'gold_key',
///   itemName: 'Gold Key', 
///   purchaseLocation: 'shop',
/// ),
/// 'special_events': ActiveItemRequirement(
///   itemId: 'event_pass',
///   itemName: 'Event Pass',
///   purchaseLocation: 'events shop',
/// ),
/// ```
class AccessControlService {
  static final Map<String, AccessRequirement> _featureRequirements = {
    'land_page': ActiveItemRequirement(
      itemId: 'bronze_key', // If this is wrong, check debug logs and update
      itemNameKey: LocalizationKeys.bronzeKey,
      purchaseLocationKey: LocalizationKeys.shop,
    ),
    
    // Example for future features (commented out):
    // 'premium_features': ActiveItemRequirement(
    //   itemId: 'silver_key',
    //   itemNameKey: 'silver_key_localization_key',
    //   purchaseLocationKey: LocalizationKeys.shop,
    // ),
  };

  /// Check if user has access to a specific feature
  static bool hasAccess(String featureId, List<InventoryItemOut> inventory) {
    print('DEBUG: Checking access for featureId: $featureId');
    final requirement = _featureRequirements[featureId];
    if (requirement == null) {
      print('DEBUG: No requirement found for $featureId, granting access');
      return true; // No requirement means access is granted
    }
    
    final hasAccess = requirement.checkRequirement(inventory);
    print('DEBUG: Access check result for $featureId: $hasAccess');
    return hasAccess;
  }

  /// Get the access requirement for a feature
  static AccessRequirement? getRequirement(String featureId) {
    return _featureRequirements[featureId];
  }

  /// Get a user-friendly message for missing access
  static String getAccessDeniedMessage(String featureId, WidgetRef ref) {
    final requirement = _featureRequirements[featureId];
    if (requirement == null) return 'Feature locked';
    
    if (requirement is ActiveItemRequirement) {
      final itemName = ref.t(requirement.itemNameKey);
      final shopLocation = ref.t(requirement.purchaseLocationKey);
      final message = ref.t(LocalizationKeys.getBronzeKeyMessage)
          .replaceAll('Bronze Key', itemName)
          .replaceAll('shop', shopLocation);
      final expireMessage = ref.t(LocalizationKeys.keysExpireMessage);
      return '$message $expireMessage';
    }
    
    return requirement.description;
  }

  /// Add new requirements dynamically (for future extensibility)
  static void addRequirement(String featureId, AccessRequirement requirement) {
    // In a real implementation, you might want to store this in a more persistent way
    // For now, this would need to be done through code changes
    throw UnimplementedError('Dynamic requirement addition not implemented yet');
  }
}
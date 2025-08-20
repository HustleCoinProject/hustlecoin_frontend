/// Utility functions for handling hustle key-value pairs
///
/// After the backend update, hustles are returned as key-value objects where:
/// - Key: English hustle name (used for internal purposes, file names, database storage)
/// - Value: Localized hustle name (displayed to users)

class HustleUtils {
  /// Extracts the hustle key (English name) from a hustle object
  /// Used for file names, API calls, and database operations
  static String getHustleKey(Map<String, String> hustleObj) {
    return hustleObj.keys.first;
  }

  /// Extracts the hustle display name (localized) from a hustle object
  /// Used for displaying to users in the UI
  static String getHustleDisplayName(Map<String, String> hustleObj) {
    return hustleObj.values.first;
  }

  /// Converts a string hustle name to a hustle object format
  /// Used for backward compatibility when sending data to server
  static Map<String, String> createHustleObject(String hustleName) {
    return {hustleName: hustleName};
  }

  /// Converts old format hustle arrays to new format hustle objects
  /// Used for migration from old API responses
  static Map<String, String> convertArrayToObject(List<String> hustleArray) {
    Map<String, String> result = {};
    for (String hustle in hustleArray) {
      result[hustle] = hustle;
    }
    return result;
  }

  /// Gets the image path for a hustle using the key (English name)
  static String getHustleImagePath(Map<String, String> hustleObj) {
    final key = getHustleKey(hustleObj);
    return 'assets/images/$key.png';
  }

  /// Gets the image path for a hustle using string hustle name
  static String getHustleImagePathFromString(String hustleName) {
    return 'assets/images/$hustleName.png';
  }

  /// Safely handles both old string format and new object format for current_hustle
  /// Returns the display name for UI
  static String getCurrentHustleDisplayName(dynamic currentHustle) {
    if (currentHustle is String) {
      // Old format - return as is
      return currentHustle;
    } else if (currentHustle is Map<String, dynamic>) {
      // New format - extract display name
      final hustleObj = Map<String, String>.from(currentHustle);
      return getHustleDisplayName(hustleObj);
    } else {
      // Fallback
      return 'Unknown Hustle';
    }
  }

  /// Safely handles both old string format and new object format for current_hustle
  /// Returns the key for internal operations
  static String getCurrentHustleKey(dynamic currentHustle) {
    if (currentHustle is String) {
      // Old format - return as is (assuming it's the key)
      return currentHustle;
    } else if (currentHustle is Map<String, dynamic>) {
      // New format - extract key
      final hustleObj = Map<String, String>.from(currentHustle);
      return getHustleKey(hustleObj);
    } else {
      // Fallback
      return 'Taxi Driver'; // Default hustle
    }
  }

  /// Gets the image path for current hustle, handling both formats
  static String getCurrentHustleImagePath(dynamic currentHustle) {
    final key = getCurrentHustleKey(currentHustle);
    return getHustleImagePathFromString(key);
  }
}

import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  final String username;
  final int rankPoints;
  final int level;
  final int hcBalance; // Still included for reference
  final String currentHustle;

  const LeaderboardEntry({
    required this.username,
    required this.rankPoints,
    required this.level,
    required this.hcBalance,
    required this.currentHustle,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    // Import HustleUtils if not already available, or handle dynamic extraction here.
    // Since we can't easily add imports in this chunk without seeing the whole file imports,
    // I will write a simple helper or assume HustleUtils is imported?
    // Wait, the file doesn't have HustleUtils imported. I should check imports first or add it.
    // Actually, I can just handle the dynamic logic inline to be safe and avoid circular deps if any (though utils is usually safe).
    // Or better, I will use a separate tool call to add the import first if needed.
    // Let's look at the file content again. It only imports 'package:flutter/foundation.dart'.
    // I will add the import in a separate tool call or use multi_replace.
    // For now, let's just do the field logic assuming I'll fix imports.
    // Actually, I'll allow myself to use multi_replace to add the import and the field at once.
    return LeaderboardEntry(
      username: json['username'],
      rankPoints: json['rank_points'] ?? 0,
      level: json['level'] ?? 0,
      hcBalance: json['hc_balance'] ?? 0,
      currentHustle: _parseCurrentHustle(json['current_hustle']),
    );
  }

  static String _parseCurrentHustle(dynamic currentHustle) {
    if (currentHustle is String) {
      return currentHustle;
    } else if (currentHustle is Map) {
      // Assuming value is the display name, like HustleUtils.getHustleDisplayName
      if (currentHustle.values.isNotEmpty) {
        return currentHustle.values.first.toString();
      }
    }
    return 'Taxi Driver'; // Default fallback
  }
}

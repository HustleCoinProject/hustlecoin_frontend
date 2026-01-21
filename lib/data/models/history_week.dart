import 'package:intl/intl.dart';

class HistoryWeek {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int entryCount;

  HistoryWeek({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.entryCount,
  });

  factory HistoryWeek.fromJson(Map<String, dynamic> json) {
    return HistoryWeek(
      id: json['id'],
      weekStart: DateTime.parse(json['week_start']),
      weekEnd: DateTime.parse(json['week_end']),
      entryCount: json['entry_count'],
    );
  }

  String get displayName {
    final startFormat = DateFormat('MMM d');
    final endFormat = DateFormat('MMM d');
    return "${startFormat.format(weekStart)} - ${endFormat.format(weekEnd)}";
  }
}

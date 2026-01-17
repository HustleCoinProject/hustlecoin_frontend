import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    @JsonKey(name: 'event_id') required String eventId,
    required String name,
    required String description,
    @JsonKey(name: 'duration_days') required int durationDays,
    @JsonKey(name: 'entry_fee') required int entryFee,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'participants_count') required int participantsCount,
    @JsonKey(name: 'is_joined') required bool isJoined,
    @JsonKey(name: 'current_rank_points') required int currentRankPoints,
    @JsonKey(name: 'rewards_info') required Map<String, int> rewardsInfo,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
class EventLeaderboardEntry with _$EventLeaderboardEntry {
  const factory EventLeaderboardEntry({
    required String username,
    @JsonKey(name: 'rank_points') required int rankPoints,
    required int level,
    @JsonKey(name: 'current_hustle') required String currentHustle,
  }) = _EventLeaderboardEntry;

  factory EventLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$EventLeaderboardEntryFromJson(json);
}

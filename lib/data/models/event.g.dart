// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
  eventId: json['event_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  durationDays: (json['duration_days'] as num).toInt(),
  entryFee: (json['entry_fee'] as num).toInt(),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  participantsCount: (json['participants_count'] as num).toInt(),
  isJoined: json['is_joined'] as bool,
  currentRankPoints: (json['current_rank_points'] as num).toInt(),
  rewardsInfo: Map<String, int>.from(json['rewards_info'] as Map),
);

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'name': instance.name,
      'description': instance.description,
      'duration_days': instance.durationDays,
      'entry_fee': instance.entryFee,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'participants_count': instance.participantsCount,
      'is_joined': instance.isJoined,
      'current_rank_points': instance.currentRankPoints,
      'rewards_info': instance.rewardsInfo,
    };

_$EventLeaderboardEntryImpl _$$EventLeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$EventLeaderboardEntryImpl(
  username: json['username'] as String,
  rankPoints: (json['rank_points'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  currentHustle: json['current_hustle'] as String,
);

Map<String, dynamic> _$$EventLeaderboardEntryImplToJson(
  _$EventLeaderboardEntryImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'rank_points': instance.rankPoints,
  'level': instance.level,
  'current_hustle': instance.currentHustle,
};

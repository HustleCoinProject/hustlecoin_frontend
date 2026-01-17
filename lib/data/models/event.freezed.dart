// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_fee')
  int get entryFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'participants_count')
  int get participantsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_joined')
  bool get isJoined => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_rank_points')
  int get currentRankPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'rewards_info')
  Map<String, int> get rewardsInfo => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    String name,
    String description,
    @JsonKey(name: 'duration_days') int durationDays,
    @JsonKey(name: 'entry_fee') int entryFee,
    @JsonKey(name: 'start_time') DateTime startTime,
    @JsonKey(name: 'end_time') DateTime endTime,
    @JsonKey(name: 'participants_count') int participantsCount,
    @JsonKey(name: 'is_joined') bool isJoined,
    @JsonKey(name: 'current_rank_points') int currentRankPoints,
    @JsonKey(name: 'rewards_info') Map<String, int> rewardsInfo,
  });
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? name = null,
    Object? description = null,
    Object? durationDays = null,
    Object? entryFee = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? participantsCount = null,
    Object? isJoined = null,
    Object? currentRankPoints = null,
    Object? rewardsInfo = null,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            durationDays: null == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int,
            entryFee: null == entryFee
                ? _value.entryFee
                : entryFee // ignore: cast_nullable_to_non_nullable
                      as int,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            participantsCount: null == participantsCount
                ? _value.participantsCount
                : participantsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isJoined: null == isJoined
                ? _value.isJoined
                : isJoined // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentRankPoints: null == currentRankPoints
                ? _value.currentRankPoints
                : currentRankPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            rewardsInfo: null == rewardsInfo
                ? _value.rewardsInfo
                : rewardsInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
    _$EventImpl value,
    $Res Function(_$EventImpl) then,
  ) = __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    String name,
    String description,
    @JsonKey(name: 'duration_days') int durationDays,
    @JsonKey(name: 'entry_fee') int entryFee,
    @JsonKey(name: 'start_time') DateTime startTime,
    @JsonKey(name: 'end_time') DateTime endTime,
    @JsonKey(name: 'participants_count') int participantsCount,
    @JsonKey(name: 'is_joined') bool isJoined,
    @JsonKey(name: 'current_rank_points') int currentRankPoints,
    @JsonKey(name: 'rewards_info') Map<String, int> rewardsInfo,
  });
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
    _$EventImpl _value,
    $Res Function(_$EventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? name = null,
    Object? description = null,
    Object? durationDays = null,
    Object? entryFee = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? participantsCount = null,
    Object? isJoined = null,
    Object? currentRankPoints = null,
    Object? rewardsInfo = null,
  }) {
    return _then(
      _$EventImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        durationDays: null == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int,
        entryFee: null == entryFee
            ? _value.entryFee
            : entryFee // ignore: cast_nullable_to_non_nullable
                  as int,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        participantsCount: null == participantsCount
            ? _value.participantsCount
            : participantsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isJoined: null == isJoined
            ? _value.isJoined
            : isJoined // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentRankPoints: null == currentRankPoints
            ? _value.currentRankPoints
            : currentRankPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        rewardsInfo: null == rewardsInfo
            ? _value._rewardsInfo
            : rewardsInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.name,
    required this.description,
    @JsonKey(name: 'duration_days') required this.durationDays,
    @JsonKey(name: 'entry_fee') required this.entryFee,
    @JsonKey(name: 'start_time') required this.startTime,
    @JsonKey(name: 'end_time') required this.endTime,
    @JsonKey(name: 'participants_count') required this.participantsCount,
    @JsonKey(name: 'is_joined') required this.isJoined,
    @JsonKey(name: 'current_rank_points') required this.currentRankPoints,
    @JsonKey(name: 'rewards_info') required final Map<String, int> rewardsInfo,
  }) : _rewardsInfo = rewardsInfo;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'duration_days')
  final int durationDays;
  @override
  @JsonKey(name: 'entry_fee')
  final int entryFee;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @override
  @JsonKey(name: 'participants_count')
  final int participantsCount;
  @override
  @JsonKey(name: 'is_joined')
  final bool isJoined;
  @override
  @JsonKey(name: 'current_rank_points')
  final int currentRankPoints;
  final Map<String, int> _rewardsInfo;
  @override
  @JsonKey(name: 'rewards_info')
  Map<String, int> get rewardsInfo {
    if (_rewardsInfo is EqualUnmodifiableMapView) return _rewardsInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rewardsInfo);
  }

  @override
  String toString() {
    return 'Event(eventId: $eventId, name: $name, description: $description, durationDays: $durationDays, entryFee: $entryFee, startTime: $startTime, endTime: $endTime, participantsCount: $participantsCount, isJoined: $isJoined, currentRankPoints: $currentRankPoints, rewardsInfo: $rewardsInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.entryFee, entryFee) ||
                other.entryFee == entryFee) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.participantsCount, participantsCount) ||
                other.participantsCount == participantsCount) &&
            (identical(other.isJoined, isJoined) ||
                other.isJoined == isJoined) &&
            (identical(other.currentRankPoints, currentRankPoints) ||
                other.currentRankPoints == currentRankPoints) &&
            const DeepCollectionEquality().equals(
              other._rewardsInfo,
              _rewardsInfo,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    name,
    description,
    durationDays,
    entryFee,
    startTime,
    endTime,
    participantsCount,
    isJoined,
    currentRankPoints,
    const DeepCollectionEquality().hash(_rewardsInfo),
  );

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(this);
  }
}

abstract class _Event implements Event {
  const factory _Event({
    @JsonKey(name: 'event_id') required final String eventId,
    required final String name,
    required final String description,
    @JsonKey(name: 'duration_days') required final int durationDays,
    @JsonKey(name: 'entry_fee') required final int entryFee,
    @JsonKey(name: 'start_time') required final DateTime startTime,
    @JsonKey(name: 'end_time') required final DateTime endTime,
    @JsonKey(name: 'participants_count') required final int participantsCount,
    @JsonKey(name: 'is_joined') required final bool isJoined,
    @JsonKey(name: 'current_rank_points') required final int currentRankPoints,
    @JsonKey(name: 'rewards_info') required final Map<String, int> rewardsInfo,
  }) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'duration_days')
  int get durationDays;
  @override
  @JsonKey(name: 'entry_fee')
  int get entryFee;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'end_time')
  DateTime get endTime;
  @override
  @JsonKey(name: 'participants_count')
  int get participantsCount;
  @override
  @JsonKey(name: 'is_joined')
  bool get isJoined;
  @override
  @JsonKey(name: 'current_rank_points')
  int get currentRankPoints;
  @override
  @JsonKey(name: 'rewards_info')
  Map<String, int> get rewardsInfo;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventLeaderboardEntry _$EventLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) {
  return _EventLeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$EventLeaderboardEntry {
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'rank_points')
  int get rankPoints => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_hustle')
  String get currentHustle => throw _privateConstructorUsedError;

  /// Serializes this EventLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventLeaderboardEntryCopyWith<EventLeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventLeaderboardEntryCopyWith<$Res> {
  factory $EventLeaderboardEntryCopyWith(
    EventLeaderboardEntry value,
    $Res Function(EventLeaderboardEntry) then,
  ) = _$EventLeaderboardEntryCopyWithImpl<$Res, EventLeaderboardEntry>;
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'rank_points') int rankPoints,
    int level,
    @JsonKey(name: 'current_hustle') String currentHustle,
  });
}

/// @nodoc
class _$EventLeaderboardEntryCopyWithImpl<
  $Res,
  $Val extends EventLeaderboardEntry
>
    implements $EventLeaderboardEntryCopyWith<$Res> {
  _$EventLeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? rankPoints = null,
    Object? level = null,
    Object? currentHustle = null,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            rankPoints: null == rankPoints
                ? _value.rankPoints
                : rankPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            currentHustle: null == currentHustle
                ? _value.currentHustle
                : currentHustle // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventLeaderboardEntryImplCopyWith<$Res>
    implements $EventLeaderboardEntryCopyWith<$Res> {
  factory _$$EventLeaderboardEntryImplCopyWith(
    _$EventLeaderboardEntryImpl value,
    $Res Function(_$EventLeaderboardEntryImpl) then,
  ) = __$$EventLeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'rank_points') int rankPoints,
    int level,
    @JsonKey(name: 'current_hustle') String currentHustle,
  });
}

/// @nodoc
class __$$EventLeaderboardEntryImplCopyWithImpl<$Res>
    extends
        _$EventLeaderboardEntryCopyWithImpl<$Res, _$EventLeaderboardEntryImpl>
    implements _$$EventLeaderboardEntryImplCopyWith<$Res> {
  __$$EventLeaderboardEntryImplCopyWithImpl(
    _$EventLeaderboardEntryImpl _value,
    $Res Function(_$EventLeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? rankPoints = null,
    Object? level = null,
    Object? currentHustle = null,
  }) {
    return _then(
      _$EventLeaderboardEntryImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        rankPoints: null == rankPoints
            ? _value.rankPoints
            : rankPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        currentHustle: null == currentHustle
            ? _value.currentHustle
            : currentHustle // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventLeaderboardEntryImpl implements _EventLeaderboardEntry {
  const _$EventLeaderboardEntryImpl({
    required this.username,
    @JsonKey(name: 'rank_points') required this.rankPoints,
    required this.level,
    @JsonKey(name: 'current_hustle') required this.currentHustle,
  });

  factory _$EventLeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventLeaderboardEntryImplFromJson(json);

  @override
  final String username;
  @override
  @JsonKey(name: 'rank_points')
  final int rankPoints;
  @override
  final int level;
  @override
  @JsonKey(name: 'current_hustle')
  final String currentHustle;

  @override
  String toString() {
    return 'EventLeaderboardEntry(username: $username, rankPoints: $rankPoints, level: $level, currentHustle: $currentHustle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventLeaderboardEntryImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.rankPoints, rankPoints) ||
                other.rankPoints == rankPoints) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.currentHustle, currentHustle) ||
                other.currentHustle == currentHustle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, username, rankPoints, level, currentHustle);

  /// Create a copy of EventLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventLeaderboardEntryImplCopyWith<_$EventLeaderboardEntryImpl>
  get copyWith =>
      __$$EventLeaderboardEntryImplCopyWithImpl<_$EventLeaderboardEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventLeaderboardEntryImplToJson(this);
  }
}

abstract class _EventLeaderboardEntry implements EventLeaderboardEntry {
  const factory _EventLeaderboardEntry({
    required final String username,
    @JsonKey(name: 'rank_points') required final int rankPoints,
    required final int level,
    @JsonKey(name: 'current_hustle') required final String currentHustle,
  }) = _$EventLeaderboardEntryImpl;

  factory _EventLeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$EventLeaderboardEntryImpl.fromJson;

  @override
  String get username;
  @override
  @JsonKey(name: 'rank_points')
  int get rankPoints;
  @override
  int get level;
  @override
  @JsonKey(name: 'current_hustle')
  String get currentHustle;

  /// Create a copy of EventLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventLeaderboardEntryImplCopyWith<_$EventLeaderboardEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

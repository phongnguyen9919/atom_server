import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/record.g.dart';

@immutable
@JsonSerializable()
class Record extends Equatable {
  const Record({
    required this.id,
    required this.deviceId,
    required this.time,
    required this.value,
  });

  final FieldId id;

  @JsonKey(name: 'device_id')
  final FieldId deviceId;

  final DateTime time;
  final String value;

  /// Deserializes the given [JsonMap] into a [Record].
  static Record fromJson(JsonMap json) {
    return _$RecordFromJson(json);
  }

  /// Converts this [Record] into a [JsonMap].
  JsonMap toJson() => _$RecordToJson(this);

  /// Returns a copy of [Record] with given parameters
  Record copyWith({
    FieldId? id,
    FieldId? deviceId,
    DateTime? time,
    String? value,
  }) {
    return Record(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      time: time ?? this.time,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, deviceId, time, value];
}

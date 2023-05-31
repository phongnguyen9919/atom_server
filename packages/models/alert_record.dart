import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/alert_record.g.dart';

@immutable
@JsonSerializable()
class AlertRecord extends Equatable {
  const AlertRecord({
    required this.id,
    required this.alertId,
    required this.time,
    required this.value,
  });

  final FieldId id;

  @JsonKey(name: 'alert_id')
  final FieldId alertId;

  final DateTime time;
  final String value;

  /// Deserializes the given [JsonMap] into a [AlertRecord].
  static AlertRecord fromJson(JsonMap json) {
    return _$AlertRecordFromJson(json);
  }

  /// Converts this [AlertRecord] into a [JsonMap].
  JsonMap toJson() => _$AlertRecordToJson(this);

  /// Returns a copy of [AlertRecord] with given parameters
  AlertRecord copyWith({
    FieldId? id,
    FieldId? alertId,
    DateTime? time,
    String? value,
  }) {
    return AlertRecord(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      time: time ?? this.time,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, alertId, time, value];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/device.g.dart';

@immutable
@JsonSerializable()

/// Device model for an API providing to access device
class Device extends Equatable {
  /// {macro Device}
  const Device({
    required this.id,
    required this.groupID,
    required this.brokerID,
    required this.name,
    required this.topic,
    required this.qos,
    required this.jsonPath,
    required this.unit,
  });

  /// The ID
  final FieldId id;

  @JsonKey(name: 'group_id')
  final FieldId? groupID;

  @JsonKey(name: 'broker_id')
  final FieldId brokerID;

  final String name;

  final String topic;

  final int qos;

  @JsonKey(name: 'json_path')
  final String jsonPath;

  final String? unit;

  /// Deserializes the given [JsonMap] into a [Device].
  static Device fromJson(JsonMap json) {
    return _$DeviceFromJson(json);
  }

  /// Converts this [Device] into a [JsonMap].
  JsonMap toJson() => _$DeviceToJson(this);

  /// Returns a copy of [Device] with given parameters
  Device copyWith({
    FieldId? id,
    FieldId? groupID,
    FieldId? brokerID,
    String? name,
    String? topic,
    int? qos,
    String? jsonPath,
    String? unit,
  }) {
    return Device(
      id: id ?? this.id,
      groupID: groupID ?? this.groupID,
      brokerID: brokerID ?? this.brokerID,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      qos: qos ?? this.qos,
      jsonPath: jsonPath ?? this.jsonPath,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props =>
      [id, groupID, brokerID, name, topic, qos, jsonPath, unit];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/alert.g.dart';

@immutable
@JsonSerializable()
class Alert extends Equatable {
  const Alert({
    required this.id,
    required this.deviceID,
    required this.name,
    required this.relate,
    required this.lvalue,
    required this.rvalue,
  });

  final FieldId id;

  @JsonKey(name: 'device_id')
  final FieldId deviceID;

  final String name;
  final bool relate;
  final String lvalue;
  final String rvalue;

  /// Deserializes the given [JsonMap] into a [Alert].
  static Alert fromJson(JsonMap json) {
    return _$AlertFromJson(json);
  }

  /// Converts this [Alert] into a [JsonMap].
  JsonMap toJson() => _$AlertToJson(this);

  /// Returns a copy of [Alert] with given parameters
  Alert copyWith({
    FieldId? id,
    FieldId? deviceID,
    String? name,
    bool? relate,
    String? lvalue,
    String? rvalue,
  }) {
    return Alert(
      id: id ?? this.id,
      deviceID: deviceID ?? this.deviceID,
      name: name ?? this.name,
      relate: relate ?? this.relate,
      lvalue: lvalue ?? this.lvalue,
      rvalue: rvalue ?? this.rvalue,
    );
  }

  @override
  List<Object?> get props => [id, deviceID, name, relate, lvalue, rvalue];
}

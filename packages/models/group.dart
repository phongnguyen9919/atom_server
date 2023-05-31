import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/group.g.dart';

@immutable
@JsonSerializable()
class Group extends Equatable {
  const Group({
    required this.id,
    required this.groupID,
    required this.name,
  });

  /// The group ID
  final FieldId id;

  /// The parent group ID
  @JsonKey(name: 'group_id')
  final FieldId? groupID;

  final String name;

  /// Deserializes the given [JsonMap] into a [Group].
  static Group fromJson(JsonMap json) {
    return _$GroupFromJson(json);
  }

  /// Converts this [Group] into a [JsonMap].
  JsonMap toJson() => _$GroupToJson(this);

  /// Returns a copy of [Group] with given parameters
  Group copyWith({
    FieldId? id,
    FieldId? groupID,
    String? name,
  }) {
    return Group(
      id: id ?? this.id,
      groupID: groupID ?? this.groupID,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, groupID, name];
}

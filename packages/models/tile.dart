import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'tile_type.dart';
import 'typedef.dart';

part 'generated/tile.g.dart';

@immutable
@JsonSerializable()

/// Tile model for an API providing to access tile
class Tile extends Equatable {
  /// {macro Tile}
  const Tile({
    required this.id,
    required this.dashboardId,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.lob,
  });

  final FieldId id;

  @JsonKey(name: 'dashboard_id')
  final FieldId dashboardId;

  @JsonKey(name: 'device_id')
  final FieldId deviceId;

  final String name;

  final TileType type;

  final String lob;

  /// Deserializes the given [JsonMap] into a [Tile].
  static Tile fromJson(JsonMap json) {
    return _$TileFromJson(json);
  }

  /// Converts this [Tile] into a [JsonMap].
  JsonMap toJson() => _$TileToJson(this);

  /// Returns a copy of [Tile] with given parameters
  Tile copyWith({
    FieldId? id,
    FieldId? dashboardId,
    FieldId? deviceId,
    String? name,
    TileType? type,
    String? lob,
  }) {
    return Tile(
      id: id ?? this.id,
      dashboardId: dashboardId ?? this.dashboardId,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      lob: lob ?? this.lob,
    );
  }

  @override
  List<Object?> get props => [id, dashboardId, deviceId, name, type, lob];
}

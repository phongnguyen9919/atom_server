// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tile _$TileFromJson(Map<String, dynamic> json) => Tile(
      id: json['id'] as String,
      dashboardId: json['dashboard_id'] as String,
      deviceId: json['device_id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TileTypeEnumMap, json['type']),
      lob: json['lob'] as String,
    );

Map<String, dynamic> _$TileToJson(Tile instance) => <String, dynamic>{
      'id': instance.id,
      'dashboard_id': instance.dashboardId,
      'device_id': instance.deviceId,
      'name': instance.name,
      'type': _$TileTypeEnumMap[instance.type],
      'lob': instance.lob,
    };

const _$TileTypeEnumMap = {
  TileType.text: 'Text',
  TileType.toggle: 'Switch',
  TileType.button: 'Button',
  TileType.line: 'Line',
};

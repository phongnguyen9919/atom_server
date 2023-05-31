// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      time: DateTime.parse(json['time'] as String),
      value: json['value'] as String,
    );

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'time': instance.time.toIso8601String(),
      'value': instance.value,
    };

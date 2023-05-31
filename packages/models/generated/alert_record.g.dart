// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../alert_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertRecord _$AlertRecordFromJson(Map<String, dynamic> json) => AlertRecord(
      id: json['id'] as String,
      alertId: json['alert_id'] as String,
      time: DateTime.parse(json['time'] as String),
      value: json['value'] as String,
    );

Map<String, dynamic> _$AlertRecordToJson(AlertRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alert_id': instance.alertId,
      'time': instance.time.toIso8601String(),
      'value': instance.value,
    };

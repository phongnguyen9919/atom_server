// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      id: json['id'] as String,
      groupID: json['group_id'] as String?,
      brokerID: json['broker_id'] as String,
      name: json['name'] as String,
      topic: json['topic'] as String,
      qos: json['qos'] as int,
      jsonPath: json['json_path'] as String,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupID,
      'broker_id': instance.brokerID,
      'name': instance.name,
      'topic': instance.topic,
      'qos': instance.qos,
      'json_path': instance.jsonPath,
      'unit': instance.unit,
    };

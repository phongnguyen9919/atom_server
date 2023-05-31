// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
      id: json['id'] as String,
      deviceID: json['device_id'] as String,
      name: json['name'] as String,
      relate: json['relate'] as bool,
      lvalue: json['lvalue'] as String,
      rvalue: json['rvalue'] as String,
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceID,
      'name': instance.name,
      'relate': instance.relate,
      'lvalue': instance.lvalue,
      'rvalue': instance.rvalue,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      id: json['id'] as String,
      groupID: json['group_id'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupID,
      'name': instance.name,
    };

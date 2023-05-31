// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../broker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Broker _$BrokerFromJson(Map<String, dynamic> json) => Broker(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      port: json['port'] as int,
      account: json['account'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$BrokerToJson(Broker instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'port': instance.port,
      'account': instance.account,
      'password': instance.url,
    };

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/broker.g.dart';

@immutable
@JsonSerializable()
class Broker extends Equatable {
  const Broker({
    required this.id,
    required this.name,
    required this.url,
    required this.port,
    required this.account,
    required this.password,
  });

  final FieldId id;

  final String name;

  final String url;

  final int port;

  final String? account;

  final String? password;

  /// Deserializes the given [JsonMap] into a [Broker].
  static Broker fromJson(JsonMap json) {
    return _$BrokerFromJson(json);
  }

  /// Converts this [Broker] into a [JsonMap].
  JsonMap toJson() => _$BrokerToJson(this);

  /// Returns a copy of [Broker] with given parameters
  Broker copyWith({
    FieldId? id,
    String? name,
    String? url,
    int? port,
    String? account,
    String? password,
  }) {
    return Broker(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      port: port ?? this.port,
      account: account ?? this.account,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [id, name, url, port, account, password];
}

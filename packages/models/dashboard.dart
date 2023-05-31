import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/dashboard.g.dart';

@immutable
@JsonSerializable()

/// Dashboard model for an API providing to access dashboard
class Dashboard extends Equatable {
  /// {macro Dashboard}
  const Dashboard({
    required this.id,
    required this.name,
  });

  final FieldId id;

  final String name;

  /// Deserializes the given [JsonMap] into a [Dashboard].
  static Dashboard fromJson(JsonMap json) {
    return _$DashboardFromJson(json);
  }

  /// Converts this [Dashboard] into a [JsonMap].
  JsonMap toJson() => _$DashboardToJson(this);

  /// Returns a copy of [Dashboard] with given parameters
  Dashboard copyWith({
    FieldId? id,
    String? name,
  }) {
    return Dashboard(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'typedef.dart';

part 'generated/user.g.dart';

@immutable
@JsonSerializable()

/// User model for an API providing to access user
class User extends Equatable {
  /// {macro User}
  const User({
    required this.id,
    required this.username,
    required this.password,
  });

  /// The ID
  final FieldId id;

  /// The username of user
  final String username;

  /// The password of user
  final String password;

  /// Deserializes the given [JsonMap] into a [User].
  static User fromJson(JsonMap json) {
    return _$UserFromJson(json);
  }

  /// Converts this [User] into a [JsonMap].
  JsonMap toJson() => _$UserToJson(this);

  /// Returns a copy of [User] with given parameters
  User copyWith({
    FieldId? id,
    String? username,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [id, username, password];
}

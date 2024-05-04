import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
final class AuthorMeta {
  const AuthorMeta({
    required this.id,
    this.userNicename,
    this.userRegistered,
    this.displayName,
  });

  factory AuthorMeta.fromJson(Map<String, dynamic> json) {
    return AuthorMeta(
      id: castOrElse(json['ID']),
      userNicename: castOrElse(json['user_nicename']),
      userRegistered: parseDateIfNotNull(castOrElse(json['user_registered'])),
      displayName: castOrElse(json['display_name']),
    );
  }

  final String id;
  final String? userNicename;
  final DateTime? userRegistered;
  final String? displayName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ID': id,
      'user_nicename': userNicename,
      'user_registered': userRegistered?.toIso8601String(),
      'display_name': displayName,
    };
  }

  @override
  bool operator ==(covariant AuthorMeta other) {
    if (identical(this, other)) {
      return true;
    }

    return other.id == id &&
        other.userNicename == userNicename &&
        other.userRegistered == userRegistered &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userNicename.hashCode ^
        userRegistered.hashCode ^
        displayName.hashCode;
  }

  @override
  String toString() {
    return 'AuthorMeta(id: $id, userNicename: $userNicename, userRegistered: $userRegistered, displayName: $displayName)';
  }
}

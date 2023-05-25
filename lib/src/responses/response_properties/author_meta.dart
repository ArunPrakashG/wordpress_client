import 'package:meta/meta.dart';

import '../../utilities/helpers.dart';

@immutable
class AuthorMeta {
  const AuthorMeta({
    this.id,
    this.userNicename,
    this.userRegistered,
    this.displayName,
  });

  factory AuthorMeta.fromJson(dynamic json) {
    return AuthorMeta(
      id: json?['ID'] as String?,
      userNicename: json?['user_nicename'] as String?,
      userRegistered: parseDateIfNotNull(json?['user_registered']),
      displayName: json?['display_name'] as String?,
    );
  }

  final String? id;
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

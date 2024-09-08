import 'package:meta/meta.dart';

import '../library_exports.dart';
import '../utilities/self_representive_base.dart';

/// Represents an application password in the WordPress system.
///
/// Application passwords allow authentication for non-interactive systems, such as mobile or desktop applications,
/// without providing your actual password. Each application password has limited capabilities compared to your main account password.
@immutable
final class ApplicationPassword implements ISelfRespresentive {
  /// Creates a new [ApplicationPassword] instance.
  ///
  /// - [uuid]: The unique identifier for this application password.
  /// - [appId]: The ID of the application associated with this password.
  /// - [name]: The name of the application password.
  /// - [created]: The date and time when the password was created.
  /// - [lastUsed]: The date and time when the password was last used.
  /// - [lastIp]: The IP address from which the password was last used.
  /// - [password]: The actual password string (only available when first created).
  /// - [self]: The raw JSON representation of this object.
  const ApplicationPassword({
    required this.uuid,
    required this.appId,
    required this.name,
    required this.created,
    required this.self,
    this.lastUsed,
    this.lastIp,
    this.password,
  });

  /// Creates an [ApplicationPassword] instance from a JSON map.
  ///
  /// [json] is the JSON map containing the application password data.
  factory ApplicationPassword.fromJson(Map<String, dynamic> json) {
    return ApplicationPassword(
      uuid: castOrElse(json['uuid']),
      appId: castOrElse(json['app_id']),
      name: castOrElse(json['name'], orElse: () => '')!,
      created: parseDateIfNotNull(castOrElse(json['created'])),
      lastUsed: parseDateIfNotNull(castOrElse(json['last_used'])),
      lastIp: castOrElse(json['last_ip']),
      password: castOrElse(json['password']),
      self: json,
    );
  }

  /// The unique identifier for this application password.
  final String uuid;

  /// The ID of the application associated with this password.
  final String? appId;

  /// The name of the application password.
  final String name;

  /// The date and time when the password was created.
  final DateTime? created;

  /// The date and time when the password was last used.
  final DateTime? lastUsed;

  /// The IP address from which the password was last used.
  final String? lastIp;

  /// The actual password string (only available when first created).
  final String? password;

  /// The raw JSON representation of this object.
  @override
  final Map<String, dynamic> self;

  /// Converts this [ApplicationPassword] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'app_id': appId,
      'name': name,
      'created': created?.toIso8601String(),
      'last_used': lastUsed?.toIso8601String(),
      'last_ip': lastIp,
      'password': password,
    };
  }

  @override
  bool operator ==(covariant ApplicationPassword other) {
    if (identical(this, other)) {
      return true;
    }

    return other.uuid == uuid &&
        other.appId == appId &&
        other.name == name &&
        other.created == created &&
        other.lastUsed == lastUsed &&
        other.lastIp == lastIp &&
        other.password == password;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        appId.hashCode ^
        name.hashCode ^
        created.hashCode ^
        lastUsed.hashCode ^
        lastIp.hashCode ^
        password.hashCode;
  }

  @override
  String toString() {
    return 'ApplicationPassword(uuid: $uuid, appId: $appId, name: $name, created: $created, lastUsed: $lastUsed, lastIp: $lastIp, password: $password)';
  }
}

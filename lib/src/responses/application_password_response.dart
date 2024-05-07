import 'package:meta/meta.dart';

import '../library_exports.dart';
import '../utilities/self_representive_base.dart';

@immutable
final class ApplicationPassword implements ISelfRespresentive {
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

  factory ApplicationPassword.fromJson(Map<String, dynamic> json) {
    return ApplicationPassword(
      uuid: castOrElse(json['uuid']),
      appId: castOrElse(json['app_id']),
      name: castOrElse(json['name']),
      created: parseDateIfNotNull(castOrElse(json['created'])),
      lastUsed: parseDateIfNotNull(castOrElse(json['last_used'])),
      lastIp: castOrElse(json['last_ip']),
      password: castOrElse(json['password']),
      self: json,
    );
  }

  final String uuid;
  final String? appId;
  final String name;
  final DateTime? created;
  final DateTime? lastUsed;
  final String? lastIp;
  final String? password;

  @override
  final Map<String, dynamic> self;

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
}

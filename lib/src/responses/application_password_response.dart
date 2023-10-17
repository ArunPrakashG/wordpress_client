import 'package:meta/meta.dart';

import '../library_exports.dart';
import '../utilities/self_representive_base.dart';
import 'properties/links.dart';

@immutable
final class ApplicationPassword implements ISelfRespresentive {
  const ApplicationPassword({
    required this.uuid,
    required this.appId,
    required this.name,
    required this.created,
    required this.lastUsed,
    required this.lastIp,
    required this.links,
    required this.self,
    this.password,
  });

  factory ApplicationPassword.fromJson(Map<String, dynamic> map) {
    return ApplicationPassword(
      uuid: castOrElse(map['uuid']),
      appId: castOrElse(map['app_id']),
      name: castOrElse(map['name']),
      created: castOrElse(
        map['created'],
        transformer: (value) => DateTime.parse(value as String),
      )!,
      lastUsed: castOrElse(
        map['last_used'],
        transformer: (value) => DateTime.parse(value as String),
      )!,
      lastIp: castOrElse(map['last_ip']),
      password: castOrElse(map['password']),
      links: castOrElse(
        map['_links'],
        transformer: (value) => Links.fromJson(value as Map<String, dynamic>),
      ),
      self: map,
    );
  }

  final String uuid;
  final String appId;
  final String name;
  final DateTime created;
  final DateTime lastUsed;
  final String lastIp;
  final Links? links;
  final String? password;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'app_id': appId,
      'name': name,
      'created': created.toIso8601String(),
      'last_used': lastUsed.toIso8601String(),
      'last_ip': lastIp,
      'password': password,
      '_links': links?.toJson(),
    };
  }
}

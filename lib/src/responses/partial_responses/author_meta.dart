import 'dart:convert';

class AuthorMeta {
  AuthorMeta({
    this.id,
    this.userNicename,
    this.userRegistered,
    this.displayName,
  });

  final String? id;
  final String? userNicename;
  final DateTime? userRegistered;
  final String? displayName;

  factory AuthorMeta.fromJson(String str) =>
      AuthorMeta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuthorMeta.fromMap(Map<String, dynamic> json) => AuthorMeta(
        id: json['ID'] ?? '',
        userNicename: json['user_nicename'] ?? '',
        userRegistered: json['user_registered'] == null
            ? null
            : DateTime.parse(json['user_registered']),
        displayName: json['display_name'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'ID': id ?? '',
        'user_nicename': userNicename ?? '',
        'user_registered':
            userRegistered == null ? null : userRegistered!.toIso8601String(),
        'display_name': displayName ?? '',
      };
}

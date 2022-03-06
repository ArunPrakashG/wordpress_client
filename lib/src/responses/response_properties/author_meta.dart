class AuthorMeta {
  AuthorMeta({
    this.id,
    this.userNicename,
    this.userRegistered,
    this.displayName,
  });

  factory AuthorMeta.fromJson(dynamic json) {
    return AuthorMeta(
      id: json?['ID'] as String?,
      userNicename: json?['user_nicename'] as String?,
      userRegistered: json?['user_registered'] == null
          ? null
          : DateTime.parse(json?['user_registered'] as String),
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
}

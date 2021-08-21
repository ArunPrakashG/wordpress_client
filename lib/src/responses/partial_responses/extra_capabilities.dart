import 'dart:convert';

class ExtraCapabilities {
  ExtraCapabilities({
    this.administrator,
  });

  final bool? administrator;

  factory ExtraCapabilities.fromJson(String str) =>
      ExtraCapabilities.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ExtraCapabilities.fromMap(Map<String, dynamic> json) =>
      ExtraCapabilities(
        administrator:
            json["administrator"] == null ? null : json["administrator"],
      );

  Map<String, dynamic> toMap() => {
        "administrator": administrator == null ? null : administrator,
      };
}

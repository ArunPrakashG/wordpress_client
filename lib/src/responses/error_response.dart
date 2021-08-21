import 'dart:convert';

import '../utilities/serializable_instance.dart';

class ErrorResponse implements ISerializable<ErrorResponse> {
  final String? code;
  final String? message;
  final Map<String, dynamic>? data;

  ErrorResponse({
    this.code,
    this.message,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }

  factory ErrorResponse.fromMap(Map<String, dynamic> map) {
    return ErrorResponse(
      code: map['code'],
      message: map['message'],
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
    );
  }

  factory ErrorResponse.fromJson(String source) =>
      ErrorResponse.fromMap(json.decode(source));

  @override
  ErrorResponse fromJson(Map<String, dynamic>? json) =>
      ErrorResponse.fromMap(json!);

  @override
  Map<String, dynamic> toJson() => toMap();
}

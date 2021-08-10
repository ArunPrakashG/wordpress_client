import 'dart:convert';

class JwtToken {
  bool? success;
  int? statusCode;
  String? code;
  String? message;
  String? token;
  String? user_email;
  String? user_nicename;
  String? user_display_name;
  
  JwtToken({
    this.success,
    this.statusCode,
    this.code,
    this.message,
    this.token,
    this.user_email,
    this.user_nicename,
    this.user_display_name,
  });

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': success,
      'statusCode': statusCode,
      'code': code,
      'message': message,
      'token': token,
      'user_email': user_email,
      'user_nicename': user_nicename,
      'user_display_name': user_display_name,
    };
  }

  factory JwtToken.fromMap(Map<String, dynamic> map) {
    return JwtToken(
      success: map['isSuccess'],
      statusCode: map['statusCode'],
      code: map['code'],
      message: map['message'],
      token: map['token'],
      user_email: map['user_email'],
      user_nicename: map['user_nicename'],
      user_display_name: map['user_display_name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory JwtToken.fromJson(String source) => JwtToken.fromMap(json.decode(source));
}

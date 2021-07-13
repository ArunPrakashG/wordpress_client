import 'dart:convert';

class JwtValidate {
  bool success;
  int statusCode;
  String message;
  String code;
  Data data;
  JwtValidate({
    this.success,
    this.statusCode,
    this.message,
    this.code,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'code': code,
      'data': data.toMap(),
    };
  }

  factory JwtValidate.fromMap(Map<String, dynamic> map) {
    return JwtValidate(
      success: map['success'],
      statusCode: map['statusCode'],
      message: map['message'],
      code: map['code'],
      data: Data.fromMap(map['data']),
    );
  }

  String toJson() => json.encode(toMap());

  factory JwtValidate.fromJson(String source) => JwtValidate.fromMap(json.decode(source));
}

class Data {
  int status;
  
  Data({
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      status: map['status'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) => Data.fromMap(json.decode(source));
}

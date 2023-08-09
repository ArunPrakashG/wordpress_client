import 'package:meta/meta.dart';

import '../utilities/helpers.dart';

@immutable
final class WordpressError {
  const WordpressError({
    required this.code,
    this.message,
    this.status,
  });

  factory WordpressError.fromMap(Map<String, dynamic> map) {
    return WordpressError(
      code: castOrElse(map['code'], orElse: () => '')!,
      message: castOrElse(map['message']),
      status: castOrElse(map['data']?['status']),
    );
  }

  final String code;
  final String? message;
  final int? status;

  @override
  bool operator ==(covariant WordpressError other) {
    if (identical(this, other)) {
      return true;
    }

    return other.code == code &&
        other.message == message &&
        other.status == status;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ status.hashCode;

  @override
  String toString() => '($status - $code) $message';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'message': message,
      'status': status,
    };
  }
}

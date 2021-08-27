import 'package:wordpress_client/src/utilities/serializable_instance.dart';

class MyResponse implements ISerializable<MyResponse> {
  @override
  MyResponse fromJson(Map<String, dynamic>? json) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

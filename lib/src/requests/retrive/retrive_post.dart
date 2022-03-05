import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class RetrivePostRequest implements IRequest {
  RetrivePostRequest({
    this.context,
    this.password,
    required this.id,
  });

  FilterContext? context;
  String? password;
  int id;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('password', password)
      ..addIfNotNull('id', id);
  }
}

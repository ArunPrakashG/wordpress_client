import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class RetriveUserRequest implements IRequest {
  RetriveUserRequest({
    this.context,
    required this.id,
  });

  FilterContext? context;
  int id;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('context', context?.name)
      ..addIfNotNull('id', id);
  }
}

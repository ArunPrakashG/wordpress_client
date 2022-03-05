import '../../enums.dart';
import '../../utilities/helpers.dart';
import '../request_interface.dart';

class RetriveMeRequest implements IRequest {
  RetriveMeRequest({
    this.context = FilterContext.VIEW,
  });

  FilterContext? context;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}..addIfNotNull('context', context?.name);
  }
}

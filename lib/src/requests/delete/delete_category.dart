import '../../utilities/helpers.dart';
import '../request_interface.dart';

class DeleteCategoryRequest implements IRequest {
  DeleteCategoryRequest({
    this.force,
  });

  bool? force;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}..addIfNotNull('force', force);
  }
}

import '../../utilities/helpers.dart';
import '../request_interface.dart';

class DeleteTagRequest implements IRequest {
  DeleteTagRequest({
    this.force,
  });

  bool? force;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}..addIfNotNull('force', force);
  }
}

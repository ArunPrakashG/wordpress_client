import '../../utilities/helpers.dart';
import '../request_interface.dart';

class DeleteMediaRequest implements IRequest {
  DeleteMediaRequest({
    this.id,
    this.force,
  });

  int? id;
  bool? force;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('id', id)
      ..addIfNotNull('force', force);
  }
}

import '../../utilities/helpers.dart';
import '../request_interface.dart';

class DeleteMeRequest implements IRequest {
  DeleteMeRequest({
    this.force,
    this.reassign,
  });

  bool? force;
  int? reassign;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addIfNotNull('reassign', (reassign ?? -1) > 0 ? reassign : null);
  }
}

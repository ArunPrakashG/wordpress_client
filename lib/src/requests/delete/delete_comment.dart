import '../../utilities/helpers.dart';
import '../request_interface.dart';

class DeleteCommentRequest implements IRequest {
  DeleteCommentRequest({
    this.force,
    this.password,
  });

  bool? force;
  String? password;

  @override
  Map<String, dynamic> build() {
    return <String, dynamic>{}
      ..addIfNotNull('force', force)
      ..addIfNotNull('password', password);
  }
}

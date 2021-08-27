import 'package:wordpress_client/src/builders/create/post_create.dart';
import 'package:wordpress_client/src/builders/delete/post_delete.dart';
import 'package:wordpress_client/src/builders/retrive/post_retrive.dart';
import 'package:wordpress_client/src/responses/post_response.dart';

import 'package:wordpress_client/wordpress_client.dart';

class TestInterface extends IInterface
    implements ICreateOperation<Post, PostCreateBuilder>, IDeleteOperation<Post, PostDeleteBuilder>, IRetriveOperation<Post, PostRetriveBuilder> {
  @override
  Future<ResponseContainer<Post?>> create(Request<Post>? Function(PostCreateBuilder p1) builder, {bool shouldWaitWhileClientBusy = false}) async {
    throw UnimplementedError();
  }

  @override
  Future<ResponseContainer<Post?>> delete(Request<Post>? Function(PostDeleteBuilder p1) builder, {bool shouldWaitWhileClientBusy = false}) {
    throw UnimplementedError();
  }

  @override
  Future<ResponseContainer<Post?>> retrive(Request<Post>? Function(PostRetriveBuilder p1) builder, {bool shouldWaitWhileClientBusy = false}) {
    throw UnimplementedError();
  }
}

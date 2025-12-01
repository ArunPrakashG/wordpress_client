import 'package:wordpress_client/src/utilities/helpers.dart';

final class MyResponse {
  const MyResponse({
    this.id,
    this.post,
    this.parent,
    this.author,
  });

  factory MyResponse.fromJson(dynamic json) {
    return MyResponse(
      id: castOrElse(json['id']),
      post: castOrElse(json['post']),
      parent: castOrElse(json['parent']),
      author: castOrElse(json['author']),
    );
  }

  final int? id;
  final int? post;
  final int? parent;
  final int? author;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'post': post,
      'parent': parent,
      'author': author,
    };
  }
}

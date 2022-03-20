class MyResponse {
  MyResponse({
    this.id,
    this.post,
    this.parent,
    this.author,
  });

  factory MyResponse.fromJson(dynamic json) {
    return MyResponse(
      id: json['id'] as int?,
      post: json['post'] as int?,
      parent: json['parent'] as int?,
      author: json['author'] as int?,
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

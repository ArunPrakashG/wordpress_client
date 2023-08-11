// ignore_for_file: comment_references

abstract class ISelfRespresentive {
  const ISelfRespresentive({
    required this.self,
  });

  /// Represents the entire JSON body as a Map.
  ///
  /// Usefull if you have extra fields in the response and would like to read them without writing a custom request/response workflow.
  ///
  /// You can get each field by using the [getField] method. Moreover, you can use `[]` operator to access the values by their key. Eg: `response['key']`
  final Map<String, dynamic> self;
}

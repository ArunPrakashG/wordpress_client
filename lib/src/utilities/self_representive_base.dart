abstract class ISelfRespresentive {
  const ISelfRespresentive({
    required this.self,
  });

  /// Represents the entire JSON body as a Map.
  ///
  /// Usefull if you have extra fields in the response and would like to read them without writing a custom request/response workflow.
  final Map<String, dynamic> self;
}

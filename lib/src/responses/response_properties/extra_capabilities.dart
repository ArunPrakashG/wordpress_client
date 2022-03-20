class ExtraCapabilities {
  ExtraCapabilities({
    this.administrator,
  });

  factory ExtraCapabilities.fromJson(dynamic json) {
    return ExtraCapabilities(administrator: json?['administrator'] as bool?);
  }

  final bool? administrator;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'administrator': administrator,
    };
  }
}

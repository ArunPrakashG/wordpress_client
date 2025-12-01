import 'package:meta/meta.dart';

import '../utilities/self_representive_base.dart';

/// Represents a rendered block response from block renderer endpoint.
@immutable
class RenderedBlock implements ISelfRespresentive {
  const RenderedBlock({required this.rendered, required this.self});

  factory RenderedBlock.fromJson(Map<String, dynamic> json) => RenderedBlock(
        rendered: json['rendered'] as String? ?? '',
        self: json,
      );

  final String rendered;

  @override
  final Map<String, dynamic> self;
}

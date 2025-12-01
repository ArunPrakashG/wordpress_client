import 'package:meta/meta.dart';

import '../utilities/self_representive_base.dart';

/// Represents a Block Type (wp/v2/block-types)
@immutable
class BlockType implements ISelfRespresentive {
  const BlockType({
    required this.name,
    required this.title,
    this.description,
    this.category,
    this.icon,
    this.supports,
    this.attributes,
    this.providesContext,
    this.usesContext,
    this.selectors,
    this.apiVersion,
    this.isDynamic,
    this.textdomain,
    this.parent,
    this.ancestor,
    this.editorScriptHandles,
    this.scriptHandles,
    this.viewScriptHandles,
    this.editorStyleHandles,
    this.styleHandles,
    this.keywords,
    this.example,
    this.styles,
    this.variations,
    this.self = const {},
  });

  factory BlockType.fromJson(Map<String, dynamic> json) => BlockType(
        name: json['name'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        icon: json['icon'],
        supports: json['supports'] as Map<String, dynamic>?,
        attributes: json['attributes'] as Map<String, dynamic>?,
        providesContext: json['provides_context'] as Map<String, dynamic>?,
        usesContext: (json['uses_context'] as List?)?.cast<String>(),
        selectors: json['selectors'] as Map<String, dynamic>?,
        apiVersion: json['api_version'] as int?,
        isDynamic: json['is_dynamic'] as bool?,
        textdomain: json['textdomain'] as String?,
        parent: (json['parent'] as List?)?.cast<String>(),
        ancestor: (json['ancestor'] as List?)?.cast<String>(),
        editorScriptHandles:
            (json['editor_script_handles'] as List?)?.cast<String>(),
        scriptHandles: (json['script_handles'] as List?)?.cast<String>(),
        viewScriptHandles:
            (json['view_script_handles'] as List?)?.cast<String>(),
        editorStyleHandles:
            (json['editor_style_handles'] as List?)?.cast<String>(),
        styleHandles: (json['style_handles'] as List?)?.cast<String>(),
        keywords: (json['keywords'] as List?)?.cast<String>(),
        example: json['example'] as Map<String, dynamic>?,
        styles: (json['styles'] as List?)?.cast<Map<String, dynamic>>(),
        variations: (json['variations'] as List?)?.cast<Map<String, dynamic>>(),
        self: json,
      );

  final String name;
  final String title;
  final String? description;
  final String? category;
  final dynamic icon;
  final Map<String, dynamic>? supports;
  final Map<String, dynamic>? attributes;
  final Map<String, dynamic>? providesContext;
  final List<String>? usesContext;
  final Map<String, dynamic>? selectors;
  final int? apiVersion;
  final bool? isDynamic;
  final String? textdomain;
  final List<String>? parent;
  final List<String>? ancestor;
  final List<String>? editorScriptHandles;
  final List<String>? scriptHandles;
  final List<String>? viewScriptHandles;
  final List<String>? editorStyleHandles;
  final List<String>? styleHandles;
  final List<String>? keywords;
  final Map<String, dynamic>? example;
  final List<Map<String, dynamic>>? styles;
  final List<Map<String, dynamic>>? variations;

  @override
  final Map<String, dynamic> self;
}

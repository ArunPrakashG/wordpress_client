import '../../responses/properties/links.dart';
import '../helpers.dart';
import '../self_representive_base.dart';

extension SelfRepresentiveExtensions on ISelfRepresentative {
  /// Returns the value of the key or null if it doesn't exist.
  ///
  /// Casts the returning value to the type of the generic type parameter.
  T? getField<T>(
    String key, {
    T Function()? orElse,
    T? Function(dynamic value)? transformer,
  }) {
    return castOrElse(
      self[key],
      orElse: orElse,
      transformer: transformer,
    );
  }

  /// Checks if the self map contains the key
  bool containsKey(String key) => self.containsKey(key);

  /// Returns the value of the key or null if it doesn't exist.
  dynamic operator [](String key) => self[key];

  T? call<T>(
    String key, {
    T Function()? orElse,
    T? Function(dynamic value)? transformer,
  }) {
    return getField<T>(key, orElse: orElse, transformer: transformer);
  }

  @Deprecated('Use "self"')
  Map<String, dynamic> get json => self;

  Links? get links {
    return getField(
      '_links',
      transformer: (value) {
        return Links.fromJson(value as Map<String, dynamic>);
      },
    );
  }

  dynamic get meta => getField('meta');

  /// The Advanced Custom Fields values (`acf`), or null when the site does
  /// not expose them.
  Map<String, dynamic>? get acf {
    final value = self['acf'];

    return value is Map ? value.cast<String, dynamic>() : null;
  }

  /// The registered meta value [key] (from `meta`) as [T], or null when it
  /// is missing or cannot be converted. Meta keys need `show_in_rest`.
  ///
  /// Numbers, booleans, strings and dates are converted leniently, since
  /// WordPress often returns them as strings: `'12'` reads as `12` for
  /// `int`, `'1'` as `true` for `bool`.
  ///
  /// ```dart
  /// final rating = post.metaValue<int>('rating');
  /// ```
  T? metaValue<T>(String key) {
    final values = self['meta'];

    return values is Map ? _coerce<T>(values[key]) : null;
  }

  /// The Advanced Custom Fields value [field] (from `acf`) as [T], with the
  /// same conversions as [metaValue]. Date pickers (`20240131`) read as
  /// [DateTime].
  ///
  /// ```dart
  /// final price = product.acfValue<double>('price');
  /// final launch = product.acfValue<DateTime>('launch_date');
  /// ```
  T? acfValue<T>(String field) => _coerce<T>(acf?[field]);
}

/// Whether [T] is [S] or `S?`.
bool _isType<T, S>() => <T>[] is List<S?>;

T? _coerce<T>(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is T) {
    return value as T;
  }

  final Object? converted;
  if (_isType<T, int>()) {
    converted = value is num ? value.toInt() : int.tryParse('$value');
  } else if (_isType<T, double>()) {
    converted = value is num ? value.toDouble() : double.tryParse('$value');
  } else if (_isType<T, num>()) {
    converted = num.tryParse('$value');
  } else if (_isType<T, bool>()) {
    converted = switch ('$value'.toLowerCase()) {
      '1' || 'true' || 'yes' || 'on' => true,
      '0' || 'false' || 'no' || 'off' || '' => false,
      _ => null,
    };
  } else if (_isType<T, String>()) {
    converted = value is num || value is bool ? '$value' : null;
  } else if (_isType<T, DateTime>()) {
    converted = value is String ? DateTime.tryParse(value) : null;
  } else {
    converted = null;
  }

  return converted is T ? converted : null;
}

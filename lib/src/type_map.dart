import 'utilities/helpers.dart';

class TypeMap {
  static final Map<Type, dynamic Function(Map<String, dynamic> instance)>
      _decoders = {};
  static final Map<Type, Map<String, dynamic> Function(dynamic instance)>
      _encoders = {};

  void addDecoderForType<T>(T Function(Map<String, dynamic> instance) decoder) {
    _decoders[typeOf<T>()] = decoder;
  }

  void removeDecoderForType<T>() {
    _decoders.remove(typeOf<T>());
  }

  static T Function(Map<String, dynamic> instance) getDecoderForType<T>() {
    if (_decoders[typeOf<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${typeOf<T>()} does not exist!');
    }

    return _decoders[typeOf<T>()] as T Function(Map<String, dynamic> instance);
  }

  void addEncoderForType<T>(
      Map<String, dynamic> Function(dynamic instance) encoder) {
    _encoders[typeOf<T>()] = encoder;
  }

  void removeEncoderForType<T>() {
    _encoders.remove(typeOf<T>());
  }

  static Map<String, dynamic> Function(T? instance) getEncoderForType<T>() {
    if (_encoders[typeOf<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${typeOf<T>()} does not exist!');
    }

    return _encoders[typeOf<T>()] as Map<String, dynamic> Function(T? instance);
  }

  void addJsonPairForType<T>({
    required Map<String, dynamic> Function(dynamic instance) encoder,
    required T Function(Map<String, dynamic> instance) decoder,
  }) {
    addDecoderForType<T>(decoder);
    addEncoderForType<T>(encoder);
  }
}

class MapDoesNotExistException implements Exception {
  MapDoesNotExistException(this.message);

  final String message;

  @override
  String toString() => message;
}

// ignore_for_file: avoid_positional_boolean_parameters

import 'type_key.dart';

typedef JsonEncoderCallback = Map<String, dynamic> Function(dynamic instance);
typedef JsonDecoderCallback<T> = T Function(Map<String, dynamic> json);

class TypeMap {
  static final Map<TypeKey<dynamic>, JsonDecoderCallback> _decoders = {};
  static final Map<TypeKey<dynamic>, JsonEncoderCallback> _encoders = {};

  bool containsEncoderForType<T>() => _encoders[TypeKey<T>()] != null;

  bool containsDecoderForType<T>() => _decoders[TypeKey<T>()] != null;

  void addDecoderForType<T>(
    JsonDecoderCallback<T> decoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    final typeKey = TypeKey<T>();
    if (!overwrite && containsDecoderForType<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
            'Decoder for type ${typeKey.toString()} already exists');
      }

      return;
    }

    _decoders[typeKey] = decoder;
  }

  void removeDecoderForType<T>() {
    if (!containsDecoderForType<T>()) {
      throw MapDoesNotExistException(
          'Map of type: ${TypeKey<T>()} does not exist!');
    }

    _decoders.remove(TypeKey<T>());
  }

  static JsonDecoderCallback<T> getDecoderForType<T>() {
    if (_decoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${TypeKey<T>()} does not exist!');
    }

    return _decoders[TypeKey<T>()] as T Function(Map<String, dynamic> instance);
  }

  void addEncoderForType<T>(
    JsonEncoderCallback encoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    if (!overwrite && containsEncoderForType<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
            'Encoder for type ${TypeKey<T>().toString()} already exists');
      }

      return;
    }

    _encoders[TypeKey<T>()] = encoder;
  }

  void removeEncoderForType<T>() {
    if (!containsEncoderForType<T>()) {
      throw MapDoesNotExistException(
          'Map of type: ${TypeKey<T>()} does not exist!');
    }

    _encoders.remove(TypeKey<T>());
  }

  static JsonEncoderCallback getEncoderForType<T>() {
    if (_encoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${TypeKey<T>()} does not exist!');
    }

    return _encoders[TypeKey<T>()] as JsonEncoderCallback;
  }

  void addJsonPairForType<T>({
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<T> decoder,
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    addDecoderForType<T>(
      decoder,
      overwrite: overwrite,
      throwIfExists: throwIfExists,
    );
    addEncoderForType<T>(
      encoder,
      overwrite: overwrite,
      throwIfExists: throwIfExists,
    );
  }
}

class MapDoesNotExistException implements Exception {
  MapDoesNotExistException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MapAlreadyExistException implements Exception {
  MapAlreadyExistException(this.message);

  final String message;

  @override
  String toString() => message;
}

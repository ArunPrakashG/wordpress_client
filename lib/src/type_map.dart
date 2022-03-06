// ignore_for_file: avoid_positional_boolean_parameters

import 'utilities/helpers.dart';

typedef JsonEncoderCallback = Map<String, dynamic> Function(dynamic instance);
typedef JsonDecoderCallback<T> = T Function(Map<String, dynamic> json);

class TypeMap {
  static final Map<Type, JsonDecoderCallback> _decoders = {};
  static final Map<Type, JsonEncoderCallback> _encoders = {};

  void addDecoderForType<T>(
    JsonDecoderCallback<T> decoder, [
    bool overriteIfExisting = false,
  ]) {
    if (!overriteIfExisting && _decoders[typeOf<T>()] != null) {
      throw MapAlreadyExistException(
          'Decoder for type ${typeOf<T>().toString()} already exists');
    }

    _decoders[typeOf<T>()] = decoder;
  }

  void removeDecoderForType<T>() {
    _decoders.remove(typeOf<T>());
  }

  static JsonDecoderCallback<T> getDecoderForType<T>() {
    if (_decoders[typeOf<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${typeOf<T>()} does not exist!');
    }

    return _decoders[typeOf<T>()] as T Function(Map<String, dynamic> instance);
  }

  void addEncoderForType<T>(
    JsonEncoderCallback encoder, [
    bool overriteIfExisting = false,
  ]) {
    if (!overriteIfExisting && _encoders[typeOf<T>()] != null) {
      throw MapAlreadyExistException(
          'Encoder for type ${typeOf<T>().toString()} already exists');
    }

    _encoders[typeOf<T>()] = encoder;
  }

  void removeEncoderForType<T>() {
    _encoders.remove(typeOf<T>());
  }

  static JsonEncoderCallback getEncoderForType<T>() {
    if (_encoders[typeOf<T>()] == null) {
      throw MapDoesNotExistException(
          'Map of type: ${typeOf<T>()} does not exist!');
    }

    return _encoders[typeOf<T>()] as JsonEncoderCallback;
  }

  void addJsonPairForType<T>({
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<T> decoder,
    bool overriteIfExists = false,
  }) {
    addDecoderForType<T>(decoder, overriteIfExists);
    addEncoderForType<T>(encoder, overriteIfExists);
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

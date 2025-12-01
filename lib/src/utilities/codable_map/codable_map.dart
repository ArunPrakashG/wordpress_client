import '../../exceptions/type_map/map_does_not_exist_exception.dart';
import '../../exceptions/type_map/map_exist_exception.dart';
import '../typedefs.dart';
import 'type_key.dart';

/// A utility class for managing encoders and decoders for JSON serialization.
///
/// This class provides methods to register, retrieve, and manage custom
/// encoders and decoders for different types, allowing for flexible
/// JSON encoding and decoding of complex objects.
class CodableMap {
  static final Map<TypeKey<dynamic>, JsonDecoderCallback> _decoders = {};
  static final Map<TypeKey<dynamic>, JsonEncoderCallback> _encoders = {};

  /// Checks if an encoder exists for the given type [T].
  ///
  /// Returns `true` if an encoder is registered for type [T], `false` otherwise.
  bool encoderExists<T>() => _encoders[TypeKey<T>()] != null;

  /// Checks if a decoder exists for the given type [T].
  ///
  /// Returns `true` if a decoder is registered for type [T], `false` otherwise.
  bool decoderExists<T>() => _decoders[TypeKey<T>()] != null;

  /// Adds a decoder for the type [T].
  ///
  /// [decoder] is the function that will be used to decode JSON to type [T].
  /// If [overwrite] is true, it will replace an existing decoder if present.
  /// If [throwIfExists] is true, it will throw a [MapAlreadyExistException] if a decoder already exists.
  void addDecoder<T>(
    JsonDecoderCallback<T> decoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    final typeKey = TypeKey<T>();
    if (!overwrite && decoderExists<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
          'Decoder for type $typeKey already exists',
        );
      }

      return;
    }

    _decoders[typeKey] = decoder;
  }

  /// Removes the decoder for the type [T].
  ///
  /// Throws a [MapDoesNotExistException] if no decoder exists for type [T].
  void removeDecoder<T>() {
    if (!decoderExists<T>()) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    _decoders.remove(TypeKey<T>());
  }

  /// Retrieves the decoder for the type [T].
  ///
  /// Throws a [MapDoesNotExistException] if no decoder exists for type [T].
  static JsonDecoderCallback<T> getDecoder<T>() {
    if (_decoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    return _decoders[TypeKey<T>()]! as T Function(dynamic instance);
  }

  /// Adds an encoder for the type [T].
  ///
  /// [encoder] is the function that will be used to encode type [T] to JSON.
  /// If [overwrite] is true, it will replace an existing encoder if present.
  /// If [throwIfExists] is true, it will throw a [MapAlreadyExistException] if an encoder already exists.
  void addEncoder<T>(
    JsonEncoderCallback encoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    if (!overwrite && encoderExists<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
          'Encoder for type ${TypeKey<T>()} already exists',
        );
      }

      return;
    }

    _encoders[TypeKey<T>()] = encoder;
  }

  /// Clears all registered encoders and decoders.
  void clear() {
    _decoders.clear();
    _encoders.clear();
  }

  /// Removes the encoder for the type [T].
  ///
  /// Throws a [MapDoesNotExistException] if no encoder exists for type [T].
  void removeEncoder<T>() {
    if (!encoderExists<T>()) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    _encoders.remove(TypeKey<T>());
  }

  /// Retrieves the encoder for the type [T].
  ///
  /// Throws a [MapDoesNotExistException] if no encoder exists for type [T].
  static JsonEncoderCallback getEncoder<T>() {
    if (_encoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    return _encoders[TypeKey<T>()]!;
  }

  /// Adds both an encoder and a decoder for the type [T] in a single call.
  ///
  /// [encoder] is the function that will be used to encode type [T] to JSON.
  /// [decoder] is the function that will be used to decode JSON to type [T].
  /// If [overwrite] is true, it will replace existing encoder/decoder if present.
  /// If [throwIfExists] is true, it will throw a [MapAlreadyExistException] if an encoder or decoder already exists.
  void addCodablePair<T>({
    required JsonEncoderCallback encoder,
    required JsonDecoderCallback<T> decoder,
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    addDecoder<T>(
      decoder,
      overwrite: overwrite,
      throwIfExists: throwIfExists,
    );
    addEncoder<T>(
      encoder,
      overwrite: overwrite,
      throwIfExists: throwIfExists,
    );
  }
}

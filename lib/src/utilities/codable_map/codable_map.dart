import '../../exceptions/type_map/map_does_not_exist_exception.dart';
import '../../exceptions/type_map/map_exist_exception.dart';
import '../typedefs.dart';
import 'type_key.dart';

class CodableMap {
  static final Map<TypeKey<dynamic>, JsonDecoderCallback> _decoders = {};
  static final Map<TypeKey<dynamic>, JsonEncoderCallback> _encoders = {};

  bool encoderExists<T>() => _encoders[TypeKey<T>()] != null;

  bool decoderExists<T>() => _decoders[TypeKey<T>()] != null;

  void addDecoder<T>(
    JsonDecoderCallback<T> decoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    final typeKey = TypeKey<T>();
    if (!overwrite && decoderExists<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
          'Decoder for type ${typeKey.toString()} already exists',
        );
      }

      return;
    }

    _decoders[typeKey] = decoder;
  }

  void removeDecoder<T>() {
    if (!decoderExists<T>()) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    _decoders.remove(TypeKey<T>());
  }

  static JsonDecoderCallback<T> getDecoder<T>() {
    if (_decoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    return _decoders[TypeKey<T>()] as T Function(dynamic instance);
  }

  void addEncoder<T>(
    JsonEncoderCallback encoder, {
    bool overwrite = false,
    bool throwIfExists = false,
  }) {
    if (!overwrite && encoderExists<T>()) {
      if (throwIfExists) {
        throw MapAlreadyExistException(
          'Encoder for type ${TypeKey<T>().toString()} already exists',
        );
      }

      return;
    }

    _encoders[TypeKey<T>()] = encoder;
  }

  void removeEncoder<T>() {
    if (!encoderExists<T>()) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    _encoders.remove(TypeKey<T>());
  }

  static JsonEncoderCallback getEncoder<T>() {
    if (_encoders[TypeKey<T>()] == null) {
      throw MapDoesNotExistException(
        'Map of type: ${TypeKey<T>()} does not exist!',
      );
    }

    return _encoders[TypeKey<T>()] as JsonEncoderCallback;
  }

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

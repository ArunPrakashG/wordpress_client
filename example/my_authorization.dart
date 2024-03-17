import 'package:dio/dio.dart';
import 'package:wordpress_client/wordpress_client.dart';

final class CustomAuth extends IAuthorization {
  CustomAuth({
    required super.userName,
    required super.password,
    super.events,
  });

  @override
  bool get isValidAuth => throw UnimplementedError();

  @override
  String get scheme => throw UnimplementedError();

  @override
  Future<bool> authorize() {
    throw UnimplementedError();
  }

  @override
  Future<String?> generateAuthUrl() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() {
    throw UnimplementedError();
  }

  @override
  Future<bool> validate() {
    throw UnimplementedError();
  }

  @override
  void clientFactoryProvider(Dio client) {
    throw UnimplementedError();
  }
}

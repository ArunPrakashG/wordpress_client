import 'package:wordpress_client/src/utilities/callback.dart';

abstract class IRequestBuilder<TRequestType, YReturnType> {
  TRequestType initializeWithDefaultValues();

  YReturnType build();

  YReturnType buildWithCallback(Callback callback);
}

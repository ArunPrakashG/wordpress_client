abstract class IRequestBuilder<TRequestType, YReturnType> {
  TRequestType initializeWithDefaultValues();

  YReturnType build();
}

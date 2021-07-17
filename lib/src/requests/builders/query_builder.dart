abstract class QueryBuilder<TBuilderType> {
  Map<String, dynamic> build();

  TBuilderType withDefaultValues();
}

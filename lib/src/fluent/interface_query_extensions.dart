import '../../wordpress_client.dart';

// Extensions do not change the underlying interface type; they offer a discovery-friendly entry.
extension RequestInterfaceFluent on IRequestInterface {
  // Query builder entry for list operations. Caller provides the seed request type.
  ListQueryBuilder<T, R> query<T, R extends IRequest>(R seed) =>
      listQuery<T, R>(interface: this, seed: seed);

  // Retrieve builder entry
  RetrieveQueryBuilder<T, R> get<T, R extends IRequest>(R seed) =>
      retrieveQuery<T, R>(interface: this, seed: seed);

  // Create/Update builder entry
  MutateQueryBuilder<T, R> mutate<T, R extends IRequest>(R seed) =>
      updateQuery<T, R>(interface: this, seed: seed);
}

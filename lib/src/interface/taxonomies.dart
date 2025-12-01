import '../../wordpress_client.dart';

/// Interface for Taxonomies (/wp/v2/taxonomies)
/// Note: The list endpoint returns an object map keyed by slug.
final class TaxonomiesInterface extends IRequestInterface
    with
        CustomOperation<List<Taxonomy>, ListTaxonomyRequest>,
        RetrieveOperation<Taxonomy, RetrieveTaxonomyRequest> {
  @override
  List<Taxonomy> decode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json.values
          .map<Taxonomy>((e) => Taxonomy.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    if (json is Iterable) {
      return json
          .map((e) => Taxonomy.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return const <Taxonomy>[];
  }
}

import '../../wordpress_client.dart';
import 'taxonomies.dart';

final class TaxonomiesExtensions
    implements IInterfaceExtensions<Taxonomy, String> {
  TaxonomiesExtensions(this._iface);
  final TaxonomiesInterface _iface;

  @override
  Future<WordpressResponse<Taxonomy>> getById(
    String slug, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveTaxonomyRequest(slug: slug, context: context),
    );
  }
}

extension TaxonomiesInterfaceExtensions on TaxonomiesInterface {
  TaxonomiesExtensions get extensions => TaxonomiesExtensions(this);
}

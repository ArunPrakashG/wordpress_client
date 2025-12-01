import '../../wordpress_client.dart';

/// Interface for Global Styles (/wp/v2/global-styles)
final class GlobalStylesInterface extends IRequestInterface
    with
        RetrieveOperation<GlobalStyles, RetrieveGlobalStylesRequest>,
        UpdateOperation<GlobalStyles, UpdateGlobalStylesRequest> {}

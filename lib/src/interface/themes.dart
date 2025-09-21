import '../../wordpress_client.dart';

/// Interface for Themes (/wp/v2/themes)
final class ThemesInterface extends IRequestInterface
    with
        ListOperation<Theme, ListThemeRequest>,
        RetrieveOperation<Theme, RetrieveThemeRequest> {}

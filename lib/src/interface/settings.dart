import '../../wordpress_client.dart';

/// Interface for Site Settings (/wp/v2/settings)
final class SettingsInterface extends IRequestInterface
    with
        RetrieveOperation<Settings, RetrieveSettingsRequest>,
        UpdateOperation<Settings, UpdateSettingsRequest> {}

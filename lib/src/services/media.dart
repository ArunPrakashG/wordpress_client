import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class MediaService extends IWordpressService
    with
        CreateMixin<Media, CreateMediaRequest>,
        DeleteMixin<DeleteMediaRequest>,
        RetrieveMixin<Media, RetriveMediaRequest>,
        UpdateMixin<Media, UpdateMediaRequest>,
        ListMixin<Media, ListMediaRequest> {}

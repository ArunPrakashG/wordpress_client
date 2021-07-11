import '../../enums.dart';
import '../../utilities/helpers.dart';
import 'query_builder.dart';
import 'request_builder_base.dart';

class PostBuilder extends QueryBuilder<PostBuilder> implements IRequestBuilder<PostBuilder, Map<String, dynamic>> {
  String _content;
  String _title;
  DateTime _postDate;
  String _slug;
  PostStatus _status;
  String _password;
  int _authorId;
  String _excerpt;
  int _featuredImageId;
  Status _commandStatus;
  Status _pingStatus;
  PostFormat _postFormat;
  bool _sticky;
  List<int> _categories;
  List<int> _tags;

  PostBuilder();

  PostBuilder withContent(String content) {
    _content = content;
    return this;
  }

  PostBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  PostBuilder withDate(DateTime date) {
    _postDate = date;
    return this;
  }

  PostBuilder withSlug(String slug) {
    if (!isAlphaNumeric(slug)) {
      throw ArgumentError('Slug can only contain Alphanumeric Charecters. (a-Z, 0-9)');
    }

    _slug = slug;
    return this;
  }

  PostBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  PostBuilder withAuthor(int id) {
    _authorId = id;
    return this;
  }

  PostBuilder withExcerpt(String excerpt) {
    _excerpt = excerpt;
    return this;
  }

  PostBuilder withFeaturedImage(int id) {
    _featuredImageId = id;
    return this;
  }

  PostBuilder withCommandStatus(Status commandStatus) {
    _commandStatus = commandStatus;
    return this;
  }

  PostBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus;
    return this;
  }

  PostBuilder withPostFormat(PostFormat format) {
    _postFormat = format;
    return this;
  }

  PostBuilder withStickyValue(bool value) {
    _sticky = value;
    return this;
  }

  PostBuilder withCategories(Iterable<int> categories) {
    _categories ??= [];
    _categories.addAll(categories);
    return this;
  }

  PostBuilder withTags(Iterable<int> tags) {
    _tags ??= [];
    _tags.addAll(tags);
    return this;
  }

  @override
  Map<String, dynamic> build() => {
        if (!isNullOrEmpty(_content)) 'content': _content,
        if (!isNullOrEmpty(_title)) 'title': _title,
        if (!isNullOrEmpty(_slug)) 'slug': _slug,
        if (!isNullOrEmpty(_password)) 'password': _password,
        if (_authorId >= 0) 'author': _authorId,
        if (!isNullOrEmpty(_excerpt)) 'excerpt': _excerpt,
        if (_featuredImageId >= 0) 'featured_media': _featuredImageId,
        if (_sticky) 'sticky': '1',
        if (_categories != null && _categories.isNotEmpty) 'categories': _categories.join(','),
        if (_tags != null && _tags.isNotEmpty) 'tags': _tags.join(','),
        if (_postDate != null) 'date': _postDate.toIso8601String(),
        'command_status': _commandStatus.toString().toLowerCase(),
        'ping_status': _pingStatus.toString().toLowerCase(),
        'format': _postFormat.toString().toLowerCase(),
        'status': _status.toString().toLowerCase(),
      };

  @override
  PostBuilder initializeWithDefaultValues() {
    _commandStatus = Status.OPEN;
    _pingStatus = Status.OPEN;
    _postFormat = PostFormat.STANDARD;
    _status = PostStatus.PENDING;
    _authorId = -1;
    _featuredImageId = -1;
    return this;
  }
}

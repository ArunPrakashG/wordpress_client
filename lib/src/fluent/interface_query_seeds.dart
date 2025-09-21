import '../../wordpress_client.dart';
import '../interface/blocks.dart';
import '../interface/category.dart';
import '../interface/comments.dart';
import '../interface/media.dart';
import '../interface/page.dart';
// Import concrete interface types so we can extend them
import '../interface/posts.dart';
import '../interface/revisions.dart';
import '../interface/search.dart';
import '../interface/statuses.dart';
import '../interface/tags.dart';
import '../interface/taxonomies.dart';
import '../interface/templates.dart';
import '../interface/themes.dart';
import '../interface/types.dart';
import '../interface/users.dart';

// Posts
extension PostsQuerySeed on PostsInterface {
  ListQueryBuilder<Post, ListPostRequest> get query =>
      listQuery<Post, ListPostRequest>(
        interface: this,
        seed: ListPostRequest(),
      );
}

// Pages
extension PagesQuerySeed on PagesInterface {
  ListQueryBuilder<Page, ListPageRequest> get query =>
      listQuery<Page, ListPageRequest>(
        interface: this,
        seed: ListPageRequest(),
      );
}

// Media
extension MediaQuerySeed on MediaInterface {
  ListQueryBuilder<Media, ListMediaRequest> get query =>
      listQuery<Media, ListMediaRequest>(
        interface: this,
        seed: ListMediaRequest(),
      );
}

// Comments
extension CommentsQuerySeed on CommentInterface {
  ListQueryBuilder<Comment, ListCommentRequest> get query =>
      listQuery<Comment, ListCommentRequest>(
        interface: this,
        seed: ListCommentRequest(),
      );
}

// Categories
extension CategoriesQuerySeed on CategoryInterface {
  ListQueryBuilder<Category, ListCategoryRequest> get query =>
      listQuery<Category, ListCategoryRequest>(
        interface: this,
        seed: ListCategoryRequest(),
      );
}

// Tags
extension TagsQuerySeed on TagInterface {
  ListQueryBuilder<Tag, ListTagRequest> get query =>
      listQuery<Tag, ListTagRequest>(
        interface: this,
        seed: ListTagRequest(),
      );
}

// Users
extension UsersQuerySeed on UsersInterface {
  ListQueryBuilder<User, ListUserRequest> get query =>
      listQuery<User, ListUserRequest>(
        interface: this,
        seed: ListUserRequest(),
      );
}

// Search
extension SearchQuerySeed on SearchInterface {
  ListQueryBuilder<Search, ListSearchRequest> get query =>
      listQuery<Search, ListSearchRequest>(
        interface: this,
        seed: ListSearchRequest(),
      );
}

// Blocks
extension BlocksQuerySeed on BlocksInterface {
  ListQueryBuilder<Block, ListBlockRequest> get query =>
      listQuery<Block, ListBlockRequest>(
        interface: this,
        seed: ListBlockRequest(),
      );
}

// Block Types
extension BlockTypesQuerySeed on BlockTypesInterface {
  ListQueryBuilder<BlockType, ListBlockTypeRequest> get query =>
      listQuery<BlockType, ListBlockTypeRequest>(
        interface: this,
        seed: ListBlockTypeRequest(),
      );
}

// Block Directory Items
extension BlockDirectoryQuerySeed on BlockDirectoryInterface {
  ListQueryBuilder<BlockDirectoryItem, ListBlockDirectoryItemsRequest>
      get query =>
          listQuery<BlockDirectoryItem, ListBlockDirectoryItemsRequest>(
            interface: this,
            seed: ListBlockDirectoryItemsRequest(term: ''),
          );
}

// Pattern Directory Items
extension PatternDirectoryQuerySeed on PatternDirectoryInterface {
  ListQueryBuilder<PatternDirectoryItem, ListPatternDirectoryItemsRequest>
      get query =>
          listQuery<PatternDirectoryItem, ListPatternDirectoryItemsRequest>(
            interface: this,
            seed: ListPatternDirectoryItemsRequest(),
          );
}

// Menus
extension MenusQuerySeed on MenusInterface {
  ListQueryBuilder<NavMenu, ListNavMenuRequest> get query =>
      listQuery<NavMenu, ListNavMenuRequest>(
        interface: this,
        seed: ListNavMenuRequest(),
      );
}

// Menu Items
extension MenuItemsQuerySeed on MenuItemsInterface {
  ListQueryBuilder<NavMenuItem, ListNavMenuItemRequest> get query =>
      listQuery<NavMenuItem, ListNavMenuItemRequest>(
        interface: this,
        seed: ListNavMenuItemRequest(),
      );
}

// Menu Locations
extension MenuLocationsQuerySeed on MenuLocationsInterface {
  ListQueryBuilder<MenuLocation, ListMenuLocationRequest> get query =>
      listQuery<MenuLocation, ListMenuLocationRequest>(
        interface: this,
        seed: ListMenuLocationRequest(),
      );
}

// Widgets
extension WidgetsQuerySeed on WidgetsInterface {
  ListQueryBuilder<Widget, ListWidgetsRequest> get query =>
      listQuery<Widget, ListWidgetsRequest>(
        interface: this,
        seed: ListWidgetsRequest(),
      );
}

// Sidebars
extension SidebarsQuerySeed on SidebarsInterface {
  ListQueryBuilder<Sidebar, ListSidebarsRequest> get query =>
      listQuery<Sidebar, ListSidebarsRequest>(
        interface: this,
        seed: ListSidebarsRequest(),
      );
}

// Widget Types
extension WidgetTypesQuerySeed on WidgetTypesInterface {
  ListQueryBuilder<WidgetType, ListWidgetTypesRequest> get query =>
      listQuery<WidgetType, ListWidgetTypesRequest>(
        interface: this,
        seed: ListWidgetTypesRequest(),
      );
}

// Types
extension TypesQuerySeed on TypesInterface {
  ListQueryBuilder<PostType, ListTypeRequest> get query =>
      listQuery<PostType, ListTypeRequest>(
        interface: this,
        seed: ListTypeRequest(),
      );
}

// Statuses
extension StatusesQuerySeed on StatusesInterface {
  ListQueryBuilder<PostStatus, ListStatusRequest> get query =>
      listQuery<PostStatus, ListStatusRequest>(
        interface: this,
        seed: ListStatusRequest(),
      );
}

// Themes
extension ThemesQuerySeed on ThemesInterface {
  ListQueryBuilder<Theme, ListThemeRequest> get query =>
      listQuery<Theme, ListThemeRequest>(
        interface: this,
        seed: ListThemeRequest(),
      );
}

// Taxonomies
extension TaxonomiesQuerySeed on TaxonomiesInterface {
  ListQueryBuilder<Taxonomy, ListTaxonomyRequest> get query =>
      listQuery<Taxonomy, ListTaxonomyRequest>(
        interface: this,
        seed: ListTaxonomyRequest(),
      );
}

// Templates
extension TemplatesQuerySeed on TemplatesInterface {
  ListQueryBuilder<Template, ListTemplatesRequest> get query =>
      listQuery<Template, ListTemplatesRequest>(
        interface: this,
        seed: ListTemplatesRequest(),
      );
}

// Template Parts
extension TemplatePartsQuerySeed on TemplatePartsInterface {
  ListQueryBuilder<TemplatePart, ListTemplatePartsRequest> get query =>
      listQuery<TemplatePart, ListTemplatePartsRequest>(
        interface: this,
        seed: ListTemplatePartsRequest(),
      );
}

// Post Revisions
extension PostRevisionsQuerySeed on PostRevisionsInterface {
  ListQueryBuilder<Revision, ListPostRevisionsRequest> get query =>
      listQuery<Revision, ListPostRevisionsRequest>(
        interface: this,
        seed: ListPostRevisionsRequest(postId: 0),
      );
}

// Page Revisions
extension PageRevisionsQuerySeed on PageRevisionsInterface {
  ListQueryBuilder<Revision, ListPageRevisionsRequest> get query =>
      listQuery<Revision, ListPageRevisionsRequest>(
        interface: this,
        seed: ListPageRevisionsRequest(pageId: 0),
      );
}

// Navigations
extension NavigationsQuerySeed on NavigationsInterface {
  ListQueryBuilder<Navigation, ListNavigationsRequest> get query =>
      listQuery<Navigation, ListNavigationsRequest>(
        interface: this,
        seed: ListNavigationsRequest(),
      );
}

// Navigation Revisions
extension NavigationRevisionsQuerySeed on NavigationRevisionsInterface {
  ListQueryBuilder<Revision, ListNavigationRevisionsRequest> get query =>
      listQuery<Revision, ListNavigationRevisionsRequest>(
        interface: this,
        seed: ListNavigationRevisionsRequest(parent: 0),
      );
}

// Navigation Autosaves
extension NavigationAutosavesQuerySeed on NavigationAutosavesInterface {
  ListQueryBuilder<Revision, ListNavigationAutosavesRequest> get query =>
      listQuery<Revision, ListNavigationAutosavesRequest>(
        interface: this,
        seed: ListNavigationAutosavesRequest(parent: 0),
      );
}

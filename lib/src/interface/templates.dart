import '../../wordpress_client.dart';

/// Interface for Templates (/wp/v2/templates)
final class TemplatesInterface extends IRequestInterface
    with
        ListOperation<Template, ListTemplatesRequest>,
        RetrieveOperation<Template, RetrieveTemplateRequest>,
        CreateOperation<Template, CreateTemplateRequest>,
        UpdateOperation<Template, UpdateTemplateRequest>,
        DeleteOperation<DeleteTemplateRequest> {}

/// Interface for Template Parts (/wp/v2/template-parts)
final class TemplatePartsInterface extends IRequestInterface
    with
        ListOperation<TemplatePart, ListTemplatePartsRequest>,
        RetrieveOperation<TemplatePart, RetrieveTemplatePartRequest>,
        CreateOperation<TemplatePart, CreateTemplatePartRequest>,
        UpdateOperation<TemplatePart, UpdateTemplatePartRequest>,
        DeleteOperation<DeleteTemplatePartRequest> {}

/// Interface for Template Revisions (/wp/v2/templates/{parent}/revisions)
final class TemplateRevisionsInterface extends IRequestInterface
    with
        ListOperation<Revision, ListTemplateRevisionsRequest>,
        RetrieveOperation<Revision, RetrieveTemplateRevisionRequest>,
        DeleteOperation<DeleteTemplateRevisionRequest> {}

/// Interface for Template Part Revisions (/wp/v2/template-parts/{parent}/revisions)
final class TemplatePartRevisionsInterface extends IRequestInterface
    with
        ListOperation<Revision, ListTemplatePartRevisionsRequest>,
        RetrieveOperation<Revision, RetrieveTemplatePartRevisionRequest>,
        DeleteOperation<DeleteTemplatePartRevisionRequest> {}

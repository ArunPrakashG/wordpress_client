# wordpress_client Flutter example

Lists the latest posts of a site, pull to refresh, and creates drafts. A draft
made while the device is offline is kept by `OfflineWriteQueue` and sent when
you tap the sync button.

```bash
cd example/flutter_app
flutter create .   # generates the platform folders once
flutter run
```

Reading works with any public site (edit `_site` in `lib/main.dart`). To create
drafts, add an application password with
`withDefaultAuthorization(WordpressAuth.appPassword(user: ..., appPassword: ...))`
in the client's bootstrapper.

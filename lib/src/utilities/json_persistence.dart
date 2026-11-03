import 'dart:async';
import 'dart:convert';

/// Reads the saved text, or null when nothing was saved yet.
typedef PersistRead = Future<String?> Function();

/// Saves [contents], replacing what was saved before.
typedef PersistWrite = Future<void> Function(String contents);

/// Loads a JSON document through [read] and saves it through [write], one
/// save at a time so a slow write never lands after a newer one.
final class JsonPersistence {
  JsonPersistence({required this.read, required this.write});

  final PersistRead read;
  final PersistWrite write;

  Future<void> _saving = Future.value();

  /// The saved document, or null when there is none or it is not valid JSON.
  Future<Object?> load() async {
    final text = await read();
    if (text == null || text.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  /// Saves [document] after any save still in flight.
  Future<void> save(Object? document) {
    final text = jsonEncode(document);

    return _saving = _saving.catchError((Object _) {}).then((_) => write(text));
  }
}

// ignore_for_file: avoid_print, require_trailing_commas

// Dart script: quick consistency checks for request classes.
// Usage: dart run tool/check_requests_consistency.dart
// - Flags IRequest build() implementations that don't forward queryParameters
//   when the class accepts them.
// - Flags public fields lacking a preceding /// doc in request classes.
// This is heuristic (regex-based); please review findings manually.

import 'dart:io';

final requestsDir = Directory('lib/src/requests');

void main(List<String> args) {
  final files = requestsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      // Focus field-doc checks on create/ and update/ requests only to reduce noise.
      .where(
        (f) =>
            f.path.contains(
              '${Platform.pathSeparator}create${Platform.pathSeparator}',
            ) ||
            f.path.contains(
              '${Platform.pathSeparator}update${Platform.pathSeparator}',
            ) ||
            // Still include all for query forwarding check
            true,
      )
      .toList();

  final missingQueryForward = <String>[];
  final missingFieldDocs = <String>[];

  for (final file in files) {
    final text = file.readAsStringSync();

    final hasQueryParamCtor = RegExp(r'super\.queryParameters').hasMatch(text);
    final forwardsQuery =
        RegExp(r'addAllIfNotNull\((this\.)?queryParameters\)').hasMatch(text) ||
            RegExp(r'queryParameters:\s*query').hasMatch(text) ||
            RegExp(r'queryParameters:\s*qp').hasMatch(text) ||
            RegExp(r'queryParameters:\s*queryParameters,').hasMatch(text);

    if (hasQueryParamCtor && !forwardsQuery) {
      missingQueryForward.add(file.path);
    }

    // Heuristic: for classes ending with Request, detect public fields without /// above.
    final classMatch = RegExp(
      r'class\s+([A-Za-z0-9_]+Request)\s+extends\s+IRequest[^\{]*\{([\s\S]*?)\n\s*@override\s+WordpressRequest\s+build',
      multiLine: true,
    ).firstMatch(text);
    if (classMatch != null &&
        (file.path.contains(
                '${Platform.pathSeparator}create${Platform.pathSeparator}') ||
            file.path.contains(
                '${Platform.pathSeparator}update${Platform.pathSeparator}'))) {
      final body = classMatch.group(2)!;
      final fieldRegex = RegExp(
        r'\n\s*(final\s+)?[A-Za-z0-9_<>?]+\s+[a-zA-Z_][a-zA-Z0-9_]*\s*;',
      );
      for (final m in fieldRegex.allMatches(body)) {
        final fieldLineStart = m.start;
        final before = body.substring(0, fieldLineStart);
        final lines = before.split('\n');
        final prev = lines.isNotEmpty ? lines.last.trimRight() : '';
        if (!prev.trimLeft().startsWith('///')) {
          // Allow private fields or late initializers to pass; skip if starts with _
          final fieldDecl = m.group(0)!;
          if (!RegExp(r'\s+_[a-zA-Z]').hasMatch(fieldDecl)) {
            missingFieldDocs.add('${file.path}:${fieldDecl.trim()}');
          }
        }
      }
    }
  }

  if (missingQueryForward.isEmpty && missingFieldDocs.isEmpty) {
    print('All checks passed.');
    return;
  }

  if (missingQueryForward.isNotEmpty) {
    print('Requests missing queryParameters forwarding:');
    for (final p in missingQueryForward) {
      print('  - $p');
    }
  }

  if (missingFieldDocs.isNotEmpty) {
    print('\nPublic fields lacking docs (heuristic):');
    for (final entry in missingFieldDocs) {
      print('  - $entry');
    }
  }

  // Non-zero exit to highlight in CI if desired
  exitCode = 1;
}

// ignore_for_file: avoid_print

// Prints the CHANGELOG.md section of one version (without its heading).
// Usage: dart run tool/changelog_section.dart 10.1.0

import 'dart:io';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: changelog_section.dart <version>');
    exit(64);
  }

  final lines = File('CHANGELOG.md').readAsLinesSync();
  final start = lines.indexWhere((l) => l.trim() == '## ${args.single}');
  if (start < 0) {
    stderr.writeln('No "## ${args.single}" section in CHANGELOG.md');
    exit(1);
  }

  final rest = lines.skip(start + 1);
  final section = rest.takeWhile((l) => !l.startsWith('## ')).join('\n');
  print(section.trim());
}

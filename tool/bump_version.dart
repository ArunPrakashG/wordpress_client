// A simple script to bump the version in pubspec.yaml.
// Usage:
//   dart run tool/bump_version.dart [patch|minor|major|<explicit-version>]
// Prints the new version to stdout.

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/bump_version.dart [patch|minor|major|<explicit-version>]',
    );
    exit(64); // usage error
  }

  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    stderr.writeln('pubspec.yaml not found in current directory');
    exit(66); // cannot open input
  }

  final content = file.readAsStringSync();

  final versionRegex = RegExp(r'^version:\s*([^\s#]+)', multiLine: true);
  final match = versionRegex.firstMatch(content);
  if (match == null) {
    stderr.writeln('Could not find version in pubspec.yaml');
    exit(65);
  }

  final currentVersion = match.group(1)!;
  final arg = args.first.trim();
  final newVersion = _computeNextVersion(currentVersion, arg);

  final updated = content.replaceFirst(versionRegex, 'version: $newVersion');
  if (updated == content) {
    // No change, but still print newVersion for consistency
    stdout.writeln(newVersion);
    return;
  }

  file.writeAsStringSync(updated);
  stdout.writeln(newVersion);
}

String _computeNextVersion(String current, String bump) {
  // Accept explicit version if it looks like semver starting with digits.
  final explicit = RegExp(r'^\d+\.\d+\.\d+(?:[+\-].+)?$');
  if (explicit.hasMatch(bump)) {
    return bump;
  }

  // Strip pre-release/build metadata for calculation
  final main = current.split(RegExp(r'[+\-]')).first;
  final parts = main.split('.');
  if (parts.length != 3) {
    throw FormatException('Unsupported version format: $current');
  }
  var major = int.tryParse(parts[0]) ??
      (throw FormatException('Invalid major in $current'));
  var minor = int.tryParse(parts[1]) ??
      (throw FormatException('Invalid minor in $current'));
  var patch = int.tryParse(parts[2]) ??
      (throw FormatException('Invalid patch in $current'));

  switch (bump.toLowerCase()) {
    case 'major':
      major += 1;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor += 1;
      patch = 0;
      break;
    case 'patch':
      patch += 1;
      break;
    default:
      throw FormatException('Unknown bump type: $bump');
  }

  return '$major.$minor.$patch';
}

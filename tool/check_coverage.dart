// ignore_for_file: avoid_print

// Fails when line coverage in an lcov file is below a threshold.
// Usage: dart run tool/check_coverage.dart coverage/lcov.info 60

import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: check_coverage.dart <lcov.info> <min-percent>');
    exit(64);
  }

  final minPercent = double.parse(args[1]);
  var found = 0;
  var hit = 0;

  for (final line in File(args[0]).readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      found += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit += int.parse(line.substring(3));
    }
  }

  final percent = found == 0 ? 0.0 : hit * 100 / found;
  print('Line coverage: ${percent.toStringAsFixed(1)}% ($hit/$found), '
      'floor: $minPercent%');

  if (percent < minPercent) {
    exit(1);
  }
}

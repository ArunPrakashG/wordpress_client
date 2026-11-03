// ignore_for_file: avoid_print

// Generates Dart models from the REST schema of WordPress routes.
//
//   dart run wordpress_client:generate --site https://example.com \
//     --route wp/v2/books --route my-plugin/v1/events --out lib/models.dart
//
// Run with --help for every option.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wordpress_client/src/codegen/model_generator.dart';

const _usage = '''
Generates Dart models from the REST schema of WordPress routes.

Usage:
  dart run wordpress_client:generate --site <url> --route <route> [options]
  dart run wordpress_client:generate --schema <file.json> [options]

Options:
  --site <url>        Site URL (https://example.com) or REST root (.../wp-json).
  --route <route>     Route to read, e.g. wp/v2/books. Repeat for several.
  --schema <file>     Read a saved OPTIONS answer or schema instead of a site.
  --name <Class>      Class name (only with a single route or schema). Default:
                      the schema title, e.g. "book" gives Book.
  --out <file>        Write to this file instead of standard output.
  --user <name>       User for routes that need authentication, with
  --app-password <p>  an application password. WP_USERNAME and
                      WP_APP_PASSWORD are read from the environment too.
  --help              Show this help.

Use the result with client.resource<Book>('books', decoder: Book.fromJson).
''';

Future<void> main(List<String> arguments) async {
  final Map<String, List<String>> options;
  try {
    options = _parse(arguments);
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..write(_usage);
    exit(64);
  }

  if (options.containsKey('help')) {
    stdout.write(_usage);
    return;
  }

  final routes = options['route'] ?? const [];
  final schemas = options['schema'] ?? const [];
  final site = options['site']?.last;
  final names = options['name'] ?? const [];

  if ((site == null) == schemas.isEmpty || (site != null && routes.isEmpty)) {
    stderr
      ..writeln('Pass either --site with at least one --route, or --schema.')
      ..writeln()
      ..write(_usage);
    exit(64);
  }

  if (names.isNotEmpty && routes.length + schemas.length != 1) {
    stderr.writeln('--name only works with a single route or schema.');
    exit(64);
  }

  final models = <ModelSource>[];
  final env = Platform.environment;

  for (final path in schemas) {
    final json = jsonDecode(File(path).readAsStringSync());
    models.add(_model(json, names.firstOrNull, path));
  }

  if (site != null) {
    final root = _restRoot(Uri.parse(site));
    final user = options['user']?.last ?? env['WP_USERNAME'];
    final password = options['app-password']?.last ?? env['WP_APP_PASSWORD'];
    final dio = Dio(
      BaseOptions(
        headers: {
          if (user != null && password != null)
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$user:$password'))}',
        },
      ),
    );

    try {
      for (final route in routes) {
        final url = root.replace(
          pathSegments: [
            ...root.pathSegments.where((s) => s.isNotEmpty),
            ...route.split('/').where((s) => s.isNotEmpty),
          ],
        );
        final response = await dio.requestUri<Object?>(
          url,
          options: Options(method: 'OPTIONS'),
        );
        models.add(_model(response.data, names.firstOrNull, route));
      }
    } on DioException catch (e) {
      stderr.writeln(
        'Could not read the schema: ${e.response?.statusCode ?? ''} '
        '${e.message ?? e.error}',
      );
      exit(1);
    } finally {
      dio.close();
    }
  }

  final source = generateModels(
    models,
    origin: site ?? schemas.join(', '),
  );

  final out = options['out']?.last;
  if (out == null) {
    stdout.write(source);
    return;
  }

  File(out)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(source);
  stderr.writeln(
    'Wrote ${models.map((m) => m.className).join(', ')} to $out',
  );
}

ModelSource _model(Object? json, String? name, String route) {
  final map = json is Map ? json.cast<String, dynamic>() : null;
  final schema = map?['schema'] is Map
      ? (map!['schema'] as Map).cast<String, dynamic>()
      : map;

  if (schema == null || schema['properties'] is! Map) {
    stderr.writeln('$route has no schema with properties.');
    exit(1);
  }

  return ModelSource(
    className: name ?? classNameFor('${schema['title'] ?? route}'),
    schema: schema,
    route: route,
  );
}

Uri _restRoot(Uri site) {
  final segments = site.pathSegments.where((s) => s.isNotEmpty).toList();
  final marker = segments.indexOf('wp-json');

  return site.replace(
    pathSegments:
        marker < 0 ? [...segments, 'wp-json'] : segments.sublist(0, marker + 1),
  );
}

Map<String, List<String>> _parse(List<String> arguments) {
  const flags = {'help'};
  const valued = {
    'site',
    'route',
    'schema',
    'name',
    'out',
    'user',
    'app-password',
  };
  final options = <String, List<String>>{};

  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    if (!argument.startsWith('--')) {
      throw FormatException('Unexpected argument: $argument');
    }

    var key = argument.substring(2);
    String? value;
    final equals = key.indexOf('=');
    if (equals >= 0) {
      value = key.substring(equals + 1);
      key = key.substring(0, equals);
    }

    if (key == 'h' || flags.contains(key)) {
      options['help'] = const [];
      continue;
    }
    if (!valued.contains(key)) {
      throw FormatException('Unknown option: --$key');
    }

    value ??= i + 1 < arguments.length ? arguments[++i] : null;
    if (value == null) {
      throw FormatException('--$key needs a value.');
    }
    (options[key] ??= []).add(value);
  }

  return options;
}

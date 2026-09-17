import 'dart:convert';

import '../analysis/criteria.dart';

const _metricNames = {
  'count',
  'minimum',
  'maximum',
  'mean',
  'rms',
  'peakPoint',
  'peakToPeak',
  'endDelta',
};

List<Criterion> parseCriteriaIni(String source) {
  final sections = <String, Map<String, String>>{};
  Map<String, String>? current;

  final sectionPattern = RegExp(
    r'^\[(metric\.[A-Za-z][A-Za-z0-9]*|point\.[1-9][0-9]*)\]$',
  );

  final lines = const LineSplitter().convert(source);

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    final lineNumber = index + 1;

    if (line.isEmpty || line.startsWith(';') || line.startsWith('#')) {
      continue;
    }

    final sectionMatch = sectionPattern.firstMatch(line);

    if (sectionMatch != null) {
      final name = sectionMatch.group(1)!;

      if (sections.containsKey(name)) {
        throw FormatException('Line $lineNumber: duplicate section [$name].');
      }

      current = <String, String>{};
      sections[name] = current;
      continue;
    }

    final parts = line.split('=');
    final key = parts.first.trim();

    if (current == null ||
        parts.length != 2 ||
        (key != 'lower' && key != 'upper')) {
      throw FormatException(
        'Line $lineNumber: expected a section or lower/upper assignment.',
      );
    }

    if (current.containsKey(key)) {
      throw FormatException('Line $lineNumber: duplicate key "$key".');
    }

    current[key] = parts[1].trim();
  }

  if (sections.isEmpty) {
    throw FormatException('The criteria file must contain at least one rule.');
  }

  final criteria = <Criterion>[];

  for (final entry in sections.entries) {
    final parts = entry.key.split('.');
    final kind = parts[0];
    final target = parts[1];

    final metric = kind == 'metric' ? target : null;
    final point = kind == 'point' ? int.tryParse(target) : null;

    if (metric != null && !_metricNames.contains(metric)) {
      throw FormatException('Unknown metric "$metric".');
    }

    if (kind == 'point' && point == null) {
      throw FormatException('Invalid point number in [${entry.key}].');
    }

    final lower = double.tryParse(entry.value['lower'] ?? '');
    final upper = double.tryParse(entry.value['upper'] ?? '');

    if (lower == null || upper == null) {
      throw FormatException(
        '[${entry.key}] requires numeric lower and upper bounds.',
      );
    }

    try {
      criteria.add(
        Criterion(metric: metric, point: point, lower: lower, upper: upper),
      );
    } on ArgumentError catch (error) {
      throw FormatException('[${entry.key}]: ${error.message}');
    }
  }

  return List<Criterion>.unmodifiable(criteria);
}

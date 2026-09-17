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
  final sections = _readSections(source);
  final criteria = <Criterion>[];

  for (final section in sections.entries) {
    final name = section.key;
    final fields = section.value;

    double? number(String key, {bool integer = false}) {
      return _number(fields[key], '[$name] $key', integer: integer);
    }

    void add({
      String? metric,
      int? point,
      double? lower,
      double? upper,
      bool upperInclusive = true,
      double tolerance = 0,
      String? label,
    }) {
      if (lower == null && upper == null) {
        return;
      }

      try {
        criteria.add(
          Criterion(
            metric: metric,
            point: point,
            lower: lower,
            upper: upper,
            upperInclusive: upperInclusive,
            tolerance: tolerance,
            label: label,
          ),
        );
      } on ArgumentError catch (error) {
        throw FormatException('[$name]: ${error.message}');
      }
    }

    if (name == 'pico') {
      _checkKeys(name, fields, const {
        'altura_minima',
        'altura_maxima',
        'ponto_minimo',
        'ponto_maximo',
      });

      add(
        metric: 'maximum',
        lower: number('altura_minima'),
        upper: number('altura_maxima'),
        label: 'Altura do pico',
      );

      add(
        metric: 'peakPoint',
        lower: number('ponto_minimo', integer: true),
        upper: number('ponto_maximo', integer: true),
        label: 'Ponto do pico',
      );
    } else if (name == 'extremos') {
      _checkKeys(name, fields, const {'inicio_abaixo_de', 'fim_abaixo_de'});

      add(
        metric: 'first',
        upper: number('inicio_abaixo_de'),
        upperInclusive: false,
        label: 'Início do sinal',
      );

      add(
        metric: 'last',
        upper: number('fim_abaixo_de'),
        upperInclusive: false,
        label: 'Fim do sinal',
      );
    } else if (name == 'forma') {
      _checkKeys(name, fields, const {
        'permitir_permanencia',
        'permitir_queda_antes_pico',
        'permitir_subida_depois_pico',
        'tolerancia',
      });

      final tolerance = number('tolerancia') ?? 0;

      if (tolerance < 0) {
        throw FormatException('[forma] tolerancia deve ser não negativa.');
      }

      const rules = {
        'permitir_permanencia': 'flatSegments',
        'permitir_queda_antes_pico': 'dropsBeforePeak',
        'permitir_subida_depois_pico': 'risesAfterPeak',
      };

      for (final rule in rules.entries) {
        final allowed = _boolean(fields[rule.key], '[forma] ${rule.key}');

        if (allowed == null) {
          continue;
        }

        add(
          metric: rule.value,
          lower: 0,
          upper: allowed ? null : 0,
          tolerance: tolerance,
        );
      }
    } else {
      String? metric;
      int? point;

      if (name.startsWith('metric.')) {
        metric = name.substring('metric.'.length);

        if (!_metricNames.contains(metric)) {
          throw FormatException('Métrica desconhecida: "$metric".');
        }
      } else {
        final match = RegExp(r'^point\.([1-9][0-9]*)$').firstMatch(name);
        point = match == null ? null : int.tryParse(match.group(1)!);

        if (point == null) {
          throw FormatException('Seção inválida ou desconhecida: [$name].');
        }
      }

      _checkKeys(name, fields, const {'lower', 'upper'});

      if (!fields.containsKey('lower') || !fields.containsKey('upper')) {
        throw FormatException(
          '[$name] exige lower e upper; use null para desativar um limite.',
        );
      }

      add(
        metric: metric,
        point: point,
        lower: number('lower'),
        upper: number('upper'),
      );
    }
  }

  return List<Criterion>.unmodifiable(criteria);
}

Map<String, Map<String, String>> _readSections(String source) {
  final sections = <String, Map<String, String>>{};
  Map<String, String>? current;

  final sectionPattern = RegExp(r'^\[([A-Za-z][A-Za-z0-9_.]*)\]$');
  final lines = const LineSplitter().convert(source);

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    final lineNumber = index + 1;

    if (line.isEmpty || line.startsWith(';') || line.startsWith('#')) {
      continue;
    }

    final match = sectionPattern.firstMatch(line);

    if (match != null) {
      final name = match.group(1)!;

      if (sections.containsKey(name)) {
        throw FormatException('Linha $lineNumber: seção duplicada [$name].');
      }

      current = <String, String>{};
      sections[name] = current;
      continue;
    }

    final parts = line.split('=');
    final key = parts.first.trim();

    if (current == null || parts.length != 2 || key.isEmpty) {
      throw FormatException(
        'Linha $lineNumber: esperava uma seção ou chave = valor.',
      );
    }

    if (current.containsKey(key)) {
      throw FormatException('Linha $lineNumber: chave duplicada "$key".');
    }

    current[key] = parts[1].trim();
  }

  if (sections.isEmpty) {
    throw FormatException('O arquivo INI deve conter ao menos uma seção.');
  }

  return sections;
}

void _checkKeys(
  String section,
  Map<String, String> fields,
  Set<String> allowed,
) {
  for (final key in fields.keys) {
    if (!allowed.contains(key)) {
      throw FormatException('[$section]: chave desconhecida "$key".');
    }
  }
}

double? _number(String? raw, String label, {bool integer = false}) {
  if (raw == null || raw == 'null') {
    return null;
  }

  if (integer) {
    final value = int.tryParse(raw);

    if (value == null || value < 1) {
      throw FormatException('$label deve ser um inteiro positivo ou null.');
    }

    return value.toDouble();
  }

  final value = double.tryParse(raw);

  if (value == null || !value.isFinite) {
    throw FormatException('$label deve ser um número finito ou null.');
  }

  return value;
}

bool? _boolean(String? raw, String label) {
  if (raw == null || raw == 'null') {
    return null;
  }

  if (raw == 'true') {
    return true;
  }

  if (raw == 'false') {
    return false;
  }

  throw FormatException('$label deve ser true, false ou null.');
}

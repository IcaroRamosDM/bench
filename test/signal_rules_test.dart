import 'dart:io';

import 'package:bench/bench.dart';
import 'package:test/test.dart';

CriteriaEvaluation evaluate(List<double> values, String ini) {
  return evaluateCriteria(values, parseCriteriaIni(ini));
}

void main() {
  const approvedValues = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

  const rejectedValues = <double>[12, 9, 2700, 2500, 2600, 2600, 1500, 500, 12];

  const profile = '''
[pico]
altura_minima = 2000
altura_maxima = 2600
ponto_minimo = 4
ponto_maximo = 6

[extremos]
inicio_abaixo_de = 10
fim_abaixo_de = 10

[forma]
permitir_permanencia = false
permitir_queda_antes_pico = false
permitir_subida_depois_pico = false
tolerancia = 0
''';

  test('approves the reference signal', () {
    final result = evaluate(approvedValues, profile);

    expect(result.status, EvaluationStatus.approved);
    expect(result.failureReasons, isEmpty);
  });

  test('reports every failure in the rejected example', () {
    final result = evaluate(rejectedValues, profile);
    final reasons = result.failureReasons.join('\n');

    expect(result.status, EvaluationStatus.rejected);
    expect(result.failureReasons, hasLength(7));
    expect(reasons, contains('Altura do pico'));
    expect(reasons, contains('Ponto do pico: valor 3'));
    expect(reasons, contains('Início do sinal'));
    expect(reasons, contains('Fim do sinal'));
    expect(reasons, contains('Permanência entre os pontos 5 e 6'));
    expect(reasons, contains('Queda antes do pico entre os pontos 1 e 2'));
    expect(reasons, contains('Subida depois do pico entre os pontos 4 e 5'));
  });

  test('supports independent inclusive height bounds', () {
    expect(
      evaluate([
        0,
        10,
        0,
      ], '[pico]\naltura_minima=10\naltura_maxima=null').status,
      EvaluationStatus.approved,
    );

    expect(
      evaluate([0, 9, 0], '[pico]\naltura_minima=10').status,
      EvaluationStatus.rejected,
    );

    expect(
      evaluate([
        0,
        10,
        0,
      ], '[pico]\naltura_minima=null\naltura_maxima=10').status,
      EvaluationStatus.approved,
    );

    expect(
      evaluate([0, 11, 0], '[pico]\naltura_maxima=10').status,
      EvaluationStatus.rejected,
    );
  });

  test('uses the largest value rather than the largest magnitude', () {
    expect(
      evaluate([
        -8,
        -2,
        -4,
      ], '[pico]\naltura_minima=-2\naltura_maxima=-2').status,
      EvaluationStatus.approved,
    );
  });

  test('checks all tied peaks with either position bound disabled', () {
    const values = <double>[0, 10, 8, 10, 0];

    expect(
      evaluate(values, '[pico]\nponto_minimo=2\nponto_maximo=4').status,
      EvaluationStatus.approved,
    );

    expect(
      evaluate(values, '[pico]\nponto_minimo=3\nponto_maximo=null').status,
      EvaluationStatus.rejected,
    );

    expect(
      evaluate(values, '[pico]\nponto_minimo=null\nponto_maximo=3').status,
      EvaluationStatus.rejected,
    );
  });

  test('uses strict limits for the first and last values', () {
    const ini = '[extremos]\ninicio_abaixo_de=1\nfim_abaixo_de=1';

    expect(evaluate([0, 10, 0], ini).status, EvaluationStatus.approved);
    expect(evaluate([1, 10, 0], ini).status, EvaluationStatus.rejected);
    expect(evaluate([0, 10, 1], ini).status, EvaluationStatus.rejected);
  });

  test('reports no criteria when every rule is disabled', () {
    const ini = '''
[pico]
altura_minima=null
altura_maxima=null
ponto_minimo=null
ponto_maximo=null
[extremos]
inicio_abaixo_de=null
fim_abaixo_de=null
[forma]
permitir_permanencia=null
permitir_queda_antes_pico=null
permitir_subida_depois_pico=null
tolerancia=0
''';

    final result = evaluate(rejectedValues, ini);

    expect(result.status, EvaluationStatus.noCriteria);
    expect(result.results, isEmpty);

    expect(
      renderHtmlReport(rejectedValues, criteria: parseCriteriaIni(ini)),
      contains('>SEM CRITÉRIOS</p>'),
    );
  });

  test('true permits shape events', () {
    const ini = '''
[forma]
permitir_permanencia=true
permitir_queda_antes_pico=true
permitir_subida_depois_pico=true
''';

    expect(evaluate(rejectedValues, ini).status, EvaluationStatus.approved);
  });

  test('checks permanence across the entire signal', () {
    final result = evaluate([
      0,
      0,
      10,
      0,
      0,
    ], '[forma]\npermitir_permanencia=false');

    expect(result.status, EvaluationStatus.rejected);
    expect(result.failureReasons, hasLength(2));
  });

  test('detects a valley between equal maxima', () {
    final result = evaluate(
      [0, 10, 8, 10, 0],
      '''
[forma]
permitir_queda_antes_pico=false
permitir_subida_depois_pico=false
''',
    );

    expect(result.status, EvaluationStatus.rejected);
    expect(result.failureReasons, hasLength(2));
    expect(result.failureReasons[0], contains('pontos 2 e 3'));
    expect(result.failureReasons[1], contains('pontos 3 e 4'));
  });

  test('includes the tolerance boundary in permanence', () {
    const ini = '[forma]\npermitir_permanencia=false\ntolerancia=0.5';

    expect(evaluate([0, 0.5, 10, 0], ini).status, EvaluationStatus.rejected);

    expect(
      evaluate([0, 0.5, 10, 0], ini.replaceFirst('0.5', '0')).status,
      EvaluationStatus.approved,
    );
  });

  test('ignores small drops and rises within tolerance', () {
    const values = <double>[0, 4, 3.5, 10, 6, 6.5, 0];
    const ini = '''
[forma]
permitir_queda_antes_pico=false
permitir_subida_depois_pico=false
tolerancia=0.5
''';

    expect(evaluate(values, ini).status, EvaluationStatus.approved);

    expect(
      evaluate(values, ini.replaceFirst('0.5', '0')).status,
      EvaluationStatus.rejected,
    );
  });

  test('does not apply shape tolerance to height limits', () {
    expect(
      evaluate([
        0,
        9.5,
        0,
      ], '[pico]\naltura_minima=10\n[forma]\ntolerancia=1').status,
      EvaluationStatus.rejected,
    );
  });

  test('a single point has no adjacent shape events', () {
    expect(
      evaluate(
        [10],
        '''
[pico]
ponto_minimo=1
ponto_maximo=1
[forma]
permitir_permanencia=false
permitir_queda_antes_pico=false
permitir_subida_depois_pico=false
''',
      ).status,
      EvaluationStatus.approved,
    );
  });

  test('supports null in legacy point bounds', () {
    expect(
      evaluate([0, 10, 0], '[point.2]\nlower=10\nupper=null').status,
      EvaluationStatus.approved,
    );

    expect(
      evaluate([0, 10, 0], '[point.2]\nlower=null\nupper=null').status,
      EvaluationStatus.noCriteria,
    );
  });

  test('rejects invalid configuration', () {
    final invalidSources = [
      '[unknown]\naltura_minima=1',
      '[pico]\nalturra_minima=1',
      '[pico]\naltura_minima=1\naltura_minima=2',
      '[pico]\naltura_minima=1\n[pico]\naltura_maxima=2',
      '[pico]\naltura_minima=2\naltura_maxima=1',
      '[pico]\nponto_minimo=5\nponto_maximo=3',
      '[pico]\nponto_minimo=0',
      '[pico]\nponto_minimo=2.5',
      '[pico]\naltura_minima=NaN',
      '[pico]\naltura_maxima=Infinity',
      '[pico]\naltura_minima="null"',
      '[forma]\npermitir_permanencia=yes',
      '[forma]\npermitir_permanencia=',
      '[forma]\ntolerancia=-1',
      '[forma]\ntolerancia=Infinity',
    ];

    for (final ini in invalidSources) {
      expect(() => parseCriteriaIni(ini), throwsFormatException, reason: ini);
    }
  });

  test(
    'CLI renders friendly INI failures while preserving the report',
    () async {
      final directory = await Directory.systemTemp.createTemp('bench_rules_');

      addTearDown(() async {
        await directory.delete(recursive: true);
      });

      final signal = File('${directory.path}/signal.json');
      final config = File('${directory.path}/criteria.ini');

      await signal.writeAsString(
        '{"values":[12,9,2700,2500,2600,2600,1500,500,12]}',
      );
      await config.writeAsString(profile);

      final result = await Process.run(Platform.resolvedExecutable, [
        'run',
        'bin/bench.dart',
        '--html',
        '--criteria',
        config.path,
        signal.path,
      ]);

      expect(result.exitCode, 0);
      expect(result.stderr, isEmpty);
      expect(result.stdout, contains('>REPROVADO</p>'));
      expect(result.stdout, contains('<svg'));
      expect(result.stdout, contains('<h2>Statistics</h2>'));
      expect(result.stdout, contains('Altura do pico'));
      expect(result.stdout, contains('Permanência entre os pontos 5 e 6'));
      expect(
        result.stdout,
        contains('Queda antes do pico entre os pontos 1 e 2'),
      );
      expect(
        result.stdout,
        contains('Subida depois do pico entre os pontos 4 e 5'),
      );
    },
  );
}

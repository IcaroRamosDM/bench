import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('evaluates INI criteria and reports results in HTML', () async {
    final directory = await Directory.systemTemp.createTemp('bench_report_');

    addTearDown(() async {
      await directory.delete(recursive: true);
    });

    final input = File('${directory.path}/signal.json');
    final config = File('${directory.path}/criteria.ini');

    await input.writeAsString('{"values":[0,10,4]}');

    Future<ProcessResult> run() {
      return Process.run(Platform.resolvedExecutable, [
        'run',
        'bin/bench.dart',
        '--html',
        '--criteria',
        config.path,
        input.path,
      ]);
    }

    const validIni = '''
[metric.maximum]
lower=8
upper=12

[point.3]
lower=4
upper=6
''';

    await config.writeAsString(validIni);

    final approved = await run();

    expect(approved.exitCode, 0);
    expect(approved.stderr, isEmpty);
    expect(approved.stdout, contains('>APROVADO</p>'));
    expect(approved.stdout, contains('<svg'));
    expect(approved.stdout, contains('<h2>Statistics</h2>'));

    await config.writeAsString(
      validIni
          .replaceFirst('upper=12', 'upper=9')
          .replaceFirst('lower=4', 'lower=5'),
    );

    final rejected = await run();

    expect(rejected.exitCode, 0);
    expect(rejected.stderr, isEmpty);
    expect(rejected.stdout, contains('>REPROVADO</p>'));
    expect(
      rejected.stdout,
      contains('[metric.maximum]: valor 10.0 acima do limite superior 9.0.'),
    );
    expect(
      rejected.stdout,
      contains('[point.3]: valor 4.0 abaixo do limite inferior 5.0.'),
    );

    await config.writeAsString('[point.99]\nlower=0\nupper=1\n');

    final invalid = await run();

    expect(invalid.exitCode, 1);
    expect(invalid.stdout, isEmpty);
    expect(invalid.stderr, contains('Invalid criteria:'));
  });
}

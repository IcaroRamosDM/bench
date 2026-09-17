import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<ProcessResult> _runBench(List<String> arguments) {
  return Process.run(Platform.resolvedExecutable, [
    'run',
    'bin/bench.dart',
    ...arguments,
  ]);
}

Future<File> _writeSignal(Directory directory, String source) {
  final file = File('${directory.path}/signal input.json');
  return file.writeAsString(source);
}

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    final directory = await Directory.systemTemp.createTemp('bench_cli_');
    temporaryDirectory = directory;

    addTearDown(() async {
      await directory.delete(recursive: true);
    });
  });

  test('prints the complete analysis for a valid file', () async {
    final file = await _writeSignal(
      temporaryDirectory,
      '{"values":[0,-3,4,0]}',
    );

    final result = await _runBench([file.path]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(result.stderr, isEmpty);
    expect(const LineSplitter().convert(result.stdout as String), [
      'Points: 4',
      'Minimum: -3.0',
      'Maximum: 4.0',
      'Mean: 0.25',
      'RMS: 2.5',
      'Peak point: 3',
      'Peak-to-peak: 7.0',
      'End delta: 0.0',
    ]);
  });

  test('shows help successfully', () async {
    for (final option in ['--help', '-h']) {
      final result = await _runBench([option]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(result.stdout, contains('Usage: bench <signal.json>'));
      expect(result.stderr, isEmpty);
    }
  });

  test('rejects an incorrect number of arguments', () async {
    for (final arguments in [
      <String>[],
      ['one.json', 'two.json'],
    ]) {
      final result = await _runBench(arguments);

      expect(result.exitCode, 2, reason: result.stderr.toString());
      expect(result.stdout, isEmpty);
      expect(result.stderr, contains('Usage: bench <signal.json>'));
    }
  });

  test('reports a missing input file', () async {
    final result = await _runBench(['${temporaryDirectory.path}/missing.json']);

    expect(result.exitCode, 1, reason: result.stderr.toString());
    expect(result.stdout, isEmpty);
    expect(result.stderr, startsWith('File error:'));
  });

  test('reports invalid signal data', () async {
    final file = await _writeSignal(
      temporaryDirectory,
      '{"values":[1, "oops", 3]}',
    );

    final result = await _runBench([file.path]);

    expect(result.exitCode, 1, reason: result.stderr.toString());
    expect(result.stdout, isEmpty);
    expect(
      result.stderr,
      contains('Invalid signal: Point 2 must be a number.'),
    );
  });

  test('reports an analysis result outside the supported range', () async {
    final file = await _writeSignal(
      temporaryDirectory,
      '{"values":[-1e308,1e308]}',
    );

    final result = await _runBench([file.path]);

    expect(result.exitCode, 1, reason: result.stderr.toString());
    expect(result.stdout, isEmpty);
    expect(result.stderr, startsWith('Analysis failed:'));
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:bench/bench.dart' as bench;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help.')
    ..addFlag('json', negatable: false, help: 'Print results as JSON.')
    ..addFlag('html', negatable: false, help: 'Print an HTML analysis report.')
    ..addOption(
      'criteria',
      valueHelp: 'file.ini',
      help: 'Acceptance criteria for --html.',
    );

  final usage = 'Usage: bench [options] <signal.json>\n\n${parser.usage}';

  late final ArgResults options;

  try {
    options = parser.parse(arguments);
  } on FormatException catch (error) {
    stderr.writeln('Argument error: ${error.message}');
    stderr.writeln(usage);
    exitCode = 2;
    return;
  }

  if (options.flag('help')) {
    print(usage);
    return;
  }

  final criteriaPath = options['criteria'] as String?;

  if (criteriaPath != null && !options.flag('html')) {
    stderr.writeln('Argument error: --criteria requires --html.');
    exitCode = 2;
    return;
  }

  if (options.flag('json') && options.flag('html')) {
    stderr.writeln('Argument error: choose either --json or --html.');
    exitCode = 2;
    return;
  }

  if (options.rest.length != 1) {
    stderr.writeln(usage);
    exitCode = 2;
    return;
  }

  final inputPath = options.rest.single;

  try {
    final source = await File(inputPath).readAsString();
    final values = bench.parseSignalJson(source);

    if (options.flag('html')) {
      var criteria = <bench.Criterion>[];

      if (criteriaPath != null) {
        try {
          final criteriaSource = await File(criteriaPath).readAsString();
          criteria = bench.parseCriteriaIni(criteriaSource);
        } on FormatException catch (error) {
          stderr.writeln('Invalid criteria: ${error.message}');
          exitCode = 1;
          return;
        }
      }

      final report = bench.renderHtmlReport(values, criteria: criteria);

      print(report);
      return;
    }

    final statistics = bench.analyzeSignal(values);

    if (options.flag('json')) {
      print(jsonEncode(statistics));
      return;
    }

    print('Points: ${statistics.count}');
    print('Minimum: ${statistics.minimum}');
    print('Maximum: ${statistics.maximum}');
    print('Mean: ${statistics.mean}');
    print('RMS: ${statistics.rms}');
    print('Peak point: ${statistics.peakPoint}');
    print('Peak-to-peak: ${statistics.peakToPeak}');
    print('End delta: ${statistics.endDelta}');
  } on FileSystemException catch (error) {
    stderr.writeln('File error: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('Invalid signal: ${error.message}');
    exitCode = 1;
  } on RangeError catch (error) {
    stderr.writeln('Analysis failed: ${error.message}');
    exitCode = 1;
  } on ArgumentError catch (error) {
    stderr.writeln('Invalid criteria: ${error.message}');
    exitCode = 1;
  }
}

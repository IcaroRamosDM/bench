import 'dart:io';

import 'package:bench/bench.dart' as bench;

Future<void> main(List<String> arguments) async {
  const usage = 'Usage: bench <signal.json>';

  if (arguments.length == 1 &&
      (arguments.single == '--help' || arguments.single == '-h')) {
    print(usage);
    return;
  }

  if (arguments.length != 1) {
    stderr.writeln(usage);
    exitCode = 2;
    return;
  }

  final inputPath = arguments.single;

  try {
    final source = await File(inputPath).readAsString();
    final values = bench.parseSignalJson(source);
    final statistics = bench.analyzeSignal(values);

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
  }
}

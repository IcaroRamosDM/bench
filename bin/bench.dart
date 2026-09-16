import 'package:bench/bench.dart' as bench;

void main() {
  const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];
  final statistics = bench.analyzeSignal(values);

  print('Points: ${statistics.count}');
  print('Minimum: ${statistics.minimum}');
  print('Maximum: ${statistics.maximum}');
  print('Mean: ${statistics.mean}');
  print('Peak point: ${statistics.peakPoint}');
  print('Peak-to-peak: ${statistics.peakToPeak}');
  print('End delta: ${statistics.endDelta}');
}

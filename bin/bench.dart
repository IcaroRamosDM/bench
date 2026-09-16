import 'package:bench/bench.dart' as bench;

void main() {
  const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

  print('Points: ${values.length}');
  print('Minimum: ${bench.minimum(values)}');
  print('Maximum: ${bench.maximum(values)}');
  print('Peak point: ${bench.peakPoint(values)}');
  print('Peak-to-peak: ${bench.peakToPeak(values)}');
  print('End delta: ${bench.endDelta(values)}');
}

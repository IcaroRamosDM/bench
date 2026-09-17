import 'dart:convert';

import 'package:bench/bench.dart';
import 'package:test/test.dart';

void main() {
  test('serializes analysis results as a numeric JSON object', () {
    final statistics = analyzeSignal([0, -3, 4, 0]);

    final encoded = jsonEncode(statistics);
    final Object? decoded = jsonDecode(encoded);

    expect(decoded, {
      'count': 4,
      'minimum': -3.0,
      'maximum': 4.0,
      'mean': 0.25,
      'rms': 2.5,
      'peakPoint': 3,
      'peakToPeak': 7.0,
      'endDelta': 0.0,
    });
  });
}

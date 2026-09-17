import 'package:bench/bench.dart';
import 'package:test/test.dart';

void main() {
  test('decodes numbers as double and preserves their order', () {
    final values = parseSignalJson('{"values":[3,-1.5,2e1]}');

    expect(values, [3.0, -1.5, 20.0]);
    expect(values, everyElement(isA<double>()));
  });

  test('analyzes a signal decoded from JSON', () {
    final values = parseSignalJson('{"values":[0,-3,4,0]}');
    final result = analyzeSignal(values);

    expect(result.count, 4);
    expect(result.mean, closeTo(0.25, 1e-12));
    expect(result.rms, closeTo(2.5, 1e-12));
    expect(result.peakPoint, 3);
  });

  test('rejects malformed JSON', () {
    expect(() => parseSignalJson('{"values":[1,]}'), throwsFormatException);
  });

  test('rejects invalid signal structures', () {
    for (final source in [
      '[]',
      'null',
      '{}',
      '{"values":null}',
      '{"values":7}',
      '{"values":"1,2"}'
          '{"values":[]}',
    ]) {
      expect(
        () => parseSignalJson(source),
        throwsFormatException,
        reason: source,
      );
    }
  });

  test('rejects non-numeric points', () {
    for (final source in [
      '{"values":[1,"2", 3]}',
      '{"values":[1,null,3]}',
      '{"values":[1,true,3]}',
      '{"values":[1,{},3]}',
      '{"values":[1,[],3]}',
    ]) {
      expect(
        () => parseSignalJson(source),
        throwsFormatException,
        reason: source,
      );
    }
  });

  test('rejects numbers outside the finite double range', () {
    for (final source in ['{"values":[1e400]}', '{"values":[-1e400]}']) {
      expect(
        () => parseSignalJson(source),
        throwsFormatException,
        reason: source,
      );
    }
  });
}

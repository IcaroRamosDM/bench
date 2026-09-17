import 'package:bench/bench.dart';
import 'package:test/test.dart';

void main() {
  const values = <double>[0, 10, 4, 10, 0];

  test('rejects a later peak outside the allowed range', () {
    final evaluation = evaluateCriteria(values, [
      Criterion(metric: 'peakPoint', lower: 2, upper: 3),
    ]);

    expect(evaluation.status, EvaluationStatus.rejected);

    expect(
      evaluation.results
          .where((result) => !result.passed)
          .map((result) => result.value),
      [4],
    );
  });

  test('rejects an earlier peak outside the allowed range', () {
    final evaluation = evaluateCriteria(values, [
      Criterion(metric: 'peakPoint', lower: 3, upper: 4),
    ]);

    expect(evaluation.status, EvaluationStatus.rejected);

    expect(
      evaluation.results
          .where((result) => !result.passed)
          .map((result) => result.value),
      [2],
    );
  });

  test('approves when every peak is inside the allowed range', () {
    final evaluation = evaluateCriteria(values, [
      Criterion(metric: 'peakPoint', lower: 2, upper: 4),
    ]);

    expect(evaluation.status, EvaluationStatus.approved);

    expect(evaluation.results.map((result) => result.value), [2, 4]);
  });

  test('checks every point of a flat peak', () {
    final evaluation = evaluateCriteria(
      [0, 10, 10, 0],
      [Criterion(metric: 'peakPoint', lower: 2, upper: 2)],
    );

    expect(evaluation.status, EvaluationStatus.rejected);

    expect(
      evaluation.results
          .where((result) => !result.passed)
          .map((result) => result.value),
      [3],
    );
  });
}

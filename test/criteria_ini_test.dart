import 'package:bench/bench.dart';
import 'package:test/test.dart';

void main() {
  const source = '''
; Demonstration

[metric.maximum]
lower = 8
upper = 12

# The second point must equal 10

[point.2]
lower = 10
upper = 10
''';

  test('loads and applies both kinds of criteria', () {
    final criteria = parseCriteriaIni(source);

    expect(criteria, hasLength(2));

    expect(
      evaluateCriteria([0, 10, 4], criteria).status,
      EvaluationStatus.approved,
    );

    expect(
      evaluateCriteria([0, 9, 4], criteria).status,
      EvaluationStatus.rejected,
    );

    expect(
      evaluateCriteria([0, 10, 14], criteria).status,
      EvaluationStatus.rejected,
    );
  });

  test('accepts Windows line endings', () {
    final criteria = parseCriteriaIni(source.replaceAll('\n', '\r\n'));

    expect(
      evaluateCriteria([0, 10, 4], criteria).status,
      EvaluationStatus.approved,
    );
  });

  test('rejects invalid or ambiguous configuration', () {
    final invalidSources = [
      '',
      '; Only a comment',
      'lower = 1',
      '$source\n$source',
      source.replaceFirst('lower = 8', 'lower = 8\nlower = 9'),
      source.replaceFirst('lower = 8', 'lowre = 8'),
      source.replaceFirst('upper = 12', ''),
      source.replaceFirst('upper = 12', 'upper = abc'),
      source.replaceFirst('lower = 8', 'lower = 20'),
      source.replaceFirst('lower = 8', 'lower = NaN'),
      source.replaceFirst('upper = 12', 'upper = Infinity'),
      source.replaceFirst('maximum', 'unknown'),
      source.replaceFirst('point.2', 'point.0'),
    ];

    for (final invalidSource in invalidSources) {
      expect(
        () => parseCriteriaIni(invalidSource),
        throwsFormatException,
        reason: invalidSource,
      );
    }
  });
}

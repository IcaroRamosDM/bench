import 'statistics.dart';

enum EvaluationStatus { noCriteria, approved, rejected }

class Criterion {
  final String? metric;
  final int? point;
  final double? lower;
  final double? upper;
  final bool upperInclusive;
  final double tolerance;
  final String? label;

  Criterion({
    this.metric,
    this.point,
    this.lower,
    this.upper,
    this.upperInclusive = true,
    this.tolerance = 0,
    this.label,
  }) {
    if ((metric == null) == (point == null)) {
      throw ArgumentError('Specify exactly one metric or point.');
    }

    if (point != null && point! < 1) {
      throw ArgumentError('Point numbers start at 1.');
    }

    final low = lower;
    final high = upper;

    if (low == null && high == null) {
      throw ArgumentError('Specify at least one bound.');
    }

    if ((low != null && !low.isFinite) || (high != null && !high.isFinite)) {
      throw ArgumentError('Criterion bounds must be finite.');
    }

    if (low != null &&
        high != null &&
        (low > high || (low == high && !upperInclusive))) {
      throw ArgumentError('The criterion interval is empty.');
    }

    if (!tolerance.isFinite || tolerance < 0) {
      throw ArgumentError('Tolerance must be finite and nonnegative.');
    }
  }

  String get target {
    return label ?? (point == null ? '[metric.$metric]' : '[point.$point]');
  }
}

class CriterionResult {
  final Criterion criterion;
  final num value;
  final List<String> _details;

  CriterionResult._(
    this.criterion,
    this.value, [
    Iterable<String> details = const [],
  ]) : _details = List<String>.unmodifiable(details);

  bool get passed {
    final lower = criterion.lower;
    final upper = criterion.upper;

    return (lower == null || value >= lower) &&
        (upper == null ||
            (criterion.upperInclusive ? value <= upper : value < upper));
  }

  List<String> get failureReasons {
    if (passed) {
      return const [];
    }

    if (_details.isNotEmpty) {
      return _details;
    }

    final target = criterion.target;
    final lower = criterion.lower;

    if (lower != null && value < lower) {
      return ['$target: valor $value abaixo do limite inferior $lower.'];
    }

    final upper = criterion.upper!;

    if (!criterion.upperInclusive) {
      return ['$target: valor $value deve ser menor que $upper.'];
    }

    return ['$target: valor $value acima do limite superior $upper.'];
  }
}

class CriteriaEvaluation {
  final List<CriterionResult> results;

  CriteriaEvaluation._(List<CriterionResult> results)
    : results = List<CriterionResult>.unmodifiable(results);

  EvaluationStatus get status {
    if (results.isEmpty) {
      return EvaluationStatus.noCriteria;
    }

    return results.every((result) => result.passed)
        ? EvaluationStatus.approved
        : EvaluationStatus.rejected;
  }

  List<String> get failureReasons {
    return List<String>.unmodifiable(
      results.expand((result) => result.failureReasons),
    );
  }
}

CriteriaEvaluation evaluateCriteria(
  List<double> values,
  List<Criterion> criteria,
) {
  final statistics = analyzeSignal(values);
  final measurements = statistics.toJson();

  measurements['first'] = values.first;
  measurements['last'] = values.last;

  final firstPeak = values.indexOf(statistics.maximum);
  final lastPeak = values.lastIndexOf(statistics.maximum);
  final results = <CriterionResult>[];

  const shapeMetrics = {'flatSegments', 'dropsBeforePeak', 'risesAfterPeak'};

  for (final criterion in criteria) {
    final metric = criterion.metric;

    if (metric == 'peakPoint') {
      for (var index = 0; index < values.length; index++) {
        if (values[index] == statistics.maximum) {
          results.add(CriterionResult._(criterion, index + 1));
        }
      }

      continue;
    }

    if (shapeMetrics.contains(metric)) {
      final details = <String>[];

      for (var index = 1; index < values.length; index++) {
        final delta = values[index] - values[index - 1];
        final tolerance = criterion.tolerance;
        String? event;

        if (metric == 'flatSegments' && delta.abs() <= tolerance) {
          event = 'Permanência';
        } else if (metric == 'dropsBeforePeak' &&
            index <= lastPeak &&
            delta < -tolerance) {
          event = 'Queda antes do pico';
        } else if (metric == 'risesAfterPeak' &&
            index > firstPeak &&
            delta > tolerance) {
          event = 'Subida depois do pico';
        }

        if (event != null) {
          details.add(
            '$event entre os pontos $index e ${index + 1}: '
            '${values[index - 1]} para ${values[index]} '
            '(tolerância $tolerance).',
          );
        }
      }

      results.add(CriterionResult._(criterion, details.length, details));
      continue;
    }

    final point = criterion.point;
    final num value;

    if (point != null) {
      if (point > values.length) {
        throw ArgumentError.value(
          point,
          'point',
          'Exceeds the number of signal points.',
        );
      }

      value = values[point - 1];
    } else {
      final measured = measurements[metric];

      if (measured == null) {
        throw ArgumentError.value(metric, 'metric', 'Unknown statistic.');
      }

      value = measured;
    }

    results.add(CriterionResult._(criterion, value));
  }

  return CriteriaEvaluation._(results);
}

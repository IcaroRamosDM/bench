import 'dart:math' as math;

import '../model/signal_statistics.dart';

double maximum(List<double> values) {
  _validateValues(values);

  double result = values.first;

  for (final value in values) {
    if (value > result) {
      result = value;
    }
  }

  return result;
}

int peakPoint(List<double> values) {
  final peak = maximum(values);
  return values.indexOf(peak) + 1;
}

double minimum(List<double> values) {
  _validateValues(values);

  double result = values.first;

  for (final value in values) {
    if (value < result) {
      result = value;
    }
  }

  return result;
}

double peakToPeak(List<double> values) {
  final result = maximum(values) - minimum(values);

  if (!result.isFinite) {
    throw RangeError('The peak-to-peak value exceeds the supported range.');
  }

  return result;
}

void _validateValues(List<double> values) {
  if (values.isEmpty) {
    throw ArgumentError('The signal must contain at least one value.');
  }

  for (final value in values) {
    if (!value.isFinite) {
      throw ArgumentError('Signal values must be finite.');
    }
  }
}

double endDelta(List<double> values) {
  _validateValues(values);

  final result = values.last - values.first;

  if (!result.isFinite) {
    throw RangeError('The end delta exceeds the supported range.');
  }

  return result;
}

SignalStatistics analyzeSignal(List<double> values) {
  return SignalStatistics(
    count: values.length,
    minimum: minimum(values),
    maximum: maximum(values),
    mean: mean(values),
    rms: rms(values),
    peakPoint: peakPoint(values),
    peakToPeak: peakToPeak(values),
    endDelta: endDelta(values),
  );
}

double mean(List<double> values) {
  _validateValues(values);

  var scale = 0.0;

  for (final value in values) {
    final magnitude = value.abs();

    if (magnitude > scale) {
      scale = magnitude;
    }
  }

  if (scale == 0.0) {
    return 0.0;
  }

  var sum = 0.0;
  var correction = 0.0;

  for (final value in values) {
    final normalized = value / scale;
    final next = sum + normalized;

    if (sum.abs() >= normalized.abs()) {
      correction += (sum - next) + normalized;
    } else {
      correction += (normalized - next) + sum;
    }

    sum = next;
  }

  return ((sum + correction) / values.length) * scale;
}

double rms(List<double> values) {
  _validateValues(values);

  var scale = 0.0;

  for (final value in values) {
    final magnitude = value.abs();

    if (magnitude > scale) {
      scale = magnitude;
    }
  }

  if (scale == 0.0) {
    return 0.0;
  }

  var sumSquares = 0.0;
  var correction = 0.0;

  for (final value in values) {
    final normalized = value / scale;
    final square = normalized * normalized;
    final next = sumSquares + square;

    if (sumSquares >= square) {
      correction += (sumSquares - next) + square;
    } else {
      correction += (square - next) + sumSquares;
    }

    sumSquares = next;
  }

  return math.sqrt((sumSquares + correction) / values.length) * scale;
}

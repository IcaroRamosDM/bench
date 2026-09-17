import 'dart:math' as math;

import '../model/signal_statistics.dart';
import 'compensated_sum.dart';

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

  final scale = _maximumMagnitude(values);

  if (scale == 0.0) {
    return 0.0;
  }

  final sum = CompensatedSum();

  for (final value in values) {
    sum.add(value / scale);
  }

  return (sum.value / values.length) * scale;
}

double rms(List<double> values) {
  _validateValues(values);

  final scale = _maximumMagnitude(values);

  if (scale == 0.0) {
    return 0.0;
  }

  final sumSquares = CompensatedSum();

  for (final value in values) {
    final normalized = value / scale;
    sumSquares.add(normalized * normalized);
  }

  return math.sqrt(sumSquares.value / values.length) * scale;
}

double _maximumMagnitude(List<double> values) {
  var scale = 0.0;

  for (final value in values) {
    final magnitude = value.abs();

    if (magnitude > scale) {
      scale = magnitude;
    }
  }

  return scale;
}

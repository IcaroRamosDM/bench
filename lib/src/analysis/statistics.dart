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

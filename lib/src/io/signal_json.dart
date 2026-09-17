import 'dart:convert';

List<double> parseSignalJson(String source) {
  final Object? decoded = jsonDecode(source);

  if (decoded is! Map<String, Object?>) {
    throw FormatException('Signal JSON must be an object.');
  }

  final rawValues = decoded['values'];

  if (rawValues is! List<Object?>) {
    throw FormatException('"values" must be a list.');
  }

  if (rawValues.isEmpty) {
    throw FormatException('"values must contain at least one number.');
  }

  final values = <double>[];

  for (var index = 0; index < rawValues.length; index++) {
    final rawValue = rawValues[index];

    if (rawValue is! num) {
      throw FormatException('Point ${index + 1} must be a number.');
    }

    final value = rawValue.toDouble();

    if (!value.isFinite) {
      throw FormatException('Point ${index + 1} must be finite.');
    }

    values.add(value);
  }

  return values;
}

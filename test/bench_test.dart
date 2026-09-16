import 'package:bench/bench.dart';
import 'package:test/test.dart';

void main() {
  test('finds the maximum of the nine-point example', () {
    const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

    expect(maximum(values), 2373.0);
  });

  test('handles negative values', () {
    expect(maximum([-5, -2, -9]), -2.0);
  });

  test('handles a single value', () {
    expect(maximum([7.5]), 7.5);
  });

  test('rejects an empty signal', () {
    expect(() => maximum([]), throwsArgumentError);
  });

  test('rejects non-finite values', () {
    expect(() => maximum([double.nan]), throwsArgumentError);
    expect(() => maximum([1, double.infinity]), throwsArgumentError);
    expect(() => maximum([1, double.negativeInfinity]), throwsArgumentError);
  });

  test('finds the peak point of the nine-point example', () {
    const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

    expect(peakPoint(values), 5);
  });

  test('returns the first peak point when the maximum repeats', () {
    expect(peakPoint([-5, -2, -9, -2]), 2);
  });

  test('returns point one when the first value is maximal', () {
    expect(peakPoint([9, 3, 1]), 1);
  });

  test('rejects an empty signal when locating the peak', () {
    expect(() => peakPoint([]), throwsArgumentError);
  });

  test('finds the minimum of the nine-point example', () {
    const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

    expect(minimum(values), 0.0);
  });

  test('finds the minimum among positive values', () {
    expect(minimum([5, 2, 9]), 2.0);
  });

  test('finds the minimum among negative values', () {
    expect(minimum([-5, -2, -9]), -9.0);
  });

  test('rejects an empty signal when finding the minimum', () {
    expect(() => minimum([]), throwsArgumentError);
  });

  test('rejects non-finite values when finding the minimnum', () {
    expect(() => minimum([double.nan]), throwsArgumentError);
    expect(() => minimum([1, double.infinity]), throwsArgumentError);
    expect(() => minimum([1, double.negativeInfinity]), throwsArgumentError);
  });

  test('calculates peak-to-peak for the nine-point example', () {
    const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

    expect(peakToPeak(values), 2373.0);
  });

  test('calculates peak-to-peak across zero', () {
    expect(peakToPeak([-3, 5]), 8.0);
  });

  test('calculates peak-to-peak for negative values', () {
    expect(peakToPeak([-5, -2, -9]), 7.0);
  });

  test('returns zero peak-to-peak for a constant signal', () {
    expect(peakToPeak([4, 4, 4]), 0.0);
    expect(peakToPeak([7.5]), 0.0);
  });

  test('rejects invalid signals when calculating peak-to-peak', () {
    expect(() => peakToPeak([]), throwsArgumentError);
    expect(() => peakToPeak([double.nan]), throwsArgumentError);
    expect(() => peakToPeak([1, double.infinity]), throwsArgumentError);
    expect(() => peakToPeak([1, double.negativeInfinity]), throwsArgumentError);
  });

  test('rejects peak-to-peak overflow', () {
    expect(() => peakToPeak([-1e308, 1e308]), throwsRangeError);
  });

  test('calculates end delta for the nine-point example', () {
    const values = <double>[0, 629, 1069, 1867, 2373, 2158, 1390, 902, 8];

    expect(endDelta(values), 8.0);
  });

  test('returns a negative end delta for a falling signal', () {
    expect(endDelta([9, 4, 1]), -8.0);
  });

  test('calculates end delta from the first and last values', () {
    expect(endDelta([3, 100, -20, 7]), 4.0);
  });

  test('returns zero when endpoints are equal', () {
    expect(endDelta([2, 10, 2]), 0.0);
    expect(endDelta([7.5]), 0.0);
  });

  test('rejects invalid signals when calculating end delta', () {
    expect(() => endDelta([]), throwsArgumentError);
    expect(() => endDelta([1, double.nan, 3]), throwsArgumentError);
    expect(() => endDelta([1, double.infinity, 3]), throwsArgumentError);
    expect(
      () => endDelta([1, double.negativeInfinity, 3]),
      throwsArgumentError,
    );
  });

  test('rejects end delta overflow', () {
    expect(() => endDelta([-1e308, 1e308]), throwsRangeError);
    expect(() => endDelta([1e308, -1e308]), throwsRangeError);
  });
}

class SignalStatistics {
  final int count;
  final double minimum;
  final double maximum;
  final int peakPoint;
  final double peakToPeak;
  final double endDelta;

  SignalStatistics({
    required this.count,
    required this.minimum,
    required this.maximum,
    required this.peakPoint,
    required this.peakToPeak,
    required this.endDelta,
  });
}

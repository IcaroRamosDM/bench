class SignalStatistics {
  final int count;
  final double minimum;
  final double maximum;
  final double mean;
  final double rms;
  final int peakPoint;
  final double peakToPeak;
  final double endDelta;

  SignalStatistics({
    required this.count,
    required this.minimum,
    required this.maximum,
    required this.mean,
    required this.rms,
    required this.peakPoint,
    required this.peakToPeak,
    required this.endDelta,
  });

  Map<String, num> toJson() {
    return {
      'count': count,
      'minimum': minimum,
      'maximum': maximum,
      'mean': mean,
      'rms': rms,
      'peakPoint': peakPoint,
      'peakToPeak': peakToPeak,
      'endDelta': endDelta,
    };
  }
}

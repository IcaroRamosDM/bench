class CompensatedSum {
  double _sum = 0.0;
  double _correction = 0.0;

  void add(double value) {
    final next = _sum + value;

    if (_sum.abs() >= value.abs()) {
      _correction += (_sum - next) + value;
    } else {
      _correction += (value - next) + _sum;
    }

    _sum = next;
  }

  double get value => _sum + _correction;
}

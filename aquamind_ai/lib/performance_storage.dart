import 'swim_performance.dart';

class PerformanceStorage {
  static final List<SwimPerformance> performances = [];

  static void addPerformance(SwimPerformance performance) {
    performances.add(performance);
  }

  static SwimPerformance? latestPerformance() {
    if (performances.isEmpty) {
      return null;
    }

    return performances.last;
  }
}

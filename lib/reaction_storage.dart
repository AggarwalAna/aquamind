class ReactionStorage {
  static final List<double> reactionTimes = [];

  static double? latestReactionTime;

  static void addReaction(double time) {
    reactionTimes.add(time);

    latestReactionTime = time;
  }

  static double getBestTime() {
    if (reactionTimes.isEmpty) {
      return 0;
    }

    return reactionTimes.reduce((a, b) => a < b ? a : b);
  }

  static double getAverageTime() {
    if (reactionTimes.isEmpty) {
      return 0;
    }

    double total = 0;

    for (double time in reactionTimes) {
      total += time;
    }

    return total / reactionTimes.length;
  }

  static int getAttempts() {
    return reactionTimes.length;
  }
}

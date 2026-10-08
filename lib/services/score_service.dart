import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  final int highScore;
  final int gamesPlayed;
  final int totalLines;

  const PlayerStats({
    required this.highScore,
    required this.gamesPlayed,
    required this.totalLines,
  });
}

class ScoreService {
  static const _highScoreKey = 'high_score';
  static const _gamesPlayedKey = 'games_played';
  static const _totalLinesKey = 'total_lines';

  Future<PlayerStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    return PlayerStats(
      highScore: prefs.getInt(_highScoreKey) ?? 0,
      gamesPlayed: prefs.getInt(_gamesPlayedKey) ?? 0,
      totalLines: prefs.getInt(_totalLinesKey) ?? 0,
    );
  }

  Future<int> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  /// تُستدعى مرة واحدة عند انتهاء الجولة.
  /// تعيد true إذا كان رقمًا قياسيًا جديدًا.
  Future<bool> submitGameResult({
    required int score,
    required int lines,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final currentHigh = prefs.getInt(_highScoreKey) ?? 0;
    final games = prefs.getInt(_gamesPlayedKey) ?? 0;
    final totalLines = prefs.getInt(_totalLinesKey) ?? 0;

    await prefs.setInt(_gamesPlayedKey, games + 1);
    await prefs.setInt(_totalLinesKey, totalLines + lines);

    if (score > currentHigh) {
      await prefs.setInt(_highScoreKey, score);
      return true;
    }

    return false;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_highScoreKey);
    await prefs.remove(_gamesPlayedKey);
    await prefs.remove(_totalLinesKey);
  }
}

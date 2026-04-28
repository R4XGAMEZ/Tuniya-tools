import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredCount;
  final String badge;

  const Achievement({
    required this.id, required this.title, required this.description,
    required this.requiredCount, required this.badge,
  });
}

class GamificationService {
  static final GamificationService _i = GamificationService._();
  static GamificationService get instance => _i;
  GamificationService._();

  static const achievements = [
    Achievement(id:'first_tool', title:'First Step', description:'Pehla tool use karo', requiredCount:1, badge:'BEGINNER'),
    Achievement(id:'tool_10', title:'Explorer', description:'10 tools use karo', requiredCount:10, badge:'EXPLORER'),
    Achievement(id:'tool_25', title:'Power User', description:'25 tools use karo', requiredCount:25, badge:'POWER USER'),
    Achievement(id:'tool_50', title:'TUNIYA PRO', description:'50 tools use karo', requiredCount:50, badge:'TUNIYA PRO'),
    Achievement(id:'tool_100', title:'Master', description:'100 tools use karo', requiredCount:100, badge:'MASTER'),
    Achievement(id:'ai_5', title:'AI Lover', description:'5 AI tools use karo', requiredCount:5, badge:'AI LOVER'),
    Achievement(id:'downloader_3', title:'Downloader', description:'3 platforms se download karo', requiredCount:3, badge:'DOWNLOADER'),
    Achievement(id:'streak_7', title:'Week Streak', description:'7 din lagatar app use karo', requiredCount:7, badge:'7 DAY STREAK'),
  ];

  // Stats
  int _totalToolUses = 0;
  int _aiToolUses = 0;
  int _downloaderUses = 0;
  int _dayStreak = 0;
  Set<String> _unlocked = {};
  String? _todayChallenge;
  bool _challengeDone = false;

  int get totalToolUses => _totalToolUses;
  int get streak => _dayStreak;
  Set<String> get unlockedIds => _unlocked;
  String? get todayChallenge => _todayChallenge;
  bool get challengeDone => _challengeDone;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _totalToolUses = p.getInt('g_total') ?? 0;
    _aiToolUses = p.getInt('g_ai') ?? 0;
    _downloaderUses = p.getInt('g_dl') ?? 0;
    _dayStreak = p.getInt('g_streak') ?? 0;
    _unlocked = (p.getStringList('g_unlocked') ?? []).toSet();
    _updateStreak(p);
    _generateDailyChallenge();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    _challengeDone = p.getString('g_challenge_date') == todayStr;
  }

  void _updateStreak(SharedPreferences p) {
    final lastDate = p.getString('g_last_date') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1))
        .toIso8601String().substring(0, 10);
    if (lastDate == today) return;
    if (lastDate == yesterday) {
      _dayStreak++;
    } else if (lastDate != today) {
      _dayStreak = 1;
    }
    p.setString('g_last_date', today);
    p.setInt('g_streak', _dayStreak);
  }

  void _generateDailyChallenge() {
    final challenges = [
      'Aaj ek PDF merge karo',
      'Ek image upscale karo',
      'Ek video compress karo',
      'AI se kuch translate karo',
      'Ek file ka link generate karo',
      'Kisi ek code editor mein kuch likho',
      'AI Chat se koi sawaal poochho',
      'Kisi file ka info check karo',
      'Ek audio ki volume boost karo',
      'QR code generate karo',
    ];
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _todayChallenge = challenges[dayOfYear % challenges.length];
  }

  Future<List<Achievement>> recordToolUse(String toolId, String category) async {
    final p = await SharedPreferences.getInstance();
    _totalToolUses++;
    if (category == 'ai') _aiToolUses++;
    if (category == 'downloader') _downloaderUses++;

    await p.setInt('g_total', _totalToolUses);
    await p.setInt('g_ai', _aiToolUses);
    await p.setInt('g_dl', _downloaderUses);

    // Check challenge
    if (!_challengeDone && _todayChallenge != null) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await p.setString('g_challenge_date', today);
      _challengeDone = true;
    }

    return await _checkAchievements(p);
  }

  Future<List<Achievement>> _checkAchievements(SharedPreferences p) async {
    final newlyUnlocked = <Achievement>[];
    for (final a in achievements) {
      if (_unlocked.contains(a.id)) continue;
      bool earned = false;
      switch (a.id) {
        case 'first_tool': earned = _totalToolUses >= 1; break;
        case 'tool_10': earned = _totalToolUses >= 10; break;
        case 'tool_25': earned = _totalToolUses >= 25; break;
        case 'tool_50': earned = _totalToolUses >= 50; break;
        case 'tool_100': earned = _totalToolUses >= 100; break;
        case 'ai_5': earned = _aiToolUses >= 5; break;
        case 'downloader_3': earned = _downloaderUses >= 3; break;
        case 'streak_7': earned = _dayStreak >= 7; break;
      }
      if (earned) {
        _unlocked.add(a.id);
        newlyUnlocked.add(a);
      }
    }
    if (newlyUnlocked.isNotEmpty) {
      await p.setStringList('g_unlocked', _unlocked.toList());
    }
    return newlyUnlocked;
  }

  List<Achievement> get allAchievements => achievements;
  bool isUnlocked(String id) => _unlocked.contains(id);

  String get userBadge {
    if (isUnlocked('tool_100')) return 'MASTER';
    if (isUnlocked('tool_50')) return 'TUNIYA PRO';
    if (isUnlocked('tool_25')) return 'POWER USER';
    if (isUnlocked('tool_10')) return 'EXPLORER';
    if (isUnlocked('first_tool')) return 'BEGINNER';
    return 'NEWBIE';
  }
}

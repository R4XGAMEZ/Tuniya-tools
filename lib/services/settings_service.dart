import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _geminiKey = 'gemini_api_key';
  static const _claudeKey = 'claude_api_key';
  static const _recentToolsKey = 'recent_tools';
  static const _favToolsKey = 'fav_tools';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Gemini API Key
  String get geminiApiKey => _prefs?.getString(_geminiKey) ?? '';
  Future<void> setGeminiApiKey(String key) async =>
      await _prefs?.setString(_geminiKey, key);

  // Claude API Key
  String get claudeApiKey => _prefs?.getString(_claudeKey) ?? '';
  Future<void> setClaudeApiKey(String key) async =>
      await _prefs?.setString(_claudeKey, key);

  bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  bool get hasClaudeKey => claudeApiKey.isNotEmpty;

  // Recent Tools (last 8 used)
  List<String> get recentTools =>
      _prefs?.getStringList(_recentToolsKey) ?? [];

  Future<void> addRecentTool(String toolId) async {
    final list = recentTools;
    list.remove(toolId);
    list.insert(0, toolId);
    if (list.length > 8) list.removeLast();
    await _prefs?.setStringList(_recentToolsKey, list);
  }

  // Favourite Tools
  List<String> get favTools =>
      _prefs?.getStringList(_favToolsKey) ?? [];

  Future<void> toggleFav(String toolId) async {
    final list = favTools;
    if (list.contains(toolId)) {
      list.remove(toolId);
    } else {
      list.add(toolId);
    }
    await _prefs?.setStringList(_favToolsKey, list);
  }

  bool isFav(String toolId) => favTools.contains(toolId);
}

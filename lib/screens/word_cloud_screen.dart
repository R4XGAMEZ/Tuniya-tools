import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class WordCloudScreen extends BaseToolScreen {
  const WordCloudScreen({super.key}) : super(toolId: 'word_cloud');
  @override
  State<WordCloudScreen> createState() => _WordCloudScreenState();
}

class _WordCloudScreenState extends BaseToolScreenState<WordCloudScreen> {
  final _inputCtrl = TextEditingController();
  List<MapEntry<String, int>> _words = [];
  bool _removeStopWords = true;
  int _maxWords = 50;
  String _tab = 'cloud'; // cloud | list

  static const _stopWords = {
    'a','an','the','is','are','was','were','be','been','being',
    'have','has','had','do','does','did','will','would','could','should',
    'may','might','shall','can','need','dare','ought','used',
    'i','me','my','myself','we','our','ours','ourselves',
    'you','your','yours','yourself','yourselves',
    'he','him','his','himself','she','her','hers','herself',
    'it','its','itself','they','them','their','theirs','themselves',
    'what','which','who','whom','this','that','these','those',
    'am','at','by','for','with','about','against','between',
    'into','through','during','before','after','above','below',
    'to','from','up','down','in','out','on','off','over','under',
    'again','further','then','once','here','there','when','where',
    'why','how','all','both','each','few','more','most','other',
    'some','such','no','nor','not','only','own','same','so','than',
    'too','very','just','but','and','or','if','as','of',
    'ki','ka','ke','ko','hai','hain','tha','thi','the','se','me','ne',
    'ye','woh','aur','par','mein','kya','jo','koi',
  };

  static const _cloudColors = [
    Color(0xFF9D4EDD), Color(0xFF7B2FBE), Color(0xFFE040FB),
    Color(0xFF00BCD4), Color(0xFF26C6DA), Color(0xFF64B5F6),
    Color(0xFF81C784), Color(0xFFFF7043), Color(0xFFFFD54F),
    Color(0xFFEF5350), Color(0xFFAB47BC), Color(0xFF42A5F5),
  ];

  void _generate() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('Kuch text paste karo!'); return; }
    setError(null);

    final freq = <String, int>{};
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1);

    for (final w in words) {
      if (_removeStopWords && _stopWords.contains(w)) continue;
      freq[w] = (freq[w] ?? 0) + 1;
    }

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() => _words = sorted.take(_maxWords).toList());
  }


  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(
          controller: _inputCtrl,
          maxLines: 6,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Koi bhi text paste karo — article, blog, essay...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _words = []; }),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Options
        Row(children: [
          Checkbox(
            value: _removeStopWords,
            onChanged: (v) => setState(() => _removeStopWords = v ?? true),
            activeColor: AppTheme.purple,
          ),
          Text('Stop words hata do',
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
          const Spacer(),
          Text('Max:', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _maxWords,
            dropdownColor: AppTheme.cardBg2,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
            underline: const SizedBox(),
            items: [25, 50, 75, 100].map((n) =>
                DropdownMenuItem(value: n, child: Text('$n'))).toList(),
            onChanged: (v) => setState(() => _maxWords = v ?? 50),
          ),
        ]),
        const SizedBox(height: 12),

        GradientButton(
          label: 'Word Cloud Banao',
          icon: Icons.cloud_outlined,
          onPressed: _generate,
        ),

        if (_words.isNotEmpty) ...[
          const SizedBox(height: 20),
          // Tab switcher
          Row(children: [
            _tabBtn('cloud', Icons.cloud_outlined, 'Cloud View'),
            const SizedBox(width: 10),
            _tabBtn('list', Icons.format_list_numbered_outlined, 'List View'),
          ]),
          const SizedBox(height: 16),

          if (_tab == 'cloud') _buildCloud(),
          if (_tab == 'list') _buildList(),
        ],
      ]),
    );
  }

  Widget _buildCloud() {
    final maxCount = _words.first.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _words.asMap().entries.map((e) {
          final word  = e.value.key;
          final count = e.value.value;
          final ratio = count / maxCount; // 0.0–1.0
          final size  = 12.0 + (ratio * 26.0); // 12–38px
          final color = _cloudColors[e.key % _cloudColors.length];
          return GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: word));
              showSnack('"$word" copied (×$count)');
            },
            child: Text(
              word,
              style: GoogleFonts.rajdhani(
                color: color.withValues(alpha: 0.6 + ratio * 0.4),
                fontSize: size,
                fontWeight: ratio > 0.5 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    final maxCount = _words.first.value;
    return Column(children: _words.take(30).toList().asMap().entries.map((e) {
      final word  = e.value.key;
      final count = e.value.value;
      final ratio = count / maxCount;
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(width: 30,
              child: Text('${e.key + 1}.',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(word, style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: ratio,
                backgroundColor: AppTheme.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _cloudColors[e.key % _cloudColors.length]),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Text('×$count', style: GoogleFonts.rajdhani(
              color: AppTheme.purple, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
    }).toList());
  }

  Widget _tabBtn(String id, IconData icon, String label) {
    final sel = _tab == id;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: sel ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.rajdhani(
              color: sel ? Colors.white : AppTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    ));
  }
}

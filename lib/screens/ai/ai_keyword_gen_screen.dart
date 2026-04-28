import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiKeywordGenScreen extends StatefulWidget {
  const AiKeywordGenScreen({super.key});
  @override
  State<AiKeywordGenScreen> createState() => _AiKeywordGenScreenState();
}

class _AiKeywordGenScreenState extends State<AiKeywordGenScreen> {
  final _topicCtrl = TextEditingController();
  String _platform = 'YouTube';
  List<String> _keywords = [];
  bool _loading = false;

  final _platforms = ['YouTube', 'Instagram', 'Blog/SEO', 'Twitter/X', 'Pinterest', 'TikTok', 'LinkedIn'];

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_topicCtrl.text.trim().isEmpty) {
      _showSnack('Topic batao!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _keywords = []; });
    try {
      final res = await ClaudeService.instance.generateKeywords(_topicCtrl.text.trim(), _platform);
      final raw = res.split(RegExp(r'[,\n]')).map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
      if (!mounted) return;
      setState(() => _keywords = raw);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Keyword Gen', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          Text('Platform', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _platforms.map((p) {
            final sel = p == _platform;
            return GestureDetector(
              onTap: () => setState(() => _platform = p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
                ),
                child: Text(p, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13)),
              ),
            );
          }).toList() as List<Widget>),
          const SizedBox(height: 14),
          Text('Video / Post Topic', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _topicCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g. How to make biryani at home, Flutter tutorial, Minecraft guide...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13),
              filled: true, fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Keywords dhoondh raha hoon...' : 'Generate Keywords 🔖',
              onPressed: _generate,
            ),
          ),
          if (_keywords.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_keywords.length} Keywords', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              GestureDetector(
                onTap: () { Clipboard.setData(ClipboardData(text: _keywords.join(', '))); _showSnack('Saare keywords copy ho gaye!'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.copy, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('Copy All', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _keywords.map((k) => GestureDetector(
              onTap: () { Clipboard.setData(ClipboardData(text: k)); _showSnack('Copied: $k'); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(k, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ]),
              ),
            )).toList() as List<Widget>),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Comma-separated (ready to paste):', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                SelectableText(_keywords.join(', '), style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

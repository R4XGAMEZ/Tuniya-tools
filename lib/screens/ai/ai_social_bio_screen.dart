import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiSocialBioScreen extends StatefulWidget {
  const AiSocialBioScreen({super.key});
  @override
  State<AiSocialBioScreen> createState() => _AiSocialBioScreenState();
}

class _AiSocialBioScreenState extends State<AiSocialBioScreen> {
  final _aboutCtrl = TextEditingController();
  String _platform = 'Instagram';
  String _vibe = 'Cool & Trendy';
  List<String> _results = [];
  bool _loading = false;

  final _platforms = ['Instagram', 'Twitter/X', 'LinkedIn', 'YouTube', 'TikTok', 'Snapchat', 'Pinterest'];
  final _vibes = ['Cool & Trendy', 'Professional', 'Funny & Witty', 'Aesthetic', 'Motivational', 'Mysterious', 'Gamer', 'Artist'];

  @override
  void dispose() { _aboutCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_aboutCtrl.text.trim().isEmpty) {
      _showSnack('Apne baare mein kuch batao pehle!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _results = []; });
    try {
      // Generate 3 variations
      final futures = List.generate(3, (_) => ClaudeService.instance.socialBio(_platform, _aboutCtrl.text.trim(), _vibe));
      final res = await Future.wait(futures);
      if (!mounted) return;
      setState(() => _results = res);
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
        title: Text('AI Social Bio', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
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
          }).toList()),
          const SizedBox(height: 14),
          Text('Vibe / Style', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
            child: DropdownButton<String>(
              value: _vibe, isExpanded: true, dropdownColor: AppTheme.cardBg2,
              underline: const SizedBox(),
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              items: _vibes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) { if (v != null) setState(() => _vibe = v); },
            ),
          ),
          const SizedBox(height: 14),
          Text('About You *', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _aboutCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. I\'m a 20 yr old photographer from Mumbai who loves street food and sunsets',
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
              label: _loading ? 'Bio generate ho raha hai...' : 'Generate 3 Bio Options ✨',
              onTap: _loading ? null : _generate,
            ),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Pick Your Favourite', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
            const SizedBox(height: 10),
            ..._results.asMap().entries.map((e) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
                    child: Text('Option ${e.key + 1}', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 11)),
                  ),
                  GestureDetector(
                    onTap: () { Clipboard.setData(ClipboardData(text: e.value)); _showSnack('Bio ${e.key + 1} copied!'); },
                    child: const Icon(Icons.copy, color: AppTheme.textSecondary, size: 18),
                  ),
                ]),
                const SizedBox(height: 10),
                SelectableText(e.value, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15, height: 1.5)),
                const SizedBox(height: 6),
                Text('${e.value.length} chars', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
              ]),
            )),
          ],
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiTextWriterScreen extends StatefulWidget {
  const AiTextWriterScreen({super.key});
  @override
  State<AiTextWriterScreen> createState() => _AiTextWriterScreenState();
}

class _AiTextWriterScreenState extends State<AiTextWriterScreen> {
  final _topicCtrl = TextEditingController();
  String _type = 'Blog Post';
  String _tone = 'Professional';
  String _language = 'English';
  String _output = '';
  bool _loading = false;

  final _types = ['Blog Post', 'Essay', 'Story', 'Email', 'Caption', 'Speech', 'Letter', 'Script'];
  final _tones = ['Professional', 'Casual', 'Funny', 'Emotional', 'Motivational', 'Formal'];
  final _languages = ['English', 'Hindi', 'Hinglish', 'Urdu', 'Marathi', 'Bengali'];

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_topicCtrl.text.trim().isEmpty) {
      _showSnack('Topic likhna bhool gaye!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final res = await ClaudeService.instance.writeText(_type, _topicCtrl.text.trim(), _tone, _language);
      if (!mounted) return;
      setState(() => _output = res);
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

  Widget _dropRow(String label, String val, List<String> opts, ValueChanged<String> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
        child: DropdownButton<String>(
          value: val, isExpanded: true, dropdownColor: AppTheme.cardBg2,
          underline: const SizedBox(),
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) { if (v != null) onChange(v); },
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Text Writer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          Text('Topic / Title', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _topicCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Topic likhao jiske baare mein likhna hai...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
              filled: true, fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 14),
          _dropRow('Content Type', _type, _types, (v) => setState(() => _type = v)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _dropRow('Tone', _tone, _tones, (v) => setState(() => _tone = v))),
            const SizedBox(width: 12),
            Expanded(child: _dropRow('Language', _language, _languages, (v) => setState(() => _language = v))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Likh raha hoon...' : 'Generate ✍️',
              onPressed: _generate,
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Generated Content', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              GestureDetector(
                onPressed: () { Clipboard.setData(ClipboardData(text: _output)); _showSnack('Copied!'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.copy, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('Copy', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: SelectableText(_output, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';
import '../../widgets/common_widgets.dart';

class AiNotesSummarizerScreen extends StatefulWidget {
  const AiNotesSummarizerScreen({super.key});
  @override
  State<AiNotesSummarizerScreen> createState() => _AiNotesSummarizerScreenState();
}

class _AiNotesSummarizerScreenState extends State<AiNotesSummarizerScreen> {
  final _inputCtrl = TextEditingController();
  String _summary = '';
  bool _loading = false;
  String _mode = 'Short';
  final _modes = ['Short', 'Detailed', 'Bullet Points', 'Key Terms'];

  Future<void> _summarize() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _summary = ''; });
    try {
      final prompt = _modePrompt(text);
      final result = await GeminiService.instance.chat(prompt);
      if (!mounted) return;
      setState(() => _summary = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _summary = '⚠️ Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _modePrompt(String text) {
    switch (_mode) {
      case 'Bullet Points':
        return 'Inhe notes ko bullet points mein summarize karo (Hindi/English mix allowed):\n\n$text';
      case 'Detailed':
        return 'Inhe notes ka detailed summary likho, saare important points cover karo:\n\n$text';
      case 'Key Terms':
        return 'Inhe notes se sirf key terms aur unke short definitions nikalo:\n\n$text';
      default:
        return 'Inhe notes ka ek chhota sa 3-5 line summary likho:\n\n$text';
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Notes Summarizer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_summary.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.purple),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _summary));
                _snack('Summary copied!');
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mode selector
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _modes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _modes[i] == _mode;
                  return GestureDetector(
                    onTap: () => setState(() => _mode = _modes[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.purple : AppTheme.cardBg2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppTheme.purple : AppTheme.borderColor),
                      ),
                      child: Text(_modes[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Input
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Apne notes yahan paste karo...',
                    hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _summarize,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.summarize_outlined),
                label: Text(_loading ? 'Summarizing...' : 'Summarize Notes', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Output
            if (_summary.isNotEmpty)
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.purple.withOpacity(0.5)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_summary, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

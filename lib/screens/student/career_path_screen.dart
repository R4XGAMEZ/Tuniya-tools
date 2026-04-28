import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class CareerPathScreen extends StatefulWidget {
  const CareerPathScreen({super.key});
  @override
  State<CareerPathScreen> createState() => _CareerPathScreenState();
}

class _CareerPathScreenState extends State<CareerPathScreen> {
  final _interestCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  String _education = '12th Pass';
  String _result = '';
  bool _loading = false;

  final _educations = ['10th Pass', '12th Pass', 'Graduate', 'Post Graduate', 'Dropout'];

  Future<void> _explore() async {
    if (_interestCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''Student Profile:
- Education: $_education
- Interests: ${_interestCtrl.text.trim()}
- Current Skills: ${_skillCtrl.text.trim().isEmpty ? 'Not specified' : _skillCtrl.text.trim()}

Top 5 best career paths suggest karo. Har career ke liye:
1. Career name
2. Kyun suit karega (2-3 lines)
3. Average salary (India)
4. Kaise shuru karein (steps)
5. Best courses/exams

Simple Hindi/English mix mein likho.''';
      final r = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() => _result = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = '⚠️ Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _interestCtrl.dispose(); _skillCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(backgroundColor: AppTheme.cardBg, title: Text('Career Path Explorer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education Level', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: _educations.map((e) {
              final sel = e == _education;
              return GestureDetector(
                onTap: () => setState(() => _education = e),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)), child: Text(e, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13))),
              );
            }).toList()),
            const SizedBox(height: 14),
            Text('Your Interests *', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(controller: _interestCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14), maxLines: 2,
                decoration: InputDecoration(hintText: 'e.g. Computers, Drawing, Sports, Cooking, Teaching...', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none)),
            ),
            const SizedBox(height: 10),
            Text('Current Skills (optional)', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(controller: _skillCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(hintText: 'e.g. Python, Photoshop, Public Speaking...', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _explore,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.explore_outlined),
                label: Text(_loading ? 'Exploring Careers...' : 'Explore Career Paths', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4))),
                child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7))),
            ],
          ],
        ),
      ),
    );
  }
}

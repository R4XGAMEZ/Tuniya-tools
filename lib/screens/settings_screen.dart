import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiCtrl = TextEditingController();
  final _claudeCtrl = TextEditingController();
  bool _geminiVisible = false;
  bool _claudeVisible = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final s = SettingsService();
    _geminiCtrl.text = s.geminiApiKey;
    _claudeCtrl.text = s.claudeApiKey;
  }

  @override
  void dispose() {
    _geminiCtrl.dispose();
    _claudeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = SettingsService();
    await s.setGeminiApiKey(_geminiCtrl.text.trim());
    await s.setClaudeApiKey(_claudeCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
            const SizedBox(width: 10),
            Text('API keys saved!', style: GoogleFonts.rajdhani(fontSize: 14)),
          ]),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gradientAppBar('SETTINGS'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── API Keys Section ──
            const SectionHeader(title: 'API KEYS', icon: Icons.vpn_key_outlined),
            const SizedBox(height: 16),

            _apiKeyCard(
              label: 'Gemini API Key',
              subtitle: 'AI Chat, Image Generator, YouTube Analyzer ke liye',
              badgeColor: Colors.blue,
              badgeText: 'Gemini Flash',
              controller: _geminiCtrl,
              visible: _geminiVisible,
              onToggle: () => setState(() => _geminiVisible = !_geminiVisible),
              hint: 'AIza... paste karo',
              helpUrl: 'https://aistudio.google.com/app/apikey',
            ),

            const SizedBox(height: 16),

            _apiKeyCard(
              label: 'Claude API Key',
              subtitle: 'AI Chat, Code Helper, PDF Summarizer ke liye',
              badgeColor: AppTheme.red,
              badgeText: 'Claude Sonnet',
              controller: _claudeCtrl,
              visible: _claudeVisible,
              onToggle: () => setState(() => _claudeVisible = !_claudeVisible),
              hint: 'sk-ant-... paste karo',
              helpUrl: 'https://console.anthropic.com/settings/keys',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: _saved ? 'Saved!' : 'Save API Keys',
                icon: _saved ? Icons.check : Icons.save_outlined,
                onPressed: _save,
              ),
            ),

            const SizedBox(height: 32),

            // ── Info Section ──
            const SectionHeader(title: 'INFO', icon: Icons.info_outline),
            const SizedBox(height: 16),

            _infoCard(Icons.shield_outlined, 'Your Keys are Safe',
                'API keys sirf aapke phone mein store hote hain. Kabhi bhi server par nahi jaate.'),
            const SizedBox(height: 12),
            _infoCard(Icons.cloud_outlined, 'Kahan se milega?',
                'Gemini: aistudio.google.com  |  Claude: console.anthropic.com\nDono free tier mein available hain.'),
            const SizedBox(height: 12),
            _infoCard(Icons.offline_bolt_outlined, 'Offline Tools',
                '100+ tools bina internet ke bhi kaam karte hain. Sirf AI tools ke liye keys chahiye.'),

            const SizedBox(height: 32),

            // ── About Section ──
            const SectionHeader(title: 'ABOUT', icon: Icons.apps_outlined),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TUNIYA TOOLS',
                              style: GoogleFonts.orbitron(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('v1.0.0  |  by R4XGAMEZ',
                              style: GoogleFonts.rajdhani(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppTheme.borderColor),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('130+', 'Tools'),
                      _statItem('Gemini', 'AI Image'),
                      _statItem('Claude', 'AI Text'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _apiKeyCard({
    required String label,
    required String subtitle,
    required Color badgeColor,
    required String badgeText,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
    required String hint,
    required String helpUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badgeText,
                    style: GoogleFonts.rajdhani(
                        color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _launchUrl(helpUrl),
                child: Text('Get Key',
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.purple, fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.purple)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: !visible,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: IconButton(
                icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(body,
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
          child: Text(value,
              style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Text(label,
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  void _launchUrl(String url) {
    // url_launcher se open karo
  }
}

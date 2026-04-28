import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/common_widgets.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _showSnack('Gemini API key Settings mein daal do pehle', isError: true);
      return;
    }
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _ctrl.clear();
    _scrollDown();
    try {
      final reply = await GeminiService.instance.chatMultiTurn(_messages);
      if (!mounted) return;
      setState(() => _messages.add({'role': 'model', 'text': reply}));
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add({'role': 'model', 'text': '⚠️ Error: $e'}));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  void _clearChat() {
    setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Chat', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.textSecondary),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(
        children: [
          if (!GeminiService.instance.isReady)
            ApiWarningBanner(needsGemini: true, needsClaude: false),
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) return _typingIndicator();
                      final m = _messages[i];
                      return _bubble(m['role'] == 'user', m['text'] ?? '');
                    },
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle),
          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Text('AI Chat', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Powered by Gemini Flash', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        ...[
          'Mujhe kuch sikhao', 'Meri help karo', 'Koi bhi sawaal poochho'
        ].map((hint) => GestureDetector(
              onTap: () { _ctrl.text = hint; },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(hint, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14), textAlign: TextAlign.center),
              ),
            )),
      ]),
    );
  }

  Widget _bubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          _showSnack('Copied!');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            gradient: isUser ? AppTheme.brandGradient : null,
            color: isUser ? null : AppTheme.cardBg2,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser ? null : Border.all(color: AppTheme.borderColor),
          ),
          child: Text(text, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, height: 1.5)),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 24, height: 16, child: LinearProgressIndicator(
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation(AppTheme.purple),
          )),
          const SizedBox(width: 8),
          Text('Soch raha hoon...', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(color: AppTheme.cardBg, border: Border(top: BorderSide(color: AppTheme.borderColor))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Kuch bhi poochho...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _loading ? null : _send,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/tool_item.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

/// Base screen template for every tool.
/// Usage: extend this and override [buildBody].
abstract class BaseToolScreen extends StatefulWidget {
  final String toolId;
  const BaseToolScreen({super.key, required this.toolId});
}

abstract class BaseToolScreenState<T extends BaseToolScreen> extends State<T> {
  ToolItem? get tool => ToolsData.byId(widget.toolId);
  bool isLoading = false;
  String? errorMsg;

  /// Override this to build tool content
  Widget buildBody(BuildContext context);

  @override
  void initState() {
    super.initState();
    // Track recently used tools
    SettingsService().addRecentTool(widget.toolId);
  }

  void setLoading(bool val) => setState(() => isLoading = val);
  void setError(String? msg) => setState(() => errorMsg = msg);

  void showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppTheme.red : Colors.greenAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.rajdhani(fontSize: 14))),
      ]),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> toggleFav() async {
    final t = tool;
    if (t == null) return;
    await SettingsService().toggleFav(t.id);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = tool;
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
          child: Text(t?.name ?? 'Tool',
              style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        actions: [
          if (t != null)
            IconButton(
              icon: Icon(
                SettingsService().isFav(t.id) ? Icons.star_rounded : Icons.star_outline_rounded,
                color: SettingsService().isFav(t.id) ? AppTheme.red : AppTheme.textSecondary,
              ),
              onPressed: toggleFav,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // API warning if needed
              if (t?.needsGemini == true || t?.needsClaude == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ApiWarningBanner(
                    needsGemini: t?.needsGemini ?? false,
                    needsClaude: t?.needsClaude ?? false,
                  ),
                ),
              // Error msg
              if (errorMsg != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(errorMsg!,
                            style: GoogleFonts.rajdhani(color: AppTheme.red, fontSize: 13))),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppTheme.red),
                          onPressed: () => setState(() => errorMsg = null),
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: buildBody(context).animate().fadeIn(duration: 300.ms),
              ),
            ],
          ),
          if (isLoading)
            const LoadingOverlay(),
        ],
      ),
    );
  }
}

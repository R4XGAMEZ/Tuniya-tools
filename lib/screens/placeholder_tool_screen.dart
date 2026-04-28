import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/tool_item.dart';
import '../widgets/common_widgets.dart';

/// Shown for tools whose screen is not yet built.
/// Replace with actual implementation screen.
class PlaceholderToolScreen extends StatelessWidget {
  final String toolId;
  const PlaceholderToolScreen({super.key, required this.toolId});

  @override
  Widget build(BuildContext context) {
    final tool = ToolsData.byId(toolId);
    return Scaffold(
      appBar: gradientAppBar(tool?.name ?? 'Tool'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.purple.withOpacity(0.4), blurRadius: 30),
                  ],
                ),
                child: Icon(tool?.icon ?? Icons.build_outlined,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text(tool?.name ?? toolId,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                      color: AppTheme.textPrimary, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(tool?.description ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
                ),
                child: Text('Coming Soon - Under Development',
                    style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 13)),
              ),
              if (tool?.needsGemini == true || tool?.needsClaude == true) ...[
                const SizedBox(height: 20),
                ApiWarningBanner(
                  needsGemini: tool?.needsGemini ?? false,
                  needsClaude: tool?.needsClaude ?? false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

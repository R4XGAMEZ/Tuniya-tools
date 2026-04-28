import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF120A20), Color(0xFF0A0A0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Glow top-left
            Positioned(
              top: -120, left: -120,
              child: Container(
                width: 380, height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.purple.withOpacity(0.35), Colors.transparent,
                  ]),
                ),
              ).animate().scale(duration: 2000.ms, curve: Curves.easeOut,
                  begin: const Offset(0.4, 0.4), end: const Offset(1.3, 1.3)),
            ),
            // Glow bottom-right
            Positioned(
              bottom: -100, right: -100,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.red.withOpacity(0.3), Colors.transparent,
                  ]),
                ),
              ).animate().scale(duration: 2200.ms, curve: Curves.easeOut,
                  begin: const Offset(0.4, 0.4), end: const Offset(1.2, 1.2)),
            ),

            // Main center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.brandGradient,
                      boxShadow: [
                        BoxShadow(color: AppTheme.purple.withOpacity(0.6),
                            blurRadius: 40, spreadRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 50),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // TUNIYA TOOLS text
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        AppTheme.brandGradient.createShader(bounds),
                    child: Text('TUNIYA TOOLS',
                      style: GoogleFonts.orbitron(
                        fontSize: 28, fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, duration: 600.ms,
                          curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  Text('by R4XGAMEZ',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary,
                      fontSize: 14, letterSpacing: 3,
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 50),

                  // Loading bar
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purple),
                        minHeight: 3,
                      ),
                    ),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // Version bottom
            Positioned(
              bottom: 32,
              left: 0, right: 0,
              child: Text('v1.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary.withOpacity(0.4),
                  fontSize: 12, letterSpacing: 2,
                ),
              ).animate(delay: 700.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

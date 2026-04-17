import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../models/lottery.dart';
import 'lotto_ball.dart';

// ── Style theme mapping ───────────────────────────────────────────────────────

class _StyleTheme {
  final List<Color> gradientColors;
  final Color accentColor;   // icon + bonus label colour
  final Color glowColor;     // subtle top-right glow

  const _StyleTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.glowColor,
  });
}

_StyleTheme _themeForStyle(PlayStyle style) => switch (style) {
      PlayStyle.hot => const _StyleTheme(
          gradientColors: [Color(0xFF7B1F00), Color(0xFFBF360C), Color(0xFF8D2800)],
          accentColor: Color(0xFFFFB74D),
          glowColor: Color(0x33FF6D00),
        ),
      PlayStyle.cold => const _StyleTheme(
          gradientColors: [Color(0xFF0D2B4E), Color(0xFF1565C0), Color(0xFF0A3D6B)],
          accentColor: Color(0xFF80DEEA),
          glowColor: Color(0x3300B0FF),
        ),
      PlayStyle.random => const _StyleTheme(
          gradientColors: [Color(0xFF1A0050), Color(0xFF4527A0), Color(0xFF311B92)],
          accentColor: Color(0xFFCE93D8),
          glowColor: Color(0x33AA00FF),
        ),
      PlayStyle.balanced => const _StyleTheme(
          gradientColors: [Color(0xFF1A0A3C), Color(0xFF4A148C), Color(0xFF2E0066)],
          accentColor: Color(0xFFFFD700),
          glowColor: Color(0x33FFD700),
        ),
    };

// ── Share card widget ─────────────────────────────────────────────────────────

class PickShareCard extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;

  const PickShareCard({super.key, required this.pick, required this.lottery});

  @override
  Widget build(BuildContext context) {
    final mainNums = pick.mainNumbers;
    final bonusNums = pick.bonusNumbers ?? [];
    final bonusLabel = switch (lottery.id) {
      'us_powerball' => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _ => 'Bonus',
    };
    final theme = _themeForStyle(pick.style);

    return SizedBox(
      width: 360,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            // ── Glow accent (top-right) ───────────────────────────
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.glowColor,
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Branding ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: theme.accentColor, size: 16),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'LottoRun ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: 'AI',
                            style: TextStyle(
                              color: theme.accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lottery.name,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Strategy tagline ──────────────────────────────────
                Text(
                  pick.style.tagline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  pick.style.taglineSubtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                // ── Main balls ────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children:
                      mainNums.map((n) => LottoBall(number: n, size: 54)).toList(),
                ),

                // ── Bonus ball ────────────────────────────────────────
                if (bonusNums.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bonusLabel,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ...bonusNums
                          .map((n) => LottoBall(number: n, isBonus: true, size: 54)),
                    ],
                  ),
                ],

                const SizedBox(height: 22),

                // ── Footer ────────────────────────────────────────────
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                const Text(
                  'Generated for fun · LottoRun AI · Just for fun, play responsibly.',
                  style: TextStyle(color: Colors.white30, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Capture + share utility ──────────────────────────────────────────────────

Future<void> sharePickCard({
  required GlobalKey repaintKey,
  required BuildContext btnContext,
}) async {
  // Capture position before any await to avoid BuildContext across async gaps.
  final box = btnContext.findRenderObject() as RenderBox?;
  final origin =
      box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final boundary = repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/lottorun_pick.png');
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My AI lottery pick 🎯 — Generated by LottoRun AI',
      sharePositionOrigin: origin,
    );
  } catch (e) {
    debugPrint('sharePickCard error: $e');
  }
}

Future<void> sharePickCards({
  required List<GlobalKey> repaintKeys,
  required BuildContext btnContext,
}) async {
  final box = btnContext.findRenderObject() as RenderBox?;
  final origin =
      box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final tempDir = await getTemporaryDirectory();
    final files = <XFile>[];

    for (var i = 0; i < repaintKeys.length; i++) {
      final boundary = repaintKeys[i].currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) continue;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) continue;

      final file = File('${tempDir.path}/lottorun_pick_${i + 1}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      files.add(XFile(file.path));
    }

    if (files.isEmpty) return;

    await Share.shareXFiles(
      files,
      text: 'My AI lottery picks 🎯 — Generated by LottoRun AI',
      sharePositionOrigin: origin,
    );
  } catch (e) {
    debugPrint('sharePickCards error: $e');
  }
}

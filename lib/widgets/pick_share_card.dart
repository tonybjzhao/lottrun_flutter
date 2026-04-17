import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../models/lottery.dart';
import 'lotto_ball.dart';

// ── Share card widget ─────────────────────────────────────────────────────────
// Rendered offscreen via Offstage + RepaintBoundary to produce a PNG.

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

    return SizedBox(
      width: 360,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E1070), Color(0xFF6A1B9A), Color(0xFF4A148C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Branding ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
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
                          color: Color(0xFFFFD700),
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
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
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

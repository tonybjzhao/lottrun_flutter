import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../services/pick_result_service.dart';

// ── Result variant ────────────────────────────────────────────────────────────

enum _Variant { almostWin, goodHit, miss }

_Variant _variantFor(int total) {
  if (total >= 3) return _Variant.almostWin;
  if (total >= 1) return _Variant.goodHit;
  return _Variant.miss;
}

int _beatPercent(int score) {
  // Rough fun percentile based on score (matchedMain*2 + suppHits)
  if (score >= 10) return 99;
  if (score >= 8)  return 96;
  if (score >= 6)  return 92;
  if (score >= 4)  return 83;
  if (score >= 3)  return 75;
  if (score >= 2)  return 65;
  if (score >= 1)  return 56;
  return 50;
}

// ── Public entry point ────────────────────────────────────────────────────────

class PickShareCard extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult? result;

  const PickShareCard({
    super.key,
    required this.pick,
    required this.lottery,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r != null && !r.isPending && r.drawMainNumbers.isNotEmpty) {
      return _ResultShareCard(pick: pick, lottery: lottery, result: r);
    }
    return _PickOnlyShareCard(pick: pick, lottery: lottery);
  }
}

// ── Result share card ─────────────────────────────────────────────────────────

class _ResultShareCard extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult result;

  const _ResultShareCard({
    required this.pick,
    required this.lottery,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isSupp     = lottery.bonusIsSupplementary;
    final matchMain  = result.matchedMain;
    final suppHits   = result.suppCategoryHits(lottery);
    final total      = matchMain + (isSupp ? suppHits : result.matchedBonus);
    final variant    = _variantFor(total);
    final score      = result.score;
    final beatPct    = _beatPercent(score);

    final drawMain   = result.drawMainNumbers;
    final drawSupp   = result.drawBonusNumbers ?? [];
    final userMain   = pick.mainNumbers;

    final matchedMainSet = result.matchedMainNumbers.toSet();
    final matchedSuppSet = result.matchedMainInDrawSupp.toSet();

    // ── Variant config ─────────────────────────────────────────────────────
    final String headline;
    final String subline;
    final String emoji;

    switch (variant) {
      case _Variant.almostWin:
        headline = 'So close!';
        subline  = _matchDesc(matchMain, suppHits, isSupp, result.matchedBonus, lottery);
        emoji    = '🔥';
      case _Variant.goodHit:
        headline = 'Nice hit!';
        subline  = 'You hit $total number${total == 1 ? '' : 's'}';
        emoji    = '🎯';
      case _Variant.miss:
        headline = 'Oops!';
        subline  = 'Better luck next time 😊';
        emoji    = '😆';
    }

    // Purple gradient — consistent across all variants
    const bgTop    = Color(0xFF2D0B6B);
    const bgBottom = Color(0xFF4A1A8C);

    return SizedBox(
      width: 360,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Background glow ──────────────────────────────────────────────
            Positioned(
              top: -40,
              left: -20,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x55FFD700), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x44AA44FF), Colors.transparent],
                  ),
                ),
              ),
            ),
            // ── Confetti particles (static) ──────────────────────────────────
            ..._confettiParticles(),

            // ── Content ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top bar: flag + lottery name | LottoRun AI
                  _topBar(lottery),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subline,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  // User pick balls (color-coded)
                  _userBallRow(userMain, matchedMainSet, matchedSuppSet),
                  const SizedBox(height: 10),
                  _legend(),

                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 14),

                  // Draw result
                  const Text(
                    'Draw result',
                    style: TextStyle(
                      color: Color(0xFFBBAAFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _drawBallRow(drawMain, drawSupp, isSupp),

                  const SizedBox(height: 20),

                  // Bottom motivation card
                  _motivationCard(variant, beatPct, total),

                  const SizedBox(height: 16),

                  // Footer
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _topBar(Lottery lottery) {
    final flag = switch (lottery.countryCode) {
      'AU' => '🇦🇺',
      'US' => '🇺🇸',
      _    => '🌍',
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$flag ${_lotteryShortName(lottery.name)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Text(
          'LottoRun AI',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _lotteryShortName(String name) {
    // Break long names onto two implied lines via newline label
    if (name.contains('Saturday')) return 'Saturday\nLotto';
    if (name.contains('Oz')) return 'Oz Lotto';
    if (name.contains('Powerball')) return 'Powerball';
    if (name.contains('Mega')) return 'Mega Millions';
    return name;
  }

  // ── User pick balls ───────────────────────────────────────────────────────

  Widget _userBallRow(
    List<int> nums,
    Set<int> matchedMain,
    Set<int> matchedSupp,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < nums.length; i++) ...[
          _ball(
            nums[i],
            matchedMain.contains(nums[i])
                ? _BallKind.mainHit
                : matchedSupp.contains(nums[i])
                    ? _BallKind.suppHit
                    : _BallKind.miss,
            size: 44,
          ),
          if (i < nums.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  // ── Legend ────────────────────────────────────────────────────────────────

  Widget _legend() {
    const style = TextStyle(color: Colors.white60, fontSize: 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(const Color(0xFFE53935)),
        const SizedBox(width: 4),
        const Text('main match', style: style),
        const SizedBox(width: 12),
        _dot(const Color(0xFF1A5FA8)),
        const SizedBox(width: 4),
        const Text('supp match', style: style),
        const SizedBox(width: 12),
        _dot(const Color(0xFFBDBDBD)),
        const SizedBox(width: 4),
        const Text('no match', style: style),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );

  // ── Draw result balls ─────────────────────────────────────────────────────

  Widget _drawBallRow(List<int> main, List<int> supp, bool isSupp) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < main.length; i++) ...[
              _ball(main[i], _BallKind.drawMain, size: 40),
              if (i < main.length - 1) const SizedBox(width: 5),
            ],
          ],
        ),
        if (isSupp && supp.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('+', style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              for (var i = 0; i < supp.length; i++) ...[
                _ball(supp[i], _BallKind.drawSupp, size: 34),
                if (i < supp.length - 1) const SizedBox(width: 5),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // ── Motivation card ───────────────────────────────────────────────────────

  Widget _motivationCard(_Variant variant, int beatPct, int total) {
    switch (variant) {
      case _Variant.almostWin:
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You beat $beatPct% of players!',
                      style: const TextStyle(
                        color: Color(0xFF2D0B6B),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Every number brings you closer\nto your dream ✨',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case _Variant.goodHit:
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Great pick!\nKeep it going!',
                      style: TextStyle(
                        color: Color(0xFF2D0B6B),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Consistency today,\nbig win tomorrow 💪',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case _Variant.miss:
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4), // sticky-note yellow
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFEE58), width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Today: practice',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Tomorrow: jackpot!',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '🙂',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _footer() {
    return Column(
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✨', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            Text(
              'LottoRun AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 3),
        Text(
          'Smart picks from real draw history',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        SizedBox(height: 6),
        Text(
          '💜  Play responsibly. It\'s all about the fun.',
          style: TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }
}

// ── Ball kind + renderer ──────────────────────────────────────────────────────

enum _BallKind { mainHit, suppHit, miss, drawMain, drawSupp }

Widget _ball(int number, _BallKind kind, {required double size}) {
  final List<Color> colors;
  final Color shadow;
  final Color text;

  switch (kind) {
    case _BallKind.mainHit:
      colors = [const Color(0xFFEF5350), const Color(0xFFB71C1C)];
      shadow = const Color(0xFFB71C1C);
      text   = Colors.white;
    case _BallKind.suppHit:
      colors = [const Color(0xFF5C9FD6), const Color(0xFF1A5FA8)];
      shadow = const Color(0xFF1A5FA8);
      text   = Colors.white;
    case _BallKind.miss:
      colors = [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)];
      shadow = const Color(0xFFBDBDBD);
      text   = const Color(0xFF888888);
    case _BallKind.drawMain:
      colors = [const Color(0xFFEF5350), const Color(0xFFB71C1C)];
      shadow = const Color(0xFFB71C1C);
      text   = Colors.white;
    case _BallKind.drawSupp:
      colors = [const Color(0xFF5C9FD6), const Color(0xFF1A5FA8)];
      shadow = const Color(0xFF1A5FA8);
      text   = Colors.white;
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.85,
        colors: colors,
      ),
      boxShadow: [
        BoxShadow(
          color: shadow.withAlpha(130),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      '$number',
      style: TextStyle(
        fontSize: size * 0.37,
        fontWeight: FontWeight.w800,
        color: text,
        letterSpacing: -0.5,
      ),
    ),
  );
}

// ── Confetti particles (static decorative dots/shapes) ───────────────────────

List<Widget> _confettiParticles() {
  const particles = [
    (dx: 30.0,  dy: 60.0,  size: 6.0,  color: Color(0xAAFFD700), angle: 0.3),
    (dx: 310.0, dy: 40.0,  size: 5.0,  color: Color(0xAA9C27B0), angle: 0.8),
    (dx: 50.0,  dy: 110.0, size: 4.0,  color: Color(0xAAFF6090), angle: 1.2),
    (dx: 290.0, dy: 90.0,  size: 7.0,  color: Color(0xAAFFD700), angle: 0.5),
    (dx: 20.0,  dy: 160.0, size: 4.0,  color: Color(0xAA64B5F6), angle: 1.8),
    (dx: 320.0, dy: 150.0, size: 5.0,  color: Color(0xAAFFD700), angle: 2.1),
    (dx: 60.0,  dy: 200.0, size: 3.0,  color: Color(0xAA9C27B0), angle: 0.7),
    (dx: 280.0, dy: 200.0, size: 4.0,  color: Color(0xAAFF6090), angle: 1.5),
    (dx: 330.0, dy: 280.0, size: 5.0,  color: Color(0xAAFFD700), angle: 0.2),
    (dx: 15.0,  dy: 300.0, size: 3.0,  color: Color(0xAA64B5F6), angle: 2.5),
  ];

  return particles.map((p) {
    return Positioned(
      left: p.dx,
      top: p.dy,
      child: Transform.rotate(
        angle: p.angle,
        child: Container(
          width: p.size,
          height: p.size * 1.6,
          decoration: BoxDecoration(
            color: p.color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }).toList();
}

// ── Match description helper ──────────────────────────────────────────────────

String _matchDesc(
  int matchMain,
  int suppHits,
  bool isSupp,
  int matchedBonus,
  Lottery lottery,
) {
  if (!isSupp) {
    if (matchedBonus > 0 && matchMain > 0) {
      return '$matchMain main + ${lottery.bonusLabel ?? 'Bonus'} matched';
    }
    if (matchedBonus > 0) return '${lottery.bonusLabel ?? 'Bonus'} matched';
    return '$matchMain matched';
  }
  if (matchMain == 0) return '$suppHits supp matched';
  if (suppHits == 0) return '$matchMain main matched';
  return '$matchMain main + $suppHits supp matched';
}

// ── Original pick-only share card (shown when no result available) ─────────────

class _PickOnlyShareCard extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;

  const _PickOnlyShareCard({required this.pick, required this.lottery});

  @override
  Widget build(BuildContext context) {
    final mainNums  = pick.mainNumbers;
    final bonusNums = pick.bonusNumbers ?? [];
    final bonusLabel = switch (lottery.id) {
      'us_powerball'    => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _                 => 'Bonus',
    };
    final theme = _styleThemeFor(pick.style);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: theme.accentColor, size: 16),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: 'LottoRun ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(lottery.name, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                Text(
                  pick.style.tagline,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  pick.style.taglineSubtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: mainNums.map((n) => _ball(n, _BallKind.drawMain, size: 54)).toList(),
                ),
                if (bonusNums.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(bonusLabel, style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.w700, fontSize: 12)),
                      const SizedBox(width: 10),
                      ...bonusNums.map((n) => _ball(n, _BallKind.suppHit, size: 54)),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
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

// ── Style theme for pick-only card ────────────────────────────────────────────

class _StyleTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final Color glowColor;
  const _StyleTheme({required this.gradientColors, required this.accentColor, required this.glowColor});
}

_StyleTheme _styleThemeFor(PlayStyle style) => switch (style) {
      PlayStyle.hot => const _StyleTheme(
          gradientColors: [Color(0xFF7B1F00), Color(0xFFBF360C), Color(0xFF8D2800)],
          accentColor: Color(0xFFFFB74D), glowColor: Color(0x33FF6D00)),
      PlayStyle.cold => const _StyleTheme(
          gradientColors: [Color(0xFF0D2B4E), Color(0xFF1565C0), Color(0xFF0A3D6B)],
          accentColor: Color(0xFF80DEEA), glowColor: Color(0x3300B0FF)),
      PlayStyle.random => const _StyleTheme(
          gradientColors: [Color(0xFF1A0050), Color(0xFF4527A0), Color(0xFF311B92)],
          accentColor: Color(0xFFCE93D8), glowColor: Color(0x33AA00FF)),
      PlayStyle.balanced => const _StyleTheme(
          gradientColors: [Color(0xFF1A0A3C), Color(0xFF4A148C), Color(0xFF2E0066)],
          accentColor: Color(0xFFFFD700), glowColor: Color(0x33FFD700)),
    };

// ── Capture + share utility ──────────────────────────────────────────────────

Future<void> sharePickCard({
  required GlobalKey repaintKey,
  required BuildContext btnContext,
  PickMatchResult? result,
  Lottery? lottery,
}) async {
  final box = btnContext.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image    = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final tempDir  = await getTemporaryDirectory();
    final file     = File('${tempDir.path}/lottorun_pick.png');
    await file.writeAsBytes(pngBytes);

    final shareText = _shareText(result, lottery);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
      sharePositionOrigin: origin,
    );
  } catch (e) {
    debugPrint('sharePickCard error: $e');
  }
}

String _shareText(PickMatchResult? result, Lottery? lottery) {
  if (result == null || result.isPending) {
    return 'My AI lottery pick 🎯 — Generated by LottoRun AI';
  }
  final isSupp  = lottery?.bonusIsSupplementary ?? false;
  final total   = result.matchedMain + (isSupp ? result.suppCategoryHits(lottery!) : result.matchedBonus);
  final variant = _variantFor(total);
  return switch (variant) {
    _Variant.almostWin => '🔥 So close! Check my LottoRun AI lottery pick!',
    _Variant.goodHit   => '🎯 Nice hit! Check my LottoRun AI lottery pick!',
    _Variant.miss      => '😆 Better luck next time! My AI lottery pick — LottoRun AI',
  };
}

Future<void> sharePickCards({
  required List<GlobalKey> repaintKeys,
  required BuildContext btnContext,
}) async {
  final box    = btnContext.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final tempDir = await getTemporaryDirectory();
    final files   = <XFile>[];

    for (var i = 0; i < repaintKeys.length; i++) {
      final boundary = repaintKeys[i].currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) continue;

      final image    = await boundary.toImage(pixelRatio: 3.0);
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

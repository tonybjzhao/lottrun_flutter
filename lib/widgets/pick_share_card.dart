import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../services/pick_result_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// § 1  Public template enum
// ─────────────────────────────────────────────────────────────────────────────

/// Three visually distinct share card templates.
///
/// Selected automatically by [selectTemplate] based on result quality.
/// Pass a [GlobalKey<ShareCardGeneratorState>] to [ShareCardGenerator] and call
/// `key.currentState?.share()` or `key.currentState?.exportImage()`.
enum ShareCardTemplate {
  /// ≥ 3 total matches — dark-gold dramatic "SO CLOSE!" card.
  fire,

  /// 1–2 total matches — navy + electric-blue stats card.
  electric,

  /// 0 matches / pending / pick-only — warm motivational card.
  warm,
}

// ─────────────────────────────────────────────────────────────────────────────
// § 2  Auto-switch selector
// ─────────────────────────────────────────────────────────────────────────────

/// Picks the right template given the current pick + result.
///
/// Rules:
/// - No result / pending / empty draw data → [ShareCardTemplate.warm]
/// - Total hits ≥ 3 → [ShareCardTemplate.fire]
/// - Total hits 1–2 → [ShareCardTemplate.electric]
/// - Total hits 0 → [ShareCardTemplate.warm]
ShareCardTemplate selectTemplate(
  GeneratedPick pick,
  PickMatchResult? result,
  Lottery lottery,
) {
  if (result == null || result.isPending || result.drawMainNumbers.isEmpty) {
    return ShareCardTemplate.warm;
  }
  final isSupp = lottery.bonusIsSupplementary;
  final total  = result.matchedMain +
      (isSupp ? result.suppCategoryHits(lottery) : result.matchedBonus);
  if (total >= 3) return ShareCardTemplate.fire;
  if (total >= 1) return ShareCardTemplate.electric;
  return ShareCardTemplate.warm;
}

// ─────────────────────────────────────────────────────────────────────────────
// § 3  ShareCardGenerator — self-contained generator widget
// ─────────────────────────────────────────────────────────────────────────────

/// Production-ready share card generator.
///
/// Owns its [RepaintBoundary]. Access the [ShareCardGeneratorState] via a
/// [GlobalKey<ShareCardGeneratorState>] to export or share the card.
///
/// ```dart
/// final _key = GlobalKey<ShareCardGeneratorState>();
///
/// // Embed (can be off-screen):
/// ShareCardGenerator(key: _key, pick: pick, lottery: lottery, result: result)
///
/// // Capture PNG bytes:
/// final bytes = await _key.currentState?.exportImage();
///
/// // Share via platform sheet:
/// await _key.currentState?.share();
/// ```
class ShareCardGenerator extends StatefulWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult? result;

  const ShareCardGenerator({
    super.key,
    required this.pick,
    required this.lottery,
    this.result,
  });

  @override
  State<ShareCardGenerator> createState() => ShareCardGeneratorState();
}

class ShareCardGeneratorState extends State<ShareCardGenerator> {
  final _repaintKey = GlobalKey();

  /// Which template is currently active.
  ShareCardTemplate get template =>
      selectTemplate(widget.pick, widget.result, widget.lottery);

  /// Captures the card as raw PNG bytes.
  ///
  /// [pixelRatio] 3.0 produces a 1080-px-wide image from the 360-pt card.
  /// Returns null if the widget has not been laid out yet.
  Future<Uint8List?> exportImage({double pixelRatio = 3.0}) async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image    = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Captures and shares via the platform share sheet.
  ///
  /// [sharePositionOrigin] positions the iPad share popover.
  Future<void> share({Rect? sharePositionOrigin}) async {
    final bytes = await exportImage();
    if (bytes == null) return;
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/lottorun_share.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: _shareText(widget.result, widget.lottery),
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r         = widget.result;
    final hasResult = r != null && !r.isPending && r.drawMainNumbers.isNotEmpty;

    final Widget card = switch (template) {
      ShareCardTemplate.fire     => _FireTemplate(pick: widget.pick, lottery: widget.lottery, result: r!),
      ShareCardTemplate.electric => _ElectricTemplate(pick: widget.pick, lottery: widget.lottery, result: r!),
      ShareCardTemplate.warm     => _WarmTemplate(pick: widget.pick, lottery: widget.lottery, result: hasResult ? r : null),
    };

    return RepaintBoundary(key: _repaintKey, child: card);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// § 4  Template A — Fire  (almostWin ≥ 3 total hits)
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual identity: near-black background, gold ambient glow, huge fraction
// score, dramatic "SO CLOSE! 🔥" copy, gold-bordered stat card.

class _FireTemplate extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult result;

  const _FireTemplate({
    required this.pick,
    required this.lottery,
    required this.result,
  });

  static const _bg1  = Color(0xFF0D0D0D);
  static const _bg2  = Color(0xFF1C0A00);
  static const _gold = Color(0xFFFFD700);
  static const _goldDim = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final isSupp    = lottery.bonusIsSupplementary;
    final matchMain = result.matchedMain;
    final suppHits  = result.suppCategoryHits(lottery);
    final total     = matchMain + (isSupp ? suppHits : result.matchedBonus);
    final beatPct   = _beatPercent(result.score);
    final mainCount = lottery.mainCount;

    final drawMain = result.drawMainNumbers;
    final drawSupp = result.drawBonusNumbers ?? [];
    final userMain = pick.mainNumbers;

    final matchedMainSet = result.matchedMainNumbers.toSet();
    final matchedSuppSet = result.matchedMainInDrawSupp.toSet();

    return SizedBox(
      width: 360,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg1, _bg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Ambient glow top-right ─────────────────────────────────────
            Positioned(
              top: -70, right: -70,
              child: Container(
                width: 280, height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x55FFD700), Colors.transparent],
                  ),
                ),
              ),
            ),
            // ── Warm glow bottom-left ──────────────────────────────────────
            Positioned(
              bottom: -50, left: -50,
              child: Container(
                width: 200, height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x33FF6B00), Colors.transparent],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  _topBar(),
                  const SizedBox(height: 16),

                  // ── RESULT pill ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: _gold.withAlpha(90)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'R E S U L T',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Big fraction score ────────────────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: '$total',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -3,
                        ),
                      ),
                      TextSpan(
                        text: ' / $mainCount',
                        style: const TextStyle(
                          color: _goldDim,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'SO CLOSE! 🔥',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Gold horizontal rule ──────────────────────────────────
                  Container(
                    height: 1.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, _gold, Colors.transparent],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── User pick balls ───────────────────────────────────────
                  _sectionLabel('YOUR NUMBERS', _gold),
                  const SizedBox(height: 8),
                  _ballRow(userMain, (n) {
                    if (matchedMainSet.contains(n)) return _BallKind.mainHit;
                    if (matchedSuppSet.contains(n)) return _BallKind.suppHit;
                    return _BallKind.miss;
                  }, size: 48),

                  const SizedBox(height: 16),

                  // ── Draw numbers ──────────────────────────────────────────
                  _sectionLabel('DRAW RESULT', Colors.white30),
                  const SizedBox(height: 8),
                  _ballRow(drawMain, (_) => _BallKind.drawMain, size: 38),
                  if (isSupp && drawSupp.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _ballRow(drawSupp, (_) => _BallKind.drawSupp, size: 32),
                  ],

                  const SizedBox(height: 22),

                  // ── Gold stat card ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                    decoration: BoxDecoration(
                      color: _gold.withAlpha(18),
                      border: Border.all(color: _gold.withAlpha(80)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You beat $beatPct% of players 🏆',
                          style: const TextStyle(
                            color: _gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _matchDesc(matchMain, suppHits, isSupp,
                              result.matchedBonus, lottery),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Can you beat this? 👀',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() => Row(children: [
        Text(
          '${_flagEmoji(lottery.countryCode)}  ${_lotteryShortName(lottery.name)}',
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _gold.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('LottoRun AI',
              style: TextStyle(
                  color: _gold, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _footer() => const Column(children: [
        Text('🔥  LottoRun AI  ·  Try your luck 🍀',
            style: TextStyle(color: Colors.white30, fontSize: 10)),
        SizedBox(height: 4),
        Text("Play responsibly. It's all about the fun.",
            style: TextStyle(color: Colors.white15, fontSize: 9)),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// § 5  Template B — Electric  (goodHit 1–2 total hits)
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual identity: deep navy, electric-cyan accent, diagonal corner accent,
// circular score badge, match-progress bar, stats-card aesthetic.

class _ElectricTemplate extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult result;

  const _ElectricTemplate({
    required this.pick,
    required this.lottery,
    required this.result,
  });

  static const _bg   = Color(0xFF08122A);
  static const _cyan = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    final isSupp    = lottery.bonusIsSupplementary;
    final matchMain = result.matchedMain;
    final suppHits  = result.suppCategoryHits(lottery);
    final total     = matchMain + (isSupp ? suppHits : result.matchedBonus);
    final beatPct   = _beatPercent(result.score);
    final mainCount = lottery.mainCount;

    final drawMain = result.drawMainNumbers;
    final drawSupp = result.drawBonusNumbers ?? [];
    final userMain = pick.mainNumbers;

    final matchedMainSet = result.matchedMainNumbers.toSet();
    final matchedSuppSet = result.matchedMainInDrawSupp.toSet();

    return SizedBox(
      width: 360,
      child: Container(
        color: _bg,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            // ── Diagonal accent top-right ─────────────────────────────────
            Positioned(
              top: 0, right: 0,
              child: CustomPaint(
                size: const Size(160, 120),
                painter: _DiagonalAccentPainter(color: const Color(0xFF0D2040)),
              ),
            ),
            // ── Cyan glow bottom-right ────────────────────────────────────
            Positioned(
              bottom: -60, right: -60,
              child: Container(
                width: 200, height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x2200E5FF), Colors.transparent],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  _topBar(),
                  const SizedBox(height: 22),

                  // ── Score badge + labels row ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular score
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _cyan, width: 2.5),
                          color: _cyan.withAlpha(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                color: _cyan,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'of $mainCount',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡ MATCHED',
                              style: TextStyle(
                                color: _cyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _matchDesc(matchMain, suppHits, isSupp,
                                  result.matchedBonus, lottery),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _matchProgressBar(total, mainCount),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── User pick balls ───────────────────────────────────────
                  _sectionLabel('YOUR PICK', Colors.white30),
                  const SizedBox(height: 8),
                  _ballRow(userMain, (n) {
                    if (matchedMainSet.contains(n)) return _BallKind.mainHit;
                    if (matchedSuppSet.contains(n)) return _BallKind.suppHit;
                    return _BallKind.miss;
                  }, size: 44),

                  const SizedBox(height: 16),

                  // ── Draw numbers ──────────────────────────────────────────
                  _sectionLabel('DRAW RESULT', Colors.white30),
                  const SizedBox(height: 8),
                  _ballRow(drawMain, (_) => _BallKind.drawMain, size: 36),
                  if (isSupp && drawSupp.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _ballRow(drawSupp, (_) => _BallKind.drawSupp, size: 30),
                  ],

                  const SizedBox(height: 20),

                  // ── Stat card ─────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1E3A),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: const Color(0xFF1A3A5C)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Better than $beatPct% of players! 🎯',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Can you beat this? 👀',
                                style: TextStyle(
                                  color: _cyan,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _cyan.withAlpha(25),
                            border: Border.all(color: _cyan.withAlpha(70)),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: _cyan, size: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchProgressBar(int matched, int total) {
    return LayoutBuilder(builder: (_, c) {
      return Stack(
        children: [
          Container(
            height: 6,
            width: c.maxWidth,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          FractionallySizedBox(
            widthFactor: matched / total.clamp(1, 99),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: _cyan,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: _cyan.withAlpha(100), blurRadius: 6)
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _topBar() => Row(children: [
        Text(
          '${_flagEmoji(lottery.countryCode)}  ${_lotteryShortName(lottery.name)}',
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        const Text('LottoRun AI',
            style: TextStyle(
                color: Colors.white30,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]);

  Widget _footer() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_rounded, color: _cyan.withAlpha(120), size: 13),
          const SizedBox(width: 4),
          Text('LottoRun AI  ·  Play for fun 🍀',
              style: TextStyle(color: _cyan.withAlpha(110), fontSize: 10)),
        ],
      );
}

/// Triangle painter for the electric template's top-right diagonal accent.
class _DiagonalAccentPainter extends CustomPainter {
  final Color color;
  const _DiagonalAccentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_DiagonalAccentPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// § 6  Template C — Warm  (miss / pending / pick-only)
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual identity: style-themed gradient (or deep red for miss), large emoji
// header, centred ball display, motivational or pick-strategy copy.
//
// Three internal sub-states:
//   miss      → result present, 0 total hits — humorous + "try again"
//   pending   → result present, isPending true — anticipation
//   pick-only → result null — strategy showcase

class _WarmTemplate extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult? result;

  const _WarmTemplate({
    required this.pick,
    required this.lottery,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = _styleThemeFor(pick.style);
    final isMiss    = result != null && !result!.isPending;
    final isPending = result?.isPending == true;
    final userMain  = pick.mainNumbers;
    final bonusNums = pick.bonusNumbers ?? [];
    final isSupp    = lottery.bonusIsSupplementary;

    final String emoji;
    final String headline;
    final String subhead;
    final String? blurbText;

    if (isMiss) {
      emoji    = '😂';
      headline = 'Well… not today';
      subhead  = 'But the next draw is waiting! 🎊';
      blurbText = null;
    } else if (isPending) {
      emoji    = '⏳';
      headline = 'Draw day incoming!';
      subhead  = 'Fingers crossed 🤞';
      blurbText = pick.style.taglineSubtitle;
    } else {
      emoji    = _styleEmoji(pick.style);
      headline = pick.style.label;
      subhead  = 'AI-generated lucky numbers 🤖';
      blurbText = pick.style.taglineSubtitle;
    }

    final bonusLabel = switch (lottery.id) {
      'au_powerball'    => 'Powerball',
      'us_powerball'    => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _                 => 'Bonus',
    };

    final List<Color> gradColors = isMiss
        ? const [Color(0xFF4A0010), Color(0xFF8B0030), Color(0xFFB03050)]
        : theme.gradientColors;

    return SizedBox(
      width: 360,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -40, right: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.glowColor,
                ),
              ),
            ),
            if (!isMiss) ..._confettiParticles(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  _topBar(theme),
                  const SizedBox(height: 22),

                  // ── Emoji + headline ──────────────────────────────────────
                  Text(emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subhead,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // ── Ball display ──────────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: userMain
                        .map((n) => _ball(n, _BallKind.drawMain, size: 50))
                        .toList(),
                  ),
                  if (!isSupp && bonusNums.isNotEmpty) ...[
                    const SizedBox(height: 12),
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
                        ...bonusNums.map((n) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: _ball(n, _BallKind.suppHit, size: 50),
                            )),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Bottom card (miss vs strategy) ────────────────────────
                  if (isMiss)
                    _missCard()
                  else if (blurbText != null)
                    _strategyCard(blurbText, theme),

                  const SizedBox(height: 20),

                  // ── Footer ────────────────────────────────────────────────
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 10),
                  Text(
                    isMiss
                        ? 'Tomorrow is a new draw! Play again with LottoRun AI'
                        : 'Try your luck with AI-powered picks 🍀',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "💜  Play responsibly. It's all about the fun.",
                    style: TextStyle(color: Colors.white30, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _missCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFEE58), width: 1.5),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today: practice\nTomorrow: jackpot! 🙂',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Can you beat this? 👀',
              style: TextStyle(
                color: Color(0xFF7B2FBE),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );

  Widget _strategyCard(String copy, _StyleTheme theme) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(45)),
        ),
        child: Text(
          copy,
          style: const TextStyle(
              color: Colors.white80, fontSize: 13, height: 1.4),
          textAlign: TextAlign.center,
        ),
      );

  Widget _topBar(_StyleTheme theme) => Row(children: [
        Text(
          '${_flagEmoji(lottery.countryCode)}  ${lottery.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const Spacer(),
        const Text('LottoRun AI',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]);

  String _styleEmoji(PlayStyle style) => switch (style) {
        PlayStyle.hot      => '🔥',
        PlayStyle.cold     => '❄️',
        PlayStyle.balanced => '⚖️',
        PlayStyle.random   => '🎲',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// § 7  Shared ball renderer
// ─────────────────────────────────────────────────────────────────────────────

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

/// Renders a horizontal row of balls with adaptive spacing.
Widget _ballRow(
  List<int> numbers,
  _BallKind Function(int n) kindFor, {
  required double size,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < numbers.length; i++) ...[
        _ball(numbers[i], kindFor(numbers[i]), size: size),
        if (i < numbers.length - 1) SizedBox(width: (size * 0.13).clamp(4, 8)),
      ],
    ],
  );
}

/// Small uppercase section label.
Widget _sectionLabel(String text, Color color) => Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// § 8  Shared pure helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Fun beat-percentile based on [score] (matchedMain×2 + suppHits + bonus×2).
int _beatPercent(int score) {
  if (score >= 10) return 99;
  if (score >= 8)  return 96;
  if (score >= 6)  return 92;
  if (score >= 4)  return 83;
  if (score >= 3)  return 75;
  if (score >= 2)  return 65;
  if (score >= 1)  return 56;
  return 50;
}

/// Factual match description used in stat cards.
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
  if (suppHits == 0)  return '$matchMain main matched';
  return '$matchMain main + $suppHits supp matched';
}

String _flagEmoji(String countryCode) => switch (countryCode) {
      'AU' => '🇦🇺',
      'US' => '🇺🇸',
      _    => '🌍',
    };

String _lotteryShortName(String name) {
  if (name.contains('Saturday')) return 'Saturday\nLotto';
  if (name.contains('Oz'))       return 'Oz Lotto';
  if (name.contains('Powerball'))return 'Powerball';
  if (name.contains('Mega'))     return 'Mega Millions';
  return name;
}

// ─────────────────────────────────────────────────────────────────────────────
// § 9  Confetti particles (shared decorative layer)
// ─────────────────────────────────────────────────────────────────────────────

List<Widget> _confettiParticles() {
  const particles = [
    (dx: 28.0,  dy: 55.0,  size: 6.0, color: Color(0xAAFFD700), angle: 0.3),
    (dx: 308.0, dy: 38.0,  size: 5.0, color: Color(0xAA9C27B0), angle: 0.8),
    (dx: 48.0,  dy: 108.0, size: 4.0, color: Color(0xAAFF6090), angle: 1.2),
    (dx: 288.0, dy: 88.0,  size: 7.0, color: Color(0xAAFFD700), angle: 0.5),
    (dx: 18.0,  dy: 158.0, size: 4.0, color: Color(0xAA64B5F6), angle: 1.8),
    (dx: 318.0, dy: 148.0, size: 5.0, color: Color(0xAAFFD700), angle: 2.1),
    (dx: 58.0,  dy: 198.0, size: 3.0, color: Color(0xAA9C27B0), angle: 0.7),
    (dx: 278.0, dy: 198.0, size: 4.0, color: Color(0xAAFF6090), angle: 1.5),
    (dx: 328.0, dy: 278.0, size: 5.0, color: Color(0xAAFFD700), angle: 0.2),
    (dx: 14.0,  dy: 298.0, size: 3.0, color: Color(0xAA64B5F6), angle: 2.5),
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

// ─────────────────────────────────────────────────────────────────────────────
// § 10  Style theme (pick-only / warm template)
// ─────────────────────────────────────────────────────────────────────────────

class _StyleTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final Color glowColor;
  const _StyleTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.glowColor,
  });
}

_StyleTheme _styleThemeFor(PlayStyle style) => switch (style) {
      PlayStyle.hot => const _StyleTheme(
          gradientColors: [Color(0xFF7B1F00), Color(0xFFBF360C), Color(0xFF8D2800)],
          accentColor: Color(0xFFFFB74D),
          glowColor: Color(0x33FF6D00)),
      PlayStyle.cold => const _StyleTheme(
          gradientColors: [Color(0xFF0D2B4E), Color(0xFF1565C0), Color(0xFF0A3D6B)],
          accentColor: Color(0xFF80DEEA),
          glowColor: Color(0x3300B0FF)),
      PlayStyle.random => const _StyleTheme(
          gradientColors: [Color(0xFF1A0050), Color(0xFF4527A0), Color(0xFF311B92)],
          accentColor: Color(0xFFCE93D8),
          glowColor: Color(0x33AA00FF)),
      PlayStyle.balanced => const _StyleTheme(
          gradientColors: [Color(0xFF1A0A3C), Color(0xFF4A148C), Color(0xFF2E0066)],
          accentColor: Color(0xFFFFD700),
          glowColor: Color(0x33FFD700)),
    };

// ─────────────────────────────────────────────────────────────────────────────
// § 11  Backward-compat: PickShareCard
// ─────────────────────────────────────────────────────────────────────────────

/// Thin wrapper kept for call-sites that embed their own [RepaintBoundary].
///
/// Prefer [ShareCardGenerator] for new code — it owns its repaint boundary
/// and exposes [ShareCardGeneratorState.exportImage] / [ShareCardGeneratorState.share].
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
    final r         = result;
    final hasResult = r != null && !r.isPending && r.drawMainNumbers.isNotEmpty;
    return switch (selectTemplate(pick, r, lottery)) {
      ShareCardTemplate.fire     => _FireTemplate(pick: pick, lottery: lottery, result: r!),
      ShareCardTemplate.electric => _ElectricTemplate(pick: pick, lottery: lottery, result: r!),
      ShareCardTemplate.warm     => _WarmTemplate(pick: pick, lottery: lottery, result: hasResult ? r : null),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// § 12  Backward-compat: sharePickCard / sharePickCards helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Captures a [RepaintBoundary] identified by [repaintKey] and shares it.
///
/// Legacy helper — new code should call [ShareCardGeneratorState.share] instead.
Future<void> sharePickCard({
  required GlobalKey repaintKey,
  required BuildContext btnContext,
  PickMatchResult? result,
  Lottery? lottery,
}) async {
  final box    = btnContext.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image    = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final file = File(
        '${(await getTemporaryDirectory()).path}/lottorun_pick.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: _shareText(result, lottery),
      sharePositionOrigin: origin,
    );
  } catch (e) {
    debugPrint('sharePickCard error: $e');
  }
}

/// Batch-captures multiple [RepaintBoundary] widgets and shares them together.
Future<void> sharePickCards({
  required List<GlobalKey> repaintKeys,
  required BuildContext btnContext,
}) async {
  final box    = btnContext.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  try {
    final dir   = await getTemporaryDirectory();
    final files = <XFile>[];

    for (var i = 0; i < repaintKeys.length; i++) {
      final boundary = repaintKeys[i].currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) continue;

      final image    = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) continue;

      final file = File('${dir.path}/lottorun_pick_${i + 1}.png');
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

String _shareText(PickMatchResult? result, Lottery? lottery) {
  if (result == null || result.isPending) {
    return 'My AI lottery pick 🎯 — Generated by LottoRun AI';
  }
  final isSupp  = lottery?.bonusIsSupplementary ?? false;
  final total   = result.matchedMain +
      (isSupp ? result.suppCategoryHits(lottery!) : result.matchedBonus);
  final tmpl = selectTemplate(
    GeneratedPick(
      lotteryId: lottery?.id ?? '',
      style: PlayStyle.balanced,
      mainNumbers: [],
      createdAt: DateTime.now(),
    ),
    result,
    lottery ?? Lottery(
      id: '', countryCode: '', countryName: '', name: '',
      mainCount: 6, mainMin: 1, mainMax: 45,
    ),
  );
  return switch (tmpl) {
    ShareCardTemplate.fire     => '🔥 SO CLOSE! Check my LottoRun AI lottery pick!',
    ShareCardTemplate.electric => '🎯 Nice hit! Check my LottoRun AI lottery pick!',
    ShareCardTemplate.warm     => total == 0
        ? '😆 Better luck next time! My AI lottery pick — LottoRun AI'
        : 'My AI lottery pick 🎯 — Generated by LottoRun AI',
  };
}

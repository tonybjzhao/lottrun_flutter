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
  final ShareCardTemplate? templateOverride;

  const ShareCardGenerator({
    super.key,
    required this.pick,
    required this.lottery,
    this.result,
    this.templateOverride,
  });

  @override
  State<ShareCardGenerator> createState() => ShareCardGeneratorState();
}

class ShareCardGeneratorState extends State<ShareCardGenerator> {
  final _repaintKey = GlobalKey();

  /// Which template is currently active.
  ShareCardTemplate get template {
    final resolvedResult = widget.result != null &&
        !widget.result!.isPending &&
        widget.result!.drawMainNumbers.isNotEmpty;
    final requested =
        widget.templateOverride ??
        selectTemplate(widget.pick, widget.result, widget.lottery);

    if (!resolvedResult &&
        (requested == ShareCardTemplate.fire ||
            requested == ShareCardTemplate.electric)) {
      return ShareCardTemplate.warm;
    }
    return requested;
  }

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
      ShareCardTemplate.warm     => _WarmTemplate(
          pick: widget.pick,
          lottery: widget.lottery,
          result: hasResult ? r : null,
          forceFunnyFail: widget.templateOverride == ShareCardTemplate.warm,
        ),
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
                  _topBar(),
                  const SizedBox(height: 18),

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
                  Text(
                    '🔥 Near match!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _matchDesc(matchMain, suppHits, isSupp, result.matchedBonus, lottery),
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Only one number away 👀',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  _ballRow(userMain, (n) {
                    if (matchedMainSet.contains(n)) return _BallKind.mainHit;
                    if (matchedSuppSet.contains(n)) return _BallKind.suppHit;
                    return _BallKind.miss;
                  }, size: 48),
                  const SizedBox(height: 14),
                  _ballRow(drawMain, (_) => _BallKind.drawMain, size: 38),
                  if (isSupp && drawSupp.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ballRow(drawSupp, (_) => _BallKind.drawSupp, size: 32),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Can you beat this? 👀',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
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
          child: Text('NumberRun',
              style: const TextStyle(
                  color: _gold, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _footer() => Text(
        '✨ NumberRun',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
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
                  _topBar(),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              '🎯 Not bad!',
                              style: TextStyle(
                                color: _cyan,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
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
                            const SizedBox(height: 6),
                            const Text(
                              'Can you beat this? 👀',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ballRow(userMain, (n) {
                    if (matchedMainSet.contains(n)) return _BallKind.mainHit;
                    if (matchedSuppSet.contains(n)) return _BallKind.suppHit;
                    return _BallKind.miss;
                  }, size: 44),
                  const SizedBox(height: 14),
                  _ballRow(drawMain, (_) => _BallKind.drawMain, size: 36),
                  if (isSupp && drawSupp.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ballRow(drawSupp, (_) => _BallKind.drawSupp, size: 30),
                  ],
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
        Text('✨ NumberRun',
            style: const TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ]);

  Widget _footer() => Text(
        '✨ NumberRun',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
}
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
  final bool forceFunnyFail;

  const _WarmTemplate({
    required this.pick,
    required this.lottery,
    this.result,
    this.forceFunnyFail = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = _styleThemeFor(pick.style);
    final isMiss    = result != null && !result!.isPending;
    final isPending = result?.isPending == true;
    final isFunnyFail = isMiss || forceFunnyFail;
    final userMain  = pick.mainNumbers;
    final bonusNums = pick.bonusNumbers ?? [];
    final isSupp    = lottery.bonusIsSupplementary;

    final String emoji;
    final String headline;
    final String subhead;
    final String? blurbText;

    if (isFunnyFail) {
      emoji    = '😂';
      headline = 'Not today';
      subhead  = isMiss ? '0 overlapped' : 'Random result';
      blurbText = null;
    } else if (isPending) {
      emoji    = '⏳';
      headline = 'Result update incoming!';
      subhead  = 'Waiting for results 🤞';
      blurbText = 'Can you beat this? 👀';
    } else {
      emoji    = '🎯';
      headline = 'My Number Pick';
      subhead  = "Let's see what happens 👀";
      blurbText = 'These are my numbers ↑';
    }

    final bonusLabel = switch (lottery.id) {
      'au_powerball'    => 'Powerball',
      'us_powerball'    => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _                 => 'Bonus',
    };

    final List<Color> gradColors = isFunnyFail
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
            if (!isFunnyFail) ..._confettiParticles(),

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
                  if (isFunnyFail)
                    _missCard()
                  else if (blurbText != null)
                    _strategyCard(blurbText, theme),

                  const SizedBox(height: 18),
                  Text(
                    'Can you beat this? 👀',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✨ NumberRun',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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
              '😂 Funny fail',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not today',
              style: TextStyle(
                color: Color(0xFF5F4339),
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
              color: Color(0xCCFFFFFF), fontSize: 13, height: 1.4),
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
        Text('NumberRun',
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]);
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

// ─────────────────────────────────────────────────────────────────────────────
// § 8  Shared pure helpers
// ─────────────────────────────────────────────────────────────────────────────

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
  final ShareCardTemplate? templateOverride;

  const PickShareCard({
    super.key,
    required this.pick,
    required this.lottery,
    this.result,
    this.templateOverride,
  });

  @override
  Widget build(BuildContext context) {
    final r         = result;
    final hasResult = r != null && !r.isPending && r.drawMainNumbers.isNotEmpty;
    final template =
        templateOverride ?? selectTemplate(pick, r, lottery);
    return switch (template) {
      ShareCardTemplate.fire     => _FireTemplate(pick: pick, lottery: lottery, result: r!),
      ShareCardTemplate.electric => _ElectricTemplate(pick: pick, lottery: lottery, result: r!),
      ShareCardTemplate.warm     => _WarmTemplate(
          pick: pick,
          lottery: lottery,
          result: hasResult ? r : null,
          forceFunnyFail: templateOverride == ShareCardTemplate.warm,
        ),
    };
  }
}

Future<void> showPickShareSheet({
  required BuildContext context,
  required GeneratedPick pick,
  required Lottery lottery,
  PickMatchResult? result,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickShareSheet(
      pick: pick,
      lottery: lottery,
      result: result,
    ),
  );
}

class _PickShareSheet extends StatefulWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult? result;

  const _PickShareSheet({
    required this.pick,
    required this.lottery,
    this.result,
  });

  @override
  State<_PickShareSheet> createState() => _PickShareSheetState();
}

class _PickShareSheetState extends State<_PickShareSheet> {
  final _generatorKey = GlobalKey<ShareCardGeneratorState>();
  ShareCardTemplate? _manualTemplate;
  bool _isSharing = false;

  ShareCardTemplate get _autoTemplate =>
      selectTemplate(widget.pick, widget.result, widget.lottery);

  ShareCardTemplate get _effectiveTemplate =>
      _manualTemplate ?? _autoTemplate;

  bool get _hasResolvedResult =>
      widget.result != null &&
      !widget.result!.isPending &&
      widget.result!.drawMainNumbers.isNotEmpty;

  Future<void> _share(BuildContext buttonContext) async {
    if (_isSharing) return;
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    setState(() => _isSharing = true);
    try {
      await _generatorKey.currentState?.share(sharePositionOrigin: origin);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Card Preview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a style or keep the auto recommendation for ${widget.lottery.name}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FittedBox(
                        child: ShareCardGenerator(
                          key: _generatorKey,
                          pick: widget.pick,
                          lottery: widget.lottery,
                          result: widget.result,
                          templateOverride: _manualTemplate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Template',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: Text(
                            '⭐ Smart Pick',
                          ),
                          selected: _manualTemplate == null,
                          onSelected: (_) {
                            setState(() => _manualTemplate = null);
                          },
                        ),
                        for (final template in ShareCardTemplate.values)
                          ChoiceChip(
                            label: Text(_templateLabel(template)),
                            selected: _manualTemplate == template,
                            onSelected: (template == ShareCardTemplate.fire ||
                                        template ==
                                            ShareCardTemplate.electric) &&
                                    !_hasResolvedResult
                                ? null
                                : (_) {
                                    setState(() => _manualTemplate = template);
                                  },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _templateDescription(_effectiveTemplate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSharing
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) => FilledButton.icon(
                        onPressed: _isSharing
                            ? null
                            : () => _share(buttonContext),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.share_rounded),
                        label: Text(
                          _isSharing ? 'Preparing...' : 'Share PNG',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      text: 'My number picks 🎯 — Generated by NumberRun',
      sharePositionOrigin: origin,
    );
  } catch (e) {
    debugPrint('sharePickCards error: $e');
  }
}

String _shareText(PickMatchResult? result, Lottery? lottery) {
  if (result == null || result.isPending) {
    return 'My number pick 🎯 — Generated by NumberRun';
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
    ShareCardTemplate.fire     => '🔥 Number comparison from NumberRun',
    ShareCardTemplate.electric => '🎯 Number overlap from NumberRun',
    ShareCardTemplate.warm     => total == 0
        ? '😆 Random result from NumberRun'
        : 'My number pick 🎯 — Generated by NumberRun',
  };
}

String _templateLabel(ShareCardTemplate template) => switch (template) {
      ShareCardTemplate.fire => '🔥 Almost Overlap',
      ShareCardTemplate.electric => '🎯 Number Overlap',
      ShareCardTemplate.warm => '😂 Random Result',
    };

String _templateDescription(ShareCardTemplate template) => switch (template) {
      ShareCardTemplate.fire =>
        'Dramatic gold-on-dark card for close calls and strong hit streaks.',
      ShareCardTemplate.electric =>
        'Clean neon stats card for smaller wins and partial matches.',
      ShareCardTemplate.warm =>
        'Playful motivational card for pending draws, misses, or pick-only sharing.',
    };

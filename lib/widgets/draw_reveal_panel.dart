import 'package:flutter/material.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../services/pick_result_service.dart';

/// Animated draw-result reveal panel.
///
/// Sequence (total ≈ 2.95 s including 350 ms initial delay):
///   1. "DRAW RESULT" label fades in
///   2. Main draw balls reveal one-by-one (scale + slide + fade, elastic)
///   3. "SUPPLEMENTARY" label + supp balls reveal
///   4. "YOUR NUMBERS" section fades in
///   5. Matched user-pick balls highlight one-by-one (gold/blue glow)
///   6. Summary card slides up with animated match counter
class DrawRevealPanel extends StatefulWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final PickMatchResult result;
  final bool isBest;

  const DrawRevealPanel({
    super.key,
    required this.pick,
    required this.lottery,
    required this.result,
    this.isBest = false,
  });

  @override
  State<DrawRevealPanel> createState() => _DrawRevealPanelState();
}

class _DrawRevealPanelState extends State<DrawRevealPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Set<int> _matchedMainSet;
  late final Set<int> _matchedSuppSet;
  late final List<int> _userMain;
  late final List<int> _matchedIndices; // indices in _userMain that are matched

  @override
  void initState() {
    super.initState();
    _userMain = widget.pick.mainNumbers;
    _matchedMainSet = widget.result.matchedMainNumbers.toSet();
    _matchedSuppSet = widget.result.matchedMainInDrawSupp.toSet();
    _matchedIndices = [
      for (var i = 0; i < _userMain.length; i++)
        if (_matchedMainSet.contains(_userMain[i]) ||
            _matchedSuppSet.contains(_userMain[i]))
          i,
    ];

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _interval(double start, double end,
          {Curve curve = Curves.easeOutCubic}) =>
      CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: curve));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawMain = widget.result.drawMainNumbers;
    final drawSupp = widget.result.drawBonusNumbers ?? [];
    final isSupp = widget.lottery.bonusIsSupplementary;
    final matchedMain = widget.result.matchedMain;
    final suppHits = widget.result.suppCategoryHits(widget.lottery);

    // ── Timing intervals (relative to 2600 ms controller) ─────────────────
    // [0.00–0.07]  "DRAW RESULT" header
    // [0.02–0.42]  6 main balls, step=0.06, duration=0.10 each
    // [0.40–0.47]  "SUPPLEMENTARY" label
    // [0.44–0.62]  2 supp balls, step=0.09, duration=0.10 each
    // [0.58–0.65]  divider + "YOUR NUMBERS" section
    // [0.66–0.88]  matched highlights, step=0.07, duration=0.10 each
    // [0.66–0.90]  animated match counter
    // [0.88–1.00]  summary card slide-up

    final headerAnim    = _interval(0.00, 0.07);
    final mainAnims     = List.generate(drawMain.length, (i) =>
        _interval(0.02 + i * 0.06, 0.12 + i * 0.06, curve: Curves.elasticOut));
    final suppLabelAnim = _interval(0.40, 0.47);
    final suppAnims     = List.generate(drawSupp.length, (i) =>
        _interval(0.44 + i * 0.09, 0.54 + i * 0.09, curve: Curves.easeOutBack));
    final userFadeAnim  = _interval(0.58, 0.65);
    final highlightAnims = List.generate(_matchedIndices.length, (i) =>
        _interval((0.66 + i * 0.07).clamp(0.0, 0.88),
                  (0.76 + i * 0.07).clamp(0.0, 0.96),
                  curve: Curves.elasticOut));
    final counterAnim   = _interval(0.66, 0.90);
    final summaryAnim   = _interval(0.88, 1.00, curve: Curves.easeOutQuart);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Pre-compute all values — one rebuild per frame, no sub-AnimatedBuilders.
        final headerOp    = headerAnim.value.clamp(0.0, 1.0);
        final mainVals    = mainAnims.map((a) => a.value).toList();
        final suppLabelOp = suppLabelAnim.value.clamp(0.0, 1.0);
        final suppVals    = suppAnims.map((a) => a.value).toList();
        final userFadeOp  = userFadeAnim.value.clamp(0.0, 1.0);
        final hlVals      = highlightAnims.map((a) => a.value).toList();
        final counterProg = counterAnim.value;
        final summaryOp   = summaryAnim.value.clamp(0.0, 1.0);

        // Map: userMain index → highlight value (0..1.5 elastic)
        final hlMap = <int, double>{
          for (var k = 0; k < _matchedIndices.length; k++)
            _matchedIndices[k]: hlVals[k],
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── "DRAW RESULT" header ───────────────────────────────────────
            Opacity(
              opacity: headerOp,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'DRAW RESULT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            // ── Main draw balls ────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < drawMain.length; i++) ...[
                    _RevealBall(number: drawMain[i], value: mainVals[i], isSupp: false),
                    if (i < drawMain.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),

            // ── Supplementary draw balls ───────────────────────────────────
            if (isSupp && drawSupp.isNotEmpty) ...[
              const SizedBox(height: 8),
              Opacity(
                opacity: suppLabelOp,
                child: const Text(
                  'SUPPLEMENTARY',
                  style: TextStyle(
                    color: Color(0xFF1A5FA8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < drawSupp.length; i++) ...[
                    _RevealBall(number: drawSupp[i], value: suppVals[i], isSupp: true),
                    if (i < drawSupp.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 14),

            // ── Divider ────────────────────────────────────────────────────
            Opacity(
              opacity: userFadeOp,
              child: Divider(height: 1, color: theme.colorScheme.outlineVariant),
            ),
            const SizedBox(height: 10),

            // ── "YOUR NUMBERS" label ───────────────────────────────────────
            Opacity(
              opacity: userFadeOp,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'YOUR NUMBERS',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 9,
                  ),
                ),
              ),
            ),

            // ── User pick balls with match highlighting ────────────────────
            Opacity(
              opacity: userFadeOp,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      for (var i = 0; i < _userMain.length; i++) ...[
                        _UserMatchBall(
                          number: _userMain[i],
                          isMatchedMain: _matchedMainSet.contains(_userMain[i]),
                          isMatchedSupp: _matchedSuppSet.contains(_userMain[i]),
                          // Matched: animate 0→1; unmatched: immediately dimmed (1.0)
                          highlightValue: hlMap[i] ??
                              (_matchedMainSet.contains(_userMain[i]) ||
                                      _matchedSuppSet.contains(_userMain[i])
                                  ? 0.0
                                  : 1.0),
                        ),
                        if (i < _userMain.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Summary card ───────────────────────────────────────────────
            Transform.translate(
              offset: Offset(0, 12 * (1 - summaryOp)),
              child: Opacity(
                opacity: summaryOp,
                child: _MatchSummaryCard(
                  matchedMain: matchedMain,
                  suppHits: suppHits,
                  isSupp: isSupp,
                  matchedBonus: widget.result.matchedBonus,
                  bonusLabel: widget.lottery.bonusLabel,
                  counterProgress: counterProg,
                  summary: widget.result.matchSummary(widget.lottery),
                  levelLabel: widget.result.levelLabel(widget.lottery),
                  isBest: widget.isBest,
                  theme: theme,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Draw result ball ──────────────────────────────────────────────────────────

class _RevealBall extends StatelessWidget {
  final int number;
  final double value; // raw animation value; elastic may exceed 1.0
  final bool isSupp;

  const _RevealBall(
      {required this.number, required this.value, required this.isSupp});

  @override
  Widget build(BuildContext context) {
    final opacity = value.clamp(0.0, 1.0);
    final scale   = value.clamp(0.0, 1.15);
    final yOffset = 10.0 * (1.0 - opacity);

    const size = 38.0;
    // Draw balls: blue (main) or silver-grey (supp) — visually distinct from user picks
    final colors = isSupp
        ? [const Color(0xFFB0BEC5), const Color(0xFF78909C)]
        : [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
    final shadowColor =
        isSupp ? const Color(0xFF78909C) : const Color(0xFF1565C0);

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
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
                  color: shadowColor.withAlpha(110),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: size * 0.37,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── User pick ball with match highlight ───────────────────────────────────────

class _UserMatchBall extends StatelessWidget {
  final int number;
  final bool isMatchedMain;
  final bool isMatchedSupp;

  /// 0.0 = pre-reveal (matched balls start here).
  /// 1.0 = fully highlighted (matched) or fully dimmed (unmatched).
  /// May exceed 1.0 due to elastic curve.
  final double highlightValue;

  const _UserMatchBall({
    required this.number,
    required this.isMatchedMain,
    required this.isMatchedSupp,
    required this.highlightValue,
  });

  @override
  Widget build(BuildContext context) {
    final isMatched = isMatchedMain || isMatchedSupp;
    final hv = highlightValue.clamp(0.0, 1.5);
    final hvC = hv.clamp(0.0, 1.0); // clamped for opacity/color math

    const size = 36.0;

    final List<Color> gradient;
    final Color ringColor;
    final Color textColor;

    if (isMatchedMain) {
      gradient  = [const Color(0xFFFFD54F), const Color(0xFFFFAB00)]; // warm gold
      ringColor = const Color(0xFFFF8F00);
      textColor = const Color(0xFF4A3000);
    } else if (isMatchedSupp) {
      gradient  = [const Color(0xFF5C9FD6), const Color(0xFF1A5FA8)]; // blue
      ringColor = const Color(0xFF1A5FA8);
      textColor = Colors.white;
    } else {
      gradient  = [const Color(0xFFEEEEEE), const Color(0xFFE0E0E0)]; // grey
      ringColor = Colors.transparent;
      textColor = Colors.grey.shade500;
    }

    // Matched: scale in from 0.82 → 1.0 (elastic may push past 1)
    // Unmatched: immediate full dim (highlightValue=1.0 on reveal)
    final ballOpacity = isMatched ? 1.0 : (1.0 - 0.55 * hvC);
    final ballScale   = isMatched ? (0.82 + 0.18 * hvC) : 1.0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Glow halo behind ball (matched only)
        if (isMatched && hvC > 0)
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ringColor.withAlpha((170 * hvC).round()),
                  blurRadius: 14 * hvC,
                  spreadRadius: 3 * hvC,
                ),
              ],
            ),
          ),
        // Ball
        Opacity(
          opacity: ballOpacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: ballScale.clamp(0.0, 1.15),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.85,
                  colors: gradient,
                ),
                border: isMatched && hvC > 0
                    ? Border.all(
                        color: ringColor.withAlpha((220 * hvC).round()),
                        width: 2,
                      )
                    : null,
                boxShadow: isMatched
                    ? [
                        BoxShadow(
                          color: ringColor.withAlpha((90 * hvC).round()),
                          blurRadius: 6 * hvC,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: size * 0.37,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
        // "S" badge for supplementary matches
        if (isMatchedSupp && hvC > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Opacity(
              opacity: hvC,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5FA8),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  'S',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Match summary card ────────────────────────────────────────────────────────

class _MatchSummaryCard extends StatelessWidget {
  final int matchedMain;
  final int suppHits;
  final bool isSupp;
  final String? bonusLabel;
  final int matchedBonus;
  final double counterProgress; // 0.0–1.0
  final String summary;
  final String levelLabel;
  final bool isBest;
  final ThemeData theme;

  const _MatchSummaryCard({
    required this.matchedMain,
    required this.suppHits,
    required this.isSupp,
    required this.bonusLabel,
    required this.matchedBonus,
    required this.counterProgress,
    required this.summary,
    required this.levelLabel,
    required this.isBest,
    required this.theme,
  });

  String get _emoji => switch (levelLabel) {
        'Light hit' => '🙂',
        'Nice'      => '😊',
        'Solid'     => '🔥',
        'Strong'    => '💪',
        'Great'     => '💥',
        _           => '—',
      };

  @override
  Widget build(BuildContext context) {
    final total = isSupp ? matchedMain + suppHits : matchedMain + matchedBonus;
    final animatedCount = (total * counterProgress.clamp(0.0, 1.0)).round();
    final isGood  = total >= 2;
    final isGreat = total >= 4;

    final bgColor = isGreat
        ? Colors.amber.shade50
        : isGood
            ? theme.colorScheme.primaryContainer.withAlpha(100)
            : theme.colorScheme.surfaceContainerHighest.withAlpha(200);
    final borderColor = isGreat
        ? Colors.amber.shade200
        : isGood
            ? theme.colorScheme.primary.withAlpha(50)
            : theme.colorScheme.outlineVariant;
    final accentColor = isGreat
        ? Colors.amber.shade900
        : isGood
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withAlpha(140);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                levelLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              if (isBest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🏆 Best',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Animated match counter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isGreat
                      ? Colors.amber.shade100
                      : isGood
                          ? theme.colorScheme.primary.withAlpha(18)
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  '$animatedCount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            summary.isEmpty ? 'No main matched' : summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isGood
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withAlpha(130),
              fontWeight: isGood ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check official results for prize details',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(75),
              fontStyle: FontStyle.italic,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

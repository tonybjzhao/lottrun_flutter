import 'package:flutter/material.dart';
import 'lotto_ball.dart';

/// Displays main + bonus lottery balls.
///
/// Layout rules (auto-detected from [bonusLabel]):
/// - [bonusLabel] != null  → inline powerball-style (e.g. "Powerball  [🔴7]")
/// - [bonusLabel] == null  → stacked supplementary-style: main on row 1,
///   bonus on row 2 labeled "Supp", 4px smaller, secondary red styling.
class BallRow extends StatelessWidget {
  final List<int> mainNumbers;
  final List<int> bonusNumbers;

  /// Inline label before bonus balls (e.g. "Powerball", "Mega Ball").
  /// null = supplementary layout (two rows, "Supp" label).
  final String? bonusLabel;

  final double ballSize;
  final double spacing;

  const BallRow({
    super.key,
    required this.mainNumbers,
    this.bonusNumbers = const [],
    this.bonusLabel,
    this.ballSize = 44,
    this.spacing = 8,
  });

  Widget _ballRow(List<int> numbers, {bool isBonus = false, required double size, required double gap}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < numbers.length; i++) ...[
              LottoBall(number: numbers[i], isBonus: isBonus, size: size),
              if (i < numbers.length - 1) SizedBox(width: gap),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Inline mode (powerball-style) ──────────────────────────────────────
    if (bonusLabel != null || bonusNumbers.isEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < mainNumbers.length; i++) ...[
                LottoBall(number: mainNumbers[i], size: ballSize),
                if (i < mainNumbers.length - 1 || bonusNumbers.isNotEmpty)
                  SizedBox(width: spacing),
              ],
              if (bonusNumbers.isNotEmpty) ...[
                if (bonusLabel != null) ...[
                  Text(
                    bonusLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: spacing),
                ],
                for (var i = 0; i < bonusNumbers.length; i++) ...[
                  LottoBall(number: bonusNumbers[i], isBonus: true, size: ballSize),
                  if (i < bonusNumbers.length - 1) SizedBox(width: spacing),
                ],
              ],
            ],
          ),
        ),
      );
    }

    // ── Stacked mode (supplementary-style) ────────────────────────────────
    final suppSize = ballSize - 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ballRow(mainNumbers, size: ballSize, gap: spacing),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Supp',
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            SizedBox(width: spacing),
            ...[
              for (var i = 0; i < bonusNumbers.length; i++) ...[
                LottoBall(number: bonusNumbers[i], isBonus: true, size: suppSize),
                if (i < bonusNumbers.length - 1) SizedBox(width: spacing - 2),
              ],
            ],
          ],
        ),
      ],
    );
  }
}

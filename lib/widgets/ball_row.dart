import 'package:flutter/material.dart';
import 'lotto_ball.dart';

/// Horizontally-scrollable row of lottery balls.
/// Prevents right-edge clipping on lotteries with many numbers (AU 7+2).
class BallRow extends StatelessWidget {
  final List<int> mainNumbers;
  final List<int> bonusNumbers;

  /// Label shown before bonus balls (e.g. "Powerball", "Mega Ball").
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}

/// Returns the appropriate bonus label for a given lottery ID.
String? bonusLabelForLottery(String lotteryId) => switch (lotteryId) {
      'us_powerball' => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      'au_powerball' => 'Powerball',
      _ => null,
    };

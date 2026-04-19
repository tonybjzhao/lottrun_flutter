import 'package:flutter/material.dart';

/// Match state for result display. When set, overrides the default isBonus color.
enum BallResultState {
  none,        // default: isBonus drives the color (amber/red gradient)
  matchedMain, // hit a draw main number → red
  matchedSupp, // hit a draw supplementary number → blue
  unmatched,   // no match → grey (dimmed)
}

class LottoBall extends StatefulWidget {
  final int number;
  final bool isBonus;
  final bool isMatched; // legacy green glow — used in result_panel only
  final BallResultState resultState;
  final double size;

  const LottoBall({
    super.key,
    required this.number,
    this.isBonus = false,
    this.isMatched = false,
    this.resultState = BallResultState.none,
    this.size = 44,
  });

  @override
  State<LottoBall> createState() => _LottoBallState();
}

class _LottoBallState extends State<LottoBall>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    // Pulse only for bonus balls in non-result mode (normal pick display)
    if (widget.isBonus &&
        !widget.isMatched &&
        widget.resultState == BallResultState.none) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulse!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors;
    final Color shadowColor;
    final Color textColor;

    switch (widget.resultState) {
      case BallResultState.matchedMain:
        gradientColors = [const Color(0xFFEF5350), const Color(0xFFC62828)];
        shadowColor = const Color(0xFFC62828);
        textColor = Colors.white;
      case BallResultState.matchedSupp:
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
        shadowColor = const Color(0xFF1565C0);
        textColor = Colors.white;
      case BallResultState.unmatched:
        gradientColors = [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)];
        shadowColor = Colors.grey;
        textColor = Colors.grey.shade600;
      case BallResultState.none:
        // Default palette: matched=green, bonus=red-orange, normal=amber
        if (widget.isMatched) {
          gradientColors = [const Color(0xFF81C784), const Color(0xFF2E7D32)];
          shadowColor = Colors.green;
          textColor = Colors.white;
        } else if (widget.isBonus) {
          gradientColors = [const Color(0xFFFF6B35), const Color(0xFFD32F2F)];
          shadowColor = Colors.red;
          textColor = Colors.white;
        } else {
          gradientColors = [const Color(0xFFFFE066), const Color(0xFFFFB300)];
          shadowColor = Colors.amber;
          textColor = const Color(0xFF5D4000);
        }
    }

    final isResult = widget.resultState != BallResultState.none;
    final isHighlighted = widget.resultState == BallResultState.matchedMain ||
        widget.resultState == BallResultState.matchedSupp ||
        widget.isMatched;

    final ball = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withAlpha(
              isHighlighted ? 180 : isResult ? 60 : (widget.isBonus ? 140 : 100),
            ),
            blurRadius: isHighlighted ? 12 : isResult ? 4 : (widget.isBonus ? 10 : 6),
            offset: const Offset(0, 2),
            spreadRadius: isHighlighted ? 1 : 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${widget.number}',
        style: TextStyle(
          fontSize: widget.size * 0.38,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (_scale == null) return ball;

    return AnimatedBuilder(
      animation: _scale!,
      builder: (_, child) => Transform.scale(scale: _scale!.value, child: child),
      child: ball,
    );
  }
}

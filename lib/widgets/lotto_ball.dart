import 'package:flutter/material.dart';

class LottoBall extends StatefulWidget {
  final int number;
  final bool isBonus;
  final bool isMatched; // green glow when a draw result matched this number
  final double size;

  const LottoBall({
    super.key,
    required this.number,
    this.isBonus = false,
    this.isMatched = false,
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
    if (widget.isBonus && !widget.isMatched) {
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
    // Colour palette: matched=green, bonus=red, normal=amber
    final List<Color> gradientColors = widget.isMatched
        ? [const Color(0xFF81C784), const Color(0xFF2E7D32)]
        : widget.isBonus
            ? [const Color(0xFFFF6B35), const Color(0xFFD32F2F)]
            : [const Color(0xFFFFE066), const Color(0xFFFFB300)];

    final Color shadowColor = widget.isMatched
        ? Colors.green
        : widget.isBonus
            ? Colors.red
            : Colors.amber;

    final Color textColor = widget.isMatched
        ? Colors.white
        : widget.isBonus
            ? Colors.white
            : const Color(0xFF5D4000);

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
                widget.isMatched ? 180 : widget.isBonus ? 140 : 100),
            blurRadius: widget.isMatched ? 12 : widget.isBonus ? 10 : 6,
            offset: const Offset(0, 2),
            spreadRadius: widget.isMatched ? 1 : 0,
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

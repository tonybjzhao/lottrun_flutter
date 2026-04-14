import 'package:flutter/material.dart';

class LottoBall extends StatelessWidget {
  final int number;
  final bool isBonus;
  final double size;

  const LottoBall({
    super.key,
    required this.number,
    this.isBonus = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: isBonus
              ? [const Color(0xFFFF6B35), const Color(0xFFD32F2F)]
              : [const Color(0xFFFFE066), const Color(0xFFFFB300)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isBonus ? Colors.red : Colors.amber).withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: isBonus ? Colors.white : const Color(0xFF5D4000),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class Lottery {
  final String id;
  final String countryCode;
  final String countryName;
  final String name;
  final int mainCount;
  final int mainMin;
  final int mainMax;
  final int? bonusCount;
  final int? bonusMin;
  final int? bonusMax;

  const Lottery({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.name,
    required this.mainCount,
    required this.mainMin,
    required this.mainMax,
    this.bonusCount,
    this.bonusMin,
    this.bonusMax,
  });

  bool get hasBonus => bonusCount != null && bonusCount! > 0;

  String get displayName => '$countryName · $name';
}

import '../models/lottery.dart';

/// V1: Australia only. Oz Lotto & Saturday Lotto have no seed draw data yet.
const List<Lottery> kSeedLotteries = [
  Lottery(
    id: 'au_powerball',
    countryCode: 'AU',
    countryName: 'Australia',
    name: 'Powerball',
    mainCount: 7,
    mainMin: 1,
    mainMax: 35,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 20,
  ),
  Lottery(
    id: 'au_ozlotto',
    countryCode: 'AU',
    countryName: 'Australia',
    name: 'Oz Lotto',
    mainCount: 7,
    mainMin: 1,
    mainMax: 47,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 47,
  ),
  Lottery(
    id: 'au_saturday',
    countryCode: 'AU',
    countryName: 'Australia',
    name: 'Saturday Lotto',
    mainCount: 6,
    mainMin: 1,
    mainMax: 45,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 45,
  ),
];

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoizi_core/immoizi_core.dart';

Property _listing(RentalType type, int price, {int? weekly}) =>
    Property('Test', 'Residence', 'Abidjan', 'Cocody', 2, 60, price,
        rentalType: type, weeklyPrice: weekly);

void main() {
  test('parses the rental type and prices from the API', () {
    final short = Property.fromJson({
      'price': 35000,
      'rentalType': 'SHORT_TERM',
      'weeklyPrice': 210000,
    });
    expect(short.isShortTerm, isTrue);
    expect(short.priceLabel, '35 000 FCFA / nuit');
    expect(short.weeklyPriceLabel, '210 000 FCFA / semaine');

    final monthly = Property.fromJson({'price': 340000});
    expect(monthly.rentalType, RentalType.longTerm);
    expect(monthly.priceLabel, '340 000 FCFA / mois');
    expect(monthly.weeklyPriceLabel, isNull);
  });

  test('filters by rental duration', () {
    final monthly = _listing(RentalType.longTerm, 340000);
    final short = _listing(RentalType.shortTerm, 35000);
    const all = PropertyFilters();
    expect(all.matches(monthly) && all.matches(short), isTrue);

    const onlyShort = PropertyFilters(
        rentalType: RentalType.shortTerm,
        priceRange: RangeValues(0, PropertyFilters.nightlyBudgetMax));
    expect(onlyShort.matches(short), isTrue);
    expect(onlyShort.matches(monthly), isFalse);
    expect(onlyShort.activeCount, 1);
  });

  test('a monthly budget never excludes nightly prices', () {
    const budget = PropertyFilters(priceRange: RangeValues(100000, 400000));
    expect(budget.matches(_listing(RentalType.longTerm, 340000)), isTrue);
    expect(budget.matches(_listing(RentalType.longTerm, 600000)), isFalse);
    expect(budget.matches(_listing(RentalType.shortTerm, 35000)), isTrue);
  });

  test('a nightly budget applies once short stays are selected', () {
    const nightly = PropertyFilters(
        rentalType: RentalType.shortTerm, priceRange: RangeValues(0, 30000));
    expect(nightly.matches(_listing(RentalType.shortTerm, 25000)), isTrue);
    expect(nightly.matches(_listing(RentalType.shortTerm, 35000)), isFalse);
  });

  test('changing the rental type resets the budget to its unit', () {
    const filters = PropertyFilters(priceRange: RangeValues(100000, 400000));
    final short = filters.copyWith(rentalType: RentalType.shortTerm);
    expect(short.priceRange.end, PropertyFilters.nightlyBudgetMax);
    expect(short.activeCount, 1);
    final all = short.copyWith(clearRentalType: true);
    expect(all.rentalType, isNull);
    expect(all.priceRange.end, PropertyFilters.monthlyBudgetMax);
    expect(all.activeCount, 0);
  });
}

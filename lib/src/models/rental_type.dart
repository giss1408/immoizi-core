import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import '../theme.dart';

/// How a listing is rented (Description.rental_type on the backend).
enum RentalType {
  /// Classic lease; the price is the monthly rent.
  longTerm('long_term', 'Au mois', 'mois'),

  /// Furnished stays of a few nights or weeks; the price is per night.
  shortTerm('short_term', 'Courte durée', 'nuit');

  const RentalType(this.apiValue, this._label, this._priceUnit);

  /// Value sent to and filtered by the backend.
  final String apiValue;
  final String _label;
  final String _priceUnit;

  /// Label and price unit ("mois", "nuit") in the active language.
  String get label => tr(_label);
  String get priceUnit => tr(_priceUnit);

  /// Parses the GraphQL enum (`SHORT_TERM`) or API value; defaults to monthly.
  static RentalType fromApi(Object? raw) =>
      '$raw'.toLowerCase() == shortTerm.apiValue ? shortTerm : longTerm;
}

/// "Toutes / Au mois / Courte durée" quick filter.
class RentalTypeChips extends StatelessWidget {
  const RentalTypeChips(
      {required this.value, required this.onChanged, super.key});

  /// Null means every duration.
  final RentalType? value;
  final ValueChanged<RentalType?> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, RentalType? type, IconData icon) => ChoiceChip(
          avatar: Icon(icon,
              size: 18,
              color: value == type ? IvoryColors.onPrimary : IvoryColors.green),
          label: Text(label),
          selected: value == type,
          showCheckmark: false,
          selectedColor: IvoryColors.green,
          labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: value == type ? IvoryColors.onPrimary : IvoryColors.ink),
          onSelected: (_) => onChanged(type),
        );
    return Wrap(spacing: 8, runSpacing: 8, children: [
      chip(tr('Toutes durées'), null, Icons.all_inclusive),
      chip(
          RentalType.longTerm.label, RentalType.longTerm, Icons.calendar_month),
      chip(RentalType.shortTerm.label, RentalType.shortTerm, Icons.nights_stay),
    ]);
  }
}

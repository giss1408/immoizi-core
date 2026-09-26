import 'package:flutter/material.dart';

import '../models/property.dart';
import '../models/rental_type.dart';
import '../theme.dart';
import '../i18n/tr.dart';

class PropertyFilters {
  const PropertyFilters(
      {this.location = '',
      this.priceRange = const RangeValues(0, 5000000),
      this.minRooms = 0,
      this.minSurface = 0,
      this.categories = const {},
      this.rentalType});

  /// Full budget range: monthly rents, or nightly prices for short stays.
  static const monthlyBudgetMax = 5000000.0;
  static const nightlyBudgetMax = 500000.0;

  static double budgetMaxFor(RentalType? type) =>
      type == RentalType.shortTerm ? nightlyBudgetMax : monthlyBudgetMax;

  final String location;
  final RangeValues priceRange;
  final int minRooms;
  final int minSurface;
  final Set<String> categories;

  /// Null means every rental duration.
  final RentalType? rentalType;

  PropertyFilters copyWith(
          {RentalType? rentalType, bool clearRentalType = false}) =>
      PropertyFilters(
        location: location,
        // The budget unit changes with the rental type, so reset it.
        priceRange: RangeValues(
            0,
            budgetMaxFor(
                clearRentalType ? null : rentalType ?? this.rentalType)),
        minRooms: minRooms,
        minSurface: minSurface,
        categories: categories,
        rentalType: clearRentalType ? null : rentalType ?? this.rentalType,
      );

  int get activeCount =>
      (location.trim().isNotEmpty ? 1 : 0) +
      (priceRange.start > 0 ? 1 : 0) +
      (priceRange.end < budgetMaxFor(rentalType) ? 1 : 0) +
      (minRooms > 0 ? 1 : 0) +
      (minSurface > 0 ? 1 : 0) +
      (categories.isNotEmpty ? 1 : 0) +
      (rentalType != null ? 1 : 0);

  bool matches(Property property) {
    final query = location.trim().toLowerCase();
    // The budget is monthly unless short stays are selected, when it is per
    // night; nightly prices are never compared with a monthly budget.
    final budgetApplies =
        rentalType != null || property.rentalType == RentalType.longTerm;
    return (query.isEmpty ||
            property.city.toLowerCase().contains(query) ||
            property.district.toLowerCase().contains(query)) &&
        (rentalType == null || property.rentalType == rentalType) &&
        (!budgetApplies ||
            (property.price >= priceRange.start &&
                property.price <= priceRange.end)) &&
        property.rooms >= minRooms &&
        property.surface >= minSurface &&
        (categories.isEmpty || categories.contains(property.category));
  }
}

class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet(
      {required this.initial,
      required this.categories,
      this.subtitle,
      super.key});
  final PropertyFilters initial;
  final List<String> categories;

  /// Null shows the default subtitle.
  final String? subtitle;

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late final TextEditingController locationController =
      TextEditingController(text: widget.initial.location);
  late RangeValues priceRange = widget.initial.priceRange;
  late int minRooms = widget.initial.minRooms;
  late int minSurface = widget.initial.minSurface;
  late Set<String> categories = {...widget.initial.categories};
  late RentalType? rentalType = widget.initial.rentalType;

  double get budgetMax => PropertyFilters.budgetMaxFor(rentalType);

  void reset() => setState(() {
        locationController.clear();
        rentalType = null;
        priceRange = RangeValues(0, budgetMax);
        minRooms = 0;
        minSurface = 0;
        categories = {};
      });

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('Filtres'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
                TextButton(onPressed: reset, child: Text(tr('Réinitialiser')))
              ]),
              Text(widget.subtitle ?? tr('Affinez les biens disponibles.'),
                  style: TextStyle(color: IvoryColors.muted)),
              const SizedBox(height: 20),
              Text(tr('Durée de location'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              RentalTypeChips(
                  value: rentalType,
                  onChanged: (value) => setState(() {
                        rentalType = value;
                        priceRange = RangeValues(0, budgetMax);
                      })),
              const SizedBox(height: 16),
              TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                      labelText: tr('Localisation'),
                      hintText: tr('Ville ou quartier'),
                      prefixIcon: const Icon(Icons.location_on_outlined))),
              const SizedBox(height: 14),
              Text(
                  tr(
                      rentalType == RentalType.shortTerm
                          ? 'Budget par nuit : {min} - {max}'
                          : 'Budget mensuel : {min} - {max}',
                      {
                        'min': formatFcfa(priceRange.start.round()),
                        'max': formatFcfa(priceRange.end.round()),
                      }),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: budgetMax,
                  divisions: 100,
                  activeColor: IvoryColors.orange,
                  labels: RangeLabels('${priceRange.start.round()}',
                      '${priceRange.end.round()}'),
                  onChanged: (value) => setState(() => priceRange = value)),
              const SizedBox(height: 12),
              _FilterStepper(
                  label: tr('Pièces minimum'),
                  value: minRooms,
                  onChanged: (value) => setState(() => minRooms = value)),
              _FilterStepper(
                  label: tr('Surface minimum'),
                  suffix: ' m²',
                  value: minSurface,
                  step: 10,
                  onChanged: (value) => setState(() => minSurface = value)),
              if (widget.categories.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(tr('Types de biens'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.categories.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: categories.contains(category),
                      selectedColor: IvoryColors.orange.withOpacity(.2),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          categories.add(category);
                        } else {
                          categories.remove(category);
                        }
                      }),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                      onPressed: () => Navigator.pop(
                          context,
                          PropertyFilters(
                              location: locationController.text,
                              priceRange: priceRange,
                              minRooms: minRooms,
                              minSurface: minSurface,
                              categories: categories,
                              rentalType: rentalType)),
                      icon: const Icon(Icons.check),
                      label: Text(tr('Appliquer les filtres')))),
            ])));
  }
}

class _FilterStepper extends StatelessWidget {
  const _FilterStepper(
      {required this.label,
      required this.value,
      required this.onChanged,
      this.step = 1,
      this.suffix = ''});
  final String label, suffix;
  final int value, step;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text('$label: $value$suffix')),
        IconButton(
            onPressed: value > 0 ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_circle_outline)),
        Text('$value'),
        IconButton(
            onPressed: () => onChanged(value + step),
            icon: const Icon(Icons.add_circle_outline))
      ]);
}

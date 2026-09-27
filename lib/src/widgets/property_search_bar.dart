import 'package:flutter/material.dart';

import '../theme.dart';
import '../i18n/tr.dart';

/// Search field with the filter button. Pass it to [AppHeader.search] to get
/// a search button that opens it.
class PropertySearchBar extends StatelessWidget {
  const PropertySearchBar(
      {required this.controller,
      required this.onChanged,
      required this.onOpenFilters,
      this.activeFilterCount = 0,
      this.hintText,
      this.autofocus = false,
      this.onClose,
      super.key});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  /// Null shows the default hint.
  final String? hintText;

  final bool autofocus;

  /// Shows a back arrow in place of the search icon.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: autofocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText ?? tr('Rechercher un bien...'),
              isDense: true,
              prefixIcon: onClose == null
                  ? const Icon(Icons.search)
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: tr('Fermer'),
                      onPressed: onClose,
                    ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
              filled: true,
              fillColor: IvoryColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilterButton(onPressed: onOpenFilters, activeCount: activeFilterCount),
      ],
    );
  }
}

/// Orange round filter button with the number of active filters.
class FilterButton extends StatelessWidget {
  const FilterButton(
      {required this.onPressed, this.activeCount = 0, super.key});

  final VoidCallback onPressed;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: IvoryColors.orange, borderRadius: BorderRadius.circular(32)),
      child: IconButton(
          onPressed: onPressed,
          tooltip: tr('Filtres'),
          icon: Badge(
              isLabelVisible: activeCount > 0,
              label: Text('$activeCount'),
              child: Icon(Icons.tune, color: IvoryColors.onAccent))),
    );
  }
}

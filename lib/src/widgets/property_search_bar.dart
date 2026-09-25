import 'package:flutter/material.dart';

import '../theme.dart';

class PropertySearchBar extends StatelessWidget {
  const PropertySearchBar(
      {required this.controller,
      required this.onChanged,
      required this.onOpenFilters,
      this.activeFilterCount = 0,
      this.hintText = 'Rechercher un bien...',
      super.key});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
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
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        DecoratedBox(
          decoration: BoxDecoration(
              color: IvoryColors.orange,
              borderRadius: BorderRadius.circular(32)),
          child: IconButton(
              onPressed: onOpenFilters,
              icon: Badge(
                  isLabelVisible: activeFilterCount > 0,
                  label: Text('$activeFilterCount'),
                  child: const Icon(Icons.tune, color: Colors.white))),
        ),
      ],
    );
  }
}

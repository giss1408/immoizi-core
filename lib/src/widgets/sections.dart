import 'package:flutter/material.dart';

import '../models/property.dart';
import '../theme.dart';
import 'common.dart';
import '../i18n/tr.dart';

/// Page-level heading with an optional count badge, e.g. "Biens disponibles 6".
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.count, this.subtitle, super.key});

  final String title;
  final int? count;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900, color: IvoryColors.ink)),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              CountBadge(count!),
            ],
          ]),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child:
                  Text(subtitle!, style: TextStyle(color: IvoryColors.muted)),
            ),
        ],
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: IvoryColors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: IvoryColors.green)),
    );
  }
}

/// Lists properties grouped by category under small category labels.
class GroupedPropertyList extends StatelessWidget {
  const GroupedPropertyList(
      {required this.properties,
      required this.cardBuilder,
      this.emptyMessage,
      super.key});

  final List<Property> properties;
  final Widget Function(Property property) cardBuilder;

  /// Null shows the default message.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return EmptyState(
          message: emptyMessage ??
              tr('Aucun bien ne correspond à votre recherche.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groupPropertiesByCategory(properties).entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Row(children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: IvoryColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.key,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: IvoryColors.ink)),
              const SizedBox(width: 8),
              CountBadge(entry.value.length),
            ]),
          ),
          ...entry.value.map(cardBuilder),
        ],
      ],
    );
  }
}

Map<String, List<Property>> groupPropertiesByCategory(
    List<Property> properties) {
  final grouped = <String, List<Property>>{};
  for (final property in properties) {
    grouped.putIfAbsent(property.category, () => []).add(property);
  }
  return grouped;
}

/// Collapsible bordered section used in "Mon espace".
class CategorySection extends StatelessWidget {
  const CategorySection({
    required this.title,
    required this.icon,
    required this.count,
    required this.children,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final int count;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: IvoryColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: IvoryColors.green),
            ),
            title: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: IvoryColors.ink)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountBadge(count),
                const SizedBox(width: 4),
                Icon(Icons.expand_more, color: IvoryColors.muted),
              ],
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [
              if (children.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MutedText(tr('Aucune donnée disponible.')),
                )
              else
                ...children,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme.dart';
import '../i18n/tr.dart';

class DetailChip extends StatelessWidget {
  const DetailChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: trailing == null ? null : Text(trailing!),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(message),
        ),
      );
}

class ErrorCard extends StatelessWidget {
  const ErrorCard(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.redAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(message, style: TextStyle(color: IvoryColors.ink)),
        ),
      );
}

class CacheStatusBar extends StatelessWidget {
  const CacheStatusBar(
      {required this.lastSynced, required this.loading, super.key});

  final DateTime? lastSynced;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final label = loading
        ? tr('Synchronisation en cours...')
        : lastSynced == null
            ? tr(
                'Aucune donn\u00e9e en cache \u2014 tirez vers le bas pour synchroniser')
            : tr('Données en cache — dernière mise à jour {date}',
                {'date': _formatTimestamp(lastSynced!)});

    return Row(
      children: [
        Icon(loading ? Icons.sync : Icons.cached,
            size: 14, color: IvoryColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 11, color: IvoryColors.muted)),
        ),
      ],
    );
  }
}

String _formatTimestamp(DateTime dt) {
  String two(int value) => value.toString().padLeft(2, '0');
  return tr('{date} à {time}', {
    'date': '${two(dt.day)}/${two(dt.month)}',
    'time': '${two(dt.hour)}:${two(dt.minute)}',
  });
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: IvoryColors.muted));
}

class TestDataBadge extends StatelessWidget {
  const TestDataBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0A800)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science, size: 12, color: Color(0xFF8A6D00)),
          const SizedBox(width: 4),
          Text(tr('Donnée de test'),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A6D00))),
        ],
      ),
    );
  }
}

class MediaPlaceholder extends StatelessWidget {
  const MediaPlaceholder({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: IvoryColors.border,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 32, color: IvoryColors.muted.withOpacity(0.6)),
    );
  }
}

class PropertyImageFallback extends StatelessWidget {
  const PropertyImageFallback({this.icon = Icons.home_work, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              IvoryColors.orange.withOpacity(0.14),
              IvoryColors.green.withOpacity(0.14)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: IvoryColors.surface, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: IvoryColors.orange),
          ),
        ),
      );
}

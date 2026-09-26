import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import '../theme.dart';

/// French labels for PropertyInterestRequest statuses (GraphQL enum values).
/// An unanswered request past its 6-day window shows as expired.
String interestStatusLabel(String raw, {bool expired = false}) {
  if (expired) return tr('Expirée');
  return tr(const {
        'pending': 'En attente',
        'reviewing': 'En cours d’examen',
        'accepted': 'Acceptée',
        'rejected': 'Refusée',
      }[raw.toLowerCase()] ??
      raw);
}

Color interestStatusColor(String raw, {bool expired = false}) {
  if (expired) return IvoryColors.muted;
  return switch (raw.toLowerCase()) {
    'accepted' => IvoryColors.success,
    'rejected' => Colors.redAccent,
    _ => IvoryColors.orange,
  };
}

/// Whether the landlord has not answered yet (and the request is still live).
bool isOpenInterestStatus(String raw, {bool expired = false}) =>
    !expired && const {'pending', 'reviewing'}.contains(raw.toLowerCase());

/// Formats an ISO timestamp from the API as dd/mm/yyyy in local time.
String formatShortDate(String? iso) {
  final date = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

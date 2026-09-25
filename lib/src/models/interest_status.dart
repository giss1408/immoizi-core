import 'package:flutter/material.dart';

import '../theme.dart';

/// French labels for PropertyInterestRequest statuses (GraphQL enum values).
String interestStatusLabel(String raw) =>
    const {
      'pending': 'En attente',
      'reviewing': 'En cours d’examen',
      'accepted': 'Acceptée',
      'rejected': 'Refusée',
    }[raw.toLowerCase()] ??
    raw;

Color interestStatusColor(String raw) => switch (raw.toLowerCase()) {
      'accepted' => IvoryColors.green,
      'rejected' => Colors.redAccent,
      _ => IvoryColors.orange,
    };

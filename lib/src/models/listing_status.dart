import '../i18n/tr.dart';

/// Backend listing statuses (Description.LISTING_STATUS_CHOICES) with their
/// French labels, in the order shown to landlords.
const listingStatusLabels = {
  'available': 'Disponible',
  'draft': 'Brouillon',
  'reserved': 'Réservé',
  'rented': 'Loué',
  'maintenance': 'En maintenance',
  'sold': 'Vendu',
  'archived': 'Archivé',
};

/// The backend value for a status as returned by GraphQL (`AVAILABLE`).
String listingStatusValue(String raw) => raw.toLowerCase();

/// Label for a status in the active language; unknown values are shown as
/// they are.
String listingStatusLabel(String raw) =>
    tr(listingStatusLabels[listingStatusValue(raw)] ?? raw);

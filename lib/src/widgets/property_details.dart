import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import '../media/image_viewer.dart';
import '../media/video.dart';
import '../models/listing_status.dart';
import '../models/property.dart';
import '../theme.dart';
import 'common.dart';

/// Frame of a listing's page: green app bar, then the title with a status
/// chip above [children].
class PropertyPageScaffold extends StatelessWidget {
  const PropertyPageScaffold({
    required this.title,
    required this.statusLabel,
    required this.children,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String statusLabel;
  final List<Widget> children;

  /// App bar actions, e.g. an edit button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: IvoryColors.green,
        foregroundColor: IvoryColors.onPrimary,
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Chip(
                      label: Text(statusLabel),
                      backgroundColor: IvoryColors.orange.withOpacity(0.15)),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A listing's photos (tap to enlarge), key facts, description and video.
class PropertyDetails extends StatelessWidget {
  const PropertyDetails(
      {required this.property, this.showListingStatus = false, super.key});

  final Property property;

  /// Adds the listing status to the key facts (landlord view).
  final bool showListingStatus;

  List<String> get _allImages => [
        if (property.mainImageUrl != null) property.mainImageUrl!,
        ...property.galleryImageUrls,
      ];

  void _openViewer(BuildContext context, int index) {
    final images = _allImages;
    if (images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ImageViewerPage(images: images, initialIndex: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (property.mainImageUrl != null)
          GestureDetector(
            onTap: () => _openViewer(context, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                property.mainImageUrl!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const MediaPlaceholder(icon: Icons.image_not_supported),
              ),
            ),
          )
        else
          const MediaPlaceholder(icon: Icons.photo_camera_back),
        if (property.galleryImageUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: property.galleryImageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _openViewer(
                    context, (property.mainImageUrl != null ? 1 : 0) + index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    property.galleryImageUrls[index],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.broken_image, size: 20)),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DetailChip(icon: Icons.category, label: property.category),
            DetailChip(
                icon: Icons.place,
                label: '${property.city}, ${property.district}'),
            DetailChip(icon: Icons.payments, label: property.priceLabel),
            if (property.weeklyPriceLabel != null)
              DetailChip(
                  icon: Icons.date_range, label: property.weeklyPriceLabel!),
            DetailChip(
                icon: property.isShortTerm
                    ? Icons.nights_stay
                    : Icons.calendar_month,
                label: property.rentalType.label),
            DetailChip(
                icon: Icons.meeting_room,
                label: tr('{count} pièces', {'count': property.rooms})),
            DetailChip(
                icon: Icons.square_foot, label: '${property.surface} m²'),
            if (showListingStatus)
              DetailChip(
                  icon: Icons.verified,
                  label: listingStatusLabel(property.status)),
            if (property.hasVideo)
              DetailChip(icon: Icons.videocam, label: tr('Vidéo disponible')),
          ],
        ),
        if (property.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Description',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(property.description, style: TextStyle(color: IvoryColors.ink)),
        ],
        if (property.videoUrl != null) ...[
          const SizedBox(height: 12),
          VideoCard(videoUrl: property.videoUrl!, title: property.title),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/property.dart';
import '../theme.dart';
import 'common.dart';

/// Bordered listing card: photo with status and price overlays, then the
/// title, location and key features.
class PropertyListingCard extends StatelessWidget {
  const PropertyListingCard(
    this.property, {
    required this.statusLabel,
    required this.onTap,
    this.fallbackIcon = Icons.home_work,
    super.key,
  });

  final Property property;
  final String statusLabel;
  final VoidCallback onTap;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final fallback = PropertyImageFallback(icon: fallbackIcon);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // The fallback stays underneath so it shows while the
                    // photo loads and when it fails.
                    fallback,
                    if (property.mainImageUrl != null)
                      Image.network(
                        property.mainImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x40000000)],
                        ),
                      ),
                    ),
                    if (property.isShortTerm)
                      const Positioned(
                        top: 48,
                        left: 12,
                        child: _Overlay(
                          color: IvoryColors.green,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.nights_stay,
                                size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Courte durée',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ]),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _Overlay(
                        color: Colors.white,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.circle,
                              size: 8,
                              color: statusLabel
                                      .toLowerCase()
                                      .startsWith('disponible')
                                  ? IvoryColors.green
                                  : IvoryColors.orange),
                          const SizedBox(width: 6),
                          Text(statusLabel,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: IvoryColors.ink)),
                        ]),
                      ),
                    ),
                    if (property.hasVideo)
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: _Overlay(
                          color: Color(0x99000000),
                          child: Icon(Icons.play_arrow_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _Overlay(
                        color: IvoryColors.orange,
                        child: Text(property.priceLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(property.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: IvoryColors.ink)),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: IvoryColors.muted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: IvoryColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('${property.district}, ${property.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: IvoryColors.muted)),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Feature(
                            Icons.bed_outlined, '${property.rooms} pièces'),
                        _Feature(Icons.square_foot, '${property.surface} m²'),
                        _Feature(Icons.sell_outlined, property.category),
                        if (property.weeklyPriceLabel != null)
                          _Feature(
                              Icons.date_range, property.weeklyPriceLabel!),
                        if (property.isTestData) const TestDataBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: IvoryColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: IvoryColors.green),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: IvoryColors.ink)),
      ]),
    );
  }
}

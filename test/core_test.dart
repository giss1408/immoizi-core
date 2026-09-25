import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoizi_core/immoizi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

Property _property({
  String category = 'Residence',
  String city = 'Abidjan',
  String district = 'Cocody',
  int rooms = 3,
  int surface = 80,
  int price = 300000,
}) =>
    Property('Test', category, city, district, rooms, surface, price);

void main() {
  group('json helpers', () {
    test('jsonItems tolerates null', () {
      expect(jsonItems(null), isEmpty);
      expect(
          jsonItems([
            {'a': 1}
          ]),
          hasLength(1));
    });

    test('jsonInt parses ints and numeric strings, defaults to 0', () {
      expect(jsonInt(4), 4);
      expect(jsonInt('12'), 12);
      expect(jsonInt('abc'), 0);
      expect(jsonInt(null), 0);
    });

    test('nestedTitle falls back to a dash', () {
      expect(nestedTitle({'title': 'Villa'}), 'Villa');
      expect(nestedTitle(null), '-');
    });
  });

  group('Property.fromJson', () {
    test('reads a complete payload', () {
      final property = Property.fromJson({
        'id': '7',
        'title': 'Villa',
        'category': {'title': 'Residence'},
        'city': 'Abidjan',
        'district': 'Cocody',
        'rooms': 5,
        'surfaceM2': '220',
        'price': 920000,
        'listingStatus': 'Disponible',
        'galleryImageUrls': ['a.jpg'],
        'hasVideo': true,
        'videoUrl': 'https://example.org/v.mp4',
      });
      expect(property.id, '7');
      expect(property.surface, 220);
      expect(property.status, 'Disponible');
      expect(property.galleryImageUrls, ['a.jpg']);
      expect(property.hasVideo, isTrue);
    });

    test('uses defaults for a sparse payload', () {
      final property = Property.fromJson({});
      expect(property.title, '-');
      expect(property.category, 'Autres');
      expect(property.status, '-');
      expect(property.price, 0);
      expect(property.galleryImageSlots, isEmpty);
    });

    test('copyWith can clear media', () {
      final property = Property(
          'Villa', 'Residence', 'Abidjan', 'Cocody', 5, 220, 920000,
          mainImageUrl: 'main.jpg', hasVideo: true, videoUrl: 'v.mp4');
      final cleared = property.copyWith(clearMainImage: true, clearVideo: true);
      expect(cleared.mainImageUrl, isNull);
      expect(cleared.hasVideo, isFalse);
      expect(cleared.videoUrl, isNull);
      expect(cleared.price, 920000);
    });
  });

  group('PropertyFilters', () {
    test('default filters match everything and count as inactive', () {
      const filters = PropertyFilters();
      expect(filters.activeCount, 0);
      expect(filters.matches(_property()), isTrue);
    });

    test('location matches city or district, case-insensitively', () {
      const filters = PropertyFilters(location: 'cocody');
      expect(filters.matches(_property()), isTrue);
      expect(filters.matches(_property(district: 'Plateau')), isFalse);
      expect(filters.activeCount, 1);
    });

    test('price, rooms, surface and category bounds apply', () {
      const filters = PropertyFilters(
        priceRange: RangeValues(100000, 400000),
        minRooms: 2,
        minSurface: 50,
        categories: {'Residence'},
      );
      expect(filters.activeCount, 5);
      expect(filters.matches(_property()), isTrue);
      expect(filters.matches(_property(price: 500000)), isFalse);
      expect(filters.matches(_property(rooms: 1)), isFalse);
      expect(filters.matches(_property(surface: 30)), isFalse);
      expect(filters.matches(_property(category: 'Business')), isFalse);
    });
  });

  test('groupPropertiesByCategory keeps first-seen category order', () {
    final grouped = groupPropertiesByCategory([
      _property(category: 'Business'),
      _property(),
      _property(category: 'Business'),
    ]);
    expect(grouped.keys, ['Business', 'Residence']);
    expect(grouped['Business'], hasLength(2));
  });

  group('DashboardCache', () {
    const cache = DashboardCache(dataKey: 'data', timeKey: 'time');

    test('round-trips a payload', () async {
      SharedPreferences.setMockInitialValues({});
      final savedAt = await cache.save({
        'items': [1, 2]
      });
      final restored = await cache.restore();
      expect(restored?.data, {
        'items': [1, 2]
      });
      expect(restored?.cachedAt?.millisecondsSinceEpoch,
          savedAt.millisecondsSinceEpoch);
    });

    test('returns null when empty or corrupt', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await cache.restore(), isNull);
      SharedPreferences.setMockInitialValues({'data': 'not json'});
      expect(await cache.restore(), isNull);
    });
  });
}

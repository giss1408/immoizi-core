import '../api/json.dart';
import '../theme.dart';
import 'rental_type.dart';

class Property {
  Property(
    this.title,
    this.category,
    this.city,
    this.district,
    this.rooms,
    this.surface,
    this.price, {
    this.status = '-',
    this.id,
    this.isTestData = false,
    this.description = '',
    this.mainImageUrl,
    this.galleryImageUrls = const [],
    this.galleryImageSlots = const [],
    this.hasVideo = false,
    this.videoUrl,
    this.rentalType = RentalType.longTerm,
    this.weeklyPrice,
  });

  final String? id;
  final String title;
  final String category;
  final String city;
  final String district;
  final int rooms;
  final int surface;
  final int price;
  final String status;
  final bool isTestData;
  final String description;
  final String? mainImageUrl;
  final List<String> galleryImageUrls;
  final List<String> galleryImageSlots;
  final bool hasVideo;
  final String? videoUrl;

  /// Monthly rent, or short stays priced per night ([price]) and week.
  final RentalType rentalType;
  final int? weeklyPrice;

  bool get isShortTerm => rentalType == RentalType.shortTerm;

  /// "340 000 FCFA / mois" or "35 000 FCFA / nuit".
  String get priceLabel => '${formatFcfa(price)} / ${rentalType.priceUnit}';

  /// "210 000 FCFA / semaine" for short stays with a weekly rate.
  String? get weeklyPriceLabel => isShortTerm && weeklyPrice != null
      ? '${formatFcfa(weeklyPrice!)} / semaine'
      : null;

  Property copyWith({
    int? price,
    String? description,
    String? mainImageUrl,
    List<String>? galleryImageUrls,
    List<String>? galleryImageSlots,
    bool? hasVideo,
    String? videoUrl,
    bool clearMainImage = false,
    bool clearVideo = false,
  }) {
    return Property(
      title,
      category,
      city,
      district,
      rooms,
      surface,
      price ?? this.price,
      status: status,
      id: id,
      isTestData: isTestData,
      description: description ?? this.description,
      mainImageUrl: clearMainImage ? null : mainImageUrl ?? this.mainImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      galleryImageSlots: galleryImageSlots ?? this.galleryImageSlots,
      hasVideo: clearVideo ? false : hasVideo ?? this.hasVideo,
      videoUrl: clearVideo ? null : videoUrl ?? this.videoUrl,
      rentalType: rentalType,
      weeklyPrice: weeklyPrice,
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        json['title'] as String? ?? '-',
        (json['category'] as Map<String, dynamic>?)?['title'] as String? ??
            'Autres',
        json['city'] as String? ?? '-',
        json['district'] as String? ?? '-',
        jsonInt(json['rooms']),
        jsonInt(json['surfaceM2']),
        jsonInt(json['price']),
        status: json['listingStatus'] as String? ?? '-',
        id: json['id'] as String?,
        isTestData: json['isTestData'] as bool? ?? false,
        description: json['description'] as String? ?? '',
        mainImageUrl: json['mainImageUrl'] as String?,
        galleryImageUrls:
            (json['galleryImageUrls'] as List<dynamic>? ?? const [])
                .cast<String>(),
        galleryImageSlots:
            (json['galleryImageSlots'] as List<dynamic>? ?? const [])
                .cast<String>(),
        hasVideo: json['hasVideo'] as bool? ?? false,
        videoUrl: json['videoUrl'] as String?,
        rentalType: RentalType.fromApi(json['rentalType']),
        weeklyPrice: json['weeklyPrice'] as int?,
      );
}

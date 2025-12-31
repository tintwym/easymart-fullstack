class ListingModel {
  final String id;
  final String title;
  final String description;
  final int priceCents;
  final String sellerId;
  final List<String> images;
  final String condition; // or status if your backend uses that

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.sellerId,
    required this.images,
    required this.condition,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priceCents: _toInt(json['price_cents'] ?? json['price']),
      sellerId: json['seller_id']?.toString() ?? '',
      images: List<String>.from(json['images'] ?? []),
      condition: json['condition'] ?? json['status'] ?? 'used',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price_cents': priceCents,
        'seller_id': sellerId,
        'images': images,
        'condition': condition,
      };

  /// ✅ SAFE getter for UI (used by ListingCard)
  String? get coverImage {
    if (images.isEmpty) return null;
    return images.first;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }
}

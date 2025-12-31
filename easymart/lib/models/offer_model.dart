class OfferModel {
  final String id;
  final String listingId;
  final String buyerId;
  final int amountCents;
  final String status;

  OfferModel({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.amountCents,
    required this.status,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: json['id'].toString(),
        listingId: json['listing_id']?.toString() ?? '',
        buyerId: json['buyer_id']?.toString() ?? '',
        amountCents: (json['amount_cents'] ?? 0) as int,
        status: json['status'] ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing_id': listingId,
        'buyer_id': buyerId,
        'amount_cents': amountCents,
        'status': status,
      };
}

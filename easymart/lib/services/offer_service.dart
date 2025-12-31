import 'api_service.dart';

class OfferService {
  final ApiService api = ApiService();

  Future<dynamic> createOffer(String listingId, int amountCents) async {
    // Backend uses POST /offers with listing_id in body
    return api.post('/offers', {
      'listing_id': listingId,
      'amount_cents': amountCents,
    });
  }

  Future<dynamic> respondOffer(String offerId, String status) async {
    return api.patch('/offers/$offerId', {'status': status});
  }
}

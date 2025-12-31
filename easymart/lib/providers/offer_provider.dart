import 'package:flutter/material.dart';
import '../services/offer_service.dart';

class OfferProvider extends ChangeNotifier {
  final OfferService _service = OfferService();
  bool loading = false;

  Future<bool> createOffer(String listingId, int cents) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _service.createOffer(listingId, cents);
      loading = false;
      notifyListeners();
      return res != null;
    } catch (e) {
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> respondOffer(String offerId, String status) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _service.respondOffer(offerId, status);
      loading = false;
      notifyListeners();
      return res != null;
    } catch (e) {
      loading = false;
      notifyListeners();
      return false;
    }
  }
}

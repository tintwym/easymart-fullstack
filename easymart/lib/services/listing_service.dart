import 'api_service.dart';

class ListingService {
  final ApiService api = ApiService();

  Future<List<dynamic>> fetchListings({int page = 1, int perPage = 20}) async {
    final res = await api.get('/listings?page=$page&per_page=$perPage');
    return (res is List) ? res : [];
  }

  Future<dynamic> fetchListing(String id) async {
    return api.get('/listings/$id');
  }

  Future<dynamic> createListing(Map<String, dynamic> data) async {
    return api.post('/listings', data);
  }
}

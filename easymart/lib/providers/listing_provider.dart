import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart'; // 👈 Import XFile
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing_model.dart';
import '../services/api_service.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _service = ListingService();
  List<ListingModel> listings = [];
  bool loading = false;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; // Web (Chrome)
    } else {
      return 'http://10.0.2.2:8000/api';  // Android Emulator
    }
  } 

  bool get isLoading => loading;

  Future<void> loadListings() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.fetchListings();
      listings = data.map((e) => ListingModel.fromJson(e)).toList();
    } catch (e) {
      listings = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchListings() => loadListings();

  Future<ListingModel?> getListing(String id) async {
    try {
      final res = await _service.fetchListing(id);
      return ListingModel.fromJson(res);
    } catch (_) {
      return null;
    }
  }

  // 📸 FIXED UPLOAD FUNCTION (Works on Web & Mobile)
  // We changed the argument from 'File' to 'XFile'
  Future<String?> uploadImage(XFile xfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/upload'), 
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ✅ KEY FIX: Read bytes directly (Browser safe)
      final bytes = await xfile.readAsBytes();

      request.files.add(http.MultipartFile.fromBytes(
        'file', // Must match the name in your Python backend (file: UploadFile)
        bytes,
        filename: xfile.name, // Sends the filename correctly
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['url']; // ✅ Returns the real URL
      } else {
        print("Upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<bool> createListing({
    required String title,
    required String description,
    required int priceCents,
    required String categoryId,
    required String condition,
    required List<String> images,
  }) async {
    try {
      final body = {
        "title": title,
        "description": description,
        "price_cents": priceCents,
        "category_id": categoryId, 
        "condition": condition,
        "images": images
      };

      final response = await ApiService().post('/listings/', body);
      
      if (response != null) {
        notifyListeners(); 
        return true;
      }
      return false;
    } catch (e) {
      print("Create Listing Error: $e");
      return false;
    }
  }
}
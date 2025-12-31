import 'dart:io'; // Needed for File() on mobile
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // To check if running on Web
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // State
  String _selectedCondition = 'new';
  String? _selectedCategoryId; 
  bool _isLoading = false;
  
  // 📸 Image State
  final List<XFile> _selectedImages = []; 

  // ⚠️ CRITICAL FIX: IDs must be unique! 
  // I changed 'Other' to a different ID to prevent the crash.
  final Map<String, String> _categories = {
    'Electronics': 'e01a385e-3fd6-438c-997a-6be2be767c9a', 
    'Clothing': 'd9102c60-859b-44ad-926b-e344fb54d0e8',
    'Phones': 'd55d2fa3-a876-44be-a0f9-d6dc9f7c32ec', 
    'Books': 'd4b6816c-2b68-4249-8279-fad93274e612',  
    'Sports': '5a913536-7979-4961-96fe-e378d4bbf3d1', 
    'Vehicles': 'e3c5ab81-b4c9-435f-93cf-f3ea93e7ebed',
    // 'Other' cannot match 'Phones'. I put a placeholder here.
    // Replace this with the REAL ID for 'Other' from your database.
    'Other': '00000000-0000-0000-0000-000000000000', 
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 📸 Function to Pick Images
  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // 🗑️ Function to Remove Image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ✅ SUBMIT FUNCTION (Fixed for Web & Mobile)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedImages.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ListingProvider>(context, listen: false);
      List<String> realImageUrls = [];

      // ---------------------------------------------------------
      // 🚀 STEP 1: UPLOAD IMAGES
      // ---------------------------------------------------------
      for (var xfile in _selectedImages) {
        // ✅ PASS 'xfile' DIRECTLY (Do not use File())
        // This ensures it works on Web without crashing
        String? url = await provider.uploadImage(xfile);
        
        if (url != null) {
          realImageUrls.add(url);
        } else {
          throw Exception("Failed to upload image");
        }
      }

      // ---------------------------------------------------------
      // 🚀 STEP 2: CREATE LISTING WITH REAL URLS
      // ---------------------------------------------------------
      final int priceCents = (double.parse(_priceController.text) * 100).round();

      final success = await provider.createListing(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priceCents: priceCents,
        categoryId: _selectedCategoryId!,
        condition: _selectedCondition,
        images: realImageUrls, // ✅ Sends Real URLs now
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing Created!')));
        Navigator.pop(context);
      } else {
        throw Exception("Failed to save listing");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📸 IMAGE PICKER UI
              const Text("Photos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1, 
                  itemBuilder: (context, index) {
                    // 1. The "Add Image" Button
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: const Icon(Icons.add_a_photo, color: Colors.grey),
                        ),
                      );
                    }

                    // 2. The Selected Image Thumbnails
                    final image = _selectedImages[index - 1];
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              // ✅ SAFELY SHOW IMAGE ON WEB & MOBILE
                              image: kIsWeb 
                                  ? NetworkImage(image.path) 
                                  : FileImage(File(image.path)) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Delete Button (X)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () => _removeImage(index - 1),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // --- Form Fields ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: const InputDecoration(labelText: 'Price (SGD)', prefixText: '\$ ', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Price is required' : null,
              ),
              const SizedBox(height: 16),

              // Categories
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                initialValue: _selectedCategoryId,
                items: _categories.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Condition
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Condition', border: OutlineInputBorder()),
                initialValue: _selectedCondition,
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('Brand New')),
                  DropdownMenuItem(value: 'like_new', child: Text('Like New')),
                  DropdownMenuItem(value: 'good', child: Text('Good')),
                  DropdownMenuItem(value: 'used', child: Text('Used')),
                ],
                onChanged: (v) => setState(() => _selectedCondition = v!),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
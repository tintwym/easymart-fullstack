import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/offer_provider.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final TextEditingController _offerController = TextEditingController();

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📏 Check Screen Width to decide layout (Mobile vs Web)
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        title: const Text("Details"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 100 : 0, // Add side padding on Web
          vertical: 20,
        ),
        child: isWeb 
            ? _buildWebLayout() // 🖥️ Desktop Layout (Split View)
            : _buildMobileLayout(), // 📱 Mobile Layout (Stacked)
      ),
    );
  }

  // 📱 MOBILE LAYOUT (Vertical Stack)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageGallery(height: 300),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSellerCard(), // Seller info
              const SizedBox(height: 20),
              _buildTitleAndPrice(),
              const SizedBox(height: 20),
              _buildDescription(),
              const SizedBox(height: 20),
              _buildOfferSection(),
            ],
          ),
        ),
      ],
    );
  }

  // 🖥️ WEB LAYOUT (Left Images, Right Details)
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Images (Takes 60% of width)
        Expanded(
          flex: 6,
          child: _buildImageGallery(height: 500, isRounded: true),
        ),
        
        const SizedBox(width: 40),

        // RIGHT: Details & Seller Card (Takes 40% of width)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSellerCard(),
              const SizedBox(height: 20),
              _buildTitleAndPrice(),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildDescription(),
              const SizedBox(height: 30),
              _buildOfferSection(),
            ],
          ),
        ),
      ],
    );
  }

  // 🖼️ IMAGE GALLERY COMPONENT
  Widget _buildImageGallery({required double height, bool isRounded = false}) {
    final images = widget.listing.images;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black, // Dark background for photos
        borderRadius: isRounded ? BorderRadius.circular(12) : null,
      ),
      clipBehavior: isRounded ? Clip.antiAlias : Clip.none,
      child: images.isNotEmpty
          ? PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.contain, // ✅ Ensures whole image is visible
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                );
              },
            )
          : const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 50)),
    );
  }

  // 👤 SELLER CARD (Like Carousell Sidebar)
  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage("https://via.placeholder.com/150"), // Placeholder Avatar
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Seller Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" 5.0 (294 reviews)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // 🔴 RED "BUY" BUTTON STYLE
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6001C), // Carousell Red
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                // Chat logic here
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chat/Buy clicked!")));
              },
              child: const Text("Chat to Buy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // 📝 TITLE & PRICE
  Widget _buildTitleAndPrice() {
    final price = (widget.listing.priceCents / 100).toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.listing.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "S\$$price", 
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
             _tag("Brand New"), // You can map condition here
             const SizedBox(width: 8),
             _tag("Free Delivery"),
          ],
        )
      ],
    );
  }

  // 🏷️ TAG HELPER
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
    );
  }

  // 📖 DESCRIPTION
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Text(
          widget.listing.description,
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
      ],
    );
  }

  // 💰 MAKE OFFER SECTION
  Widget _buildOfferSection() {
    final offerProvider = Provider.of<OfferProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50], // Light grey background for this section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Make an Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          TextField(
            controller: _offerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Your Offer (SGD)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: offerProvider.loading
                  ? null
                  : () async {
                      final text = _offerController.text.trim();
                      if (text.isEmpty) return;
                      final double price = double.tryParse(text) ?? 0.0;
                      final int cents = (price * 100).round();
                      
                      final success = await offerProvider.createOffer(widget.listing.id, cents);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Offer Sent!' : 'Failed')),
                        );
                        if (success) _offerController.clear();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black26),
              ),
              child: offerProvider.loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Make Offer"),
            ),
          ),
        ],
      ),
    );
  }
}
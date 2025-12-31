import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../../models/listing_model.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dataLoaded = false;
  int _currentIndex = 0; 
  final TextEditingController _searchController = TextEditingController();

  final Color _carousellRed = const Color(0xFFD6001C);
  final Color _carousellGreen = const Color(0xFF268E76);

  final List<String> _webNavLinks = ["Electronics", "Fashion", "Luxury", "Services", "Cars", "Property"];
  final List<String> _mobileTabs = ["Top picks", "Nearby", "Free Items", "Certified", "Following"];

  final List<Map<String, dynamic>> _mobileCategories = [
    {'name': 'Likes', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Home Services', 'icon': Icons.build, 'color': Colors.green},
    {'name': 'Cars', 'icon': Icons.directions_car_filled, 'color': Colors.blue},
    {'name': 'Mobile Phones', 'icon': Icons.phone_android, 'color': Colors.blueAccent},
    {'name': 'Luxury', 'icon': Icons.shopping_bag, 'color': Colors.indigo},
    {'name': 'Property', 'icon': Icons.apartment, 'color': Colors.green},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _requireAuth(BuildContext context, VoidCallback onSuccess) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      onSuccess();
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) { 
      _requireAuth(context, () => Navigator.pushNamed(context, '/create-listing'));
      return; 
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final listingProvider = context.watch<ListingProvider>();
    final user = auth.user;
    final isWeb = MediaQuery.of(context).size.width > 900;

    if (!_dataLoaded) {
      _dataLoaded = true;
      Future.microtask(() => context.read<ListingProvider>().loadListings());
    }

    // ✅ FIXED: Removed the extra '?' to clear the yellow warning
    String displayName = user?.email.split('@')[0] ?? "Guest";

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isWeb ? null : _buildMobileDrawer(user, auth),
      appBar: isWeb ? null : _buildMobileAppBar(),
      body: RefreshIndicator(
        onRefresh: () => listingProvider.loadListings(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWeb) _buildWebHeader(context, user, displayName, auth),

                  // 🖼️ BANNER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: isWeb 
                      ? Row(
                          children: [
                            Expanded(child: _buildBanner(const Color(0xFFEF5350), "Tis the season!", "Refresh your home")),
                            const SizedBox(width: 16),
                            Expanded(child: _buildBanner(const Color(0xFF5C0011), "Free Delivery", "On electronics")),
                          ],
                        )
                      : AspectRatio(
                          aspectRatio: 16/9, 
                          child: _buildBanner(const Color(0xFF5C0011), "Tis the season", "to refresh your home!"),
                        ),
                  ),

                  if (!isWeb) ...[
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _mobileCategories.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          final cat = _mobileCategories[index];
                          return _buildMobileCategoryCircle(cat['name'], cat['icon'], cat['color']);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                  ],

                  if (!isWeb)
                    Container(
                      height: 50,
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _mobileTabs.length,
                        itemBuilder: (context, index) {
                          final isActive = index == 0;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: isActive ? BoxDecoration(border: Border(bottom: BorderSide(color: _carousellGreen, width: 3))) : null,
                            child: Text(_mobileTabs[index], style: TextStyle(color: isActive ? _carousellGreen : Colors.black54, fontWeight: FontWeight.bold, fontSize: 15)),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            listingProvider.loading
              ? const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())))
              : SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200, 
                      childAspectRatio: 0.65, 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ListingModel item = listingProvider.listings[index];
                        return ListingCard(listing: item, onTap: () => Navigator.pushNamed(context, '/listing-detail', arguments: item));
                      },
                      childCount: listingProvider.listings.length,
                    ),
                  ),
                ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: isWeb ? null : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "For You"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box, color: Color(0xFFD6001C), size: 30), label: "Sell"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Updates"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Me"),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0,
      leading: Builder(builder: (context) {
        return IconButton(icon: const Icon(Icons.menu, color: Colors.black87, size: 28), onPressed: () => Scaffold.of(context).openDrawer());
      }),
      titleSpacing: 0,
      title: Container(
        height: 40, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
        child: TextField(controller: _searchController, textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(hintText: "Search Item", hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 4))),
      ),
      actions: [IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87), onPressed: () {}), IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87), onPressed: () {}), IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87), onPressed: () {}), const SizedBox(width: 8)],
    );
  }

  Widget _buildMobileDrawer(dynamic user, AuthProvider auth) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100,
            child: DrawerHeader(
              margin: EdgeInsets.zero, padding: const EdgeInsets.only(left: 16, bottom: 16),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Align(alignment: Alignment.bottomLeft, child: Text("Browse by categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ),
          ),
          ..._mobileCategories.map((cat) => ListTile(leading: Icon(cat['icon'], color: cat['color']), title: Text(cat['name']), trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), onTap: () {})),
          const Divider(),
          if (user != null) ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(context); auth.logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false); }),
        ],
      ),
    );
  }

  Widget _buildMobileCategoryCircle(String name, IconData icon, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 32, color: color), const SizedBox(height: 4), Text(name, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center)]);
  }

  Widget _buildWebHeader(BuildContext context, dynamic user, String displayName, AuthProvider auth) {
    return Column(children: [Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 32), child: Row(children: [Text("easymart", style: TextStyle(color: _carousellRed, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Roboto')), const SizedBox(width: 24), Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _webNavLinks.map((name) => Padding(padding: const EdgeInsets.only(right: 20), child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)))).toList()))), if (user == null) ...[TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))), TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)))] else ...[PopupMenuButton<String>(child: Row(children: [CircleAvatar(radius: 14, backgroundColor: Colors.grey[300], backgroundImage: const NetworkImage("https://picsum.photos/200")), const SizedBox(width: 8), Text("Hello, $displayName", style: const TextStyle(fontWeight: FontWeight.bold)), const Icon(Icons.arrow_drop_down)]), onSelected: (v) { if (v == 'logout') { Navigator.pop(context); auth.logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false); } if (v == 'profile') Navigator.pushNamed(context, '/profile'); }, itemBuilder: (ctx) => [const PopupMenuItem(value: 'profile', child: Text("My Profile")), const PopupMenuItem(value: 'logout', child: Text("Logout", style: TextStyle(color: Colors.red)))])], const SizedBox(width: 16), ElevatedButton(onPressed: () => _requireAuth(context, () => Navigator.pushNamed(context, '/create-listing')), style: ElevatedButton.styleFrom(backgroundColor: _carousellRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text("Sell", style: TextStyle(fontWeight: FontWeight.bold)))])) , Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), child: Row(children: [Expanded(child: Container(height: 45, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Row(children: [const SizedBox(width: 12), const Icon(Icons.search, color: Colors.grey), const SizedBox(width: 12), Expanded(child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: "Search for an item", border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 5)))), Container(width: 1, height: 25, color: Colors.grey[300]), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: const [Icon(Icons.location_on_outlined, size: 18, color: Colors.grey), SizedBox(width: 4), Text("All of Singapore", style: TextStyle(color: Colors.grey)), Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey)]))]))), const SizedBox(width: 12), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _carousellGreen, foregroundColor: Colors.white, fixedSize: const Size(100, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))])), const Divider(height: 1, color: Colors.grey)]);
  }

  Widget _buildBanner(Color color, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD6001C),
        borderRadius: BorderRadius.circular(8),
        // ✅ FIXED: Using picsum.photos instead of placeholder
        image: const DecorationImage(image: NetworkImage("https://picsum.photos/800/400"), fit: BoxFit.cover, opacity: 0.3),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black45)])), Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, shadows: [Shadow(blurRadius: 5, color: Colors.black45)])), const SizedBox(height: 12), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text("Book now!"))]),
          )
        ],
      ),
    );
  }
}
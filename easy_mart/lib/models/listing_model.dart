class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String condition;

  ListingModel({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.price, 
    required this.condition
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      condition: json['condition'] ?? 'Used',
    );
  }
}
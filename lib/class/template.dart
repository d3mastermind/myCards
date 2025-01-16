class Template {
  final String templateId;
  final String name;
  final String category;
  final bool isPremium;
  final int? price; // Null for free templates
  final String frontCover;

  Template({
    required this.templateId,
    required this.name,
    required this.category,
    required this.isPremium,
    this.price,
    required this.frontCover,
  });

  // Factory method to create an instance from Firestore data
  factory Template.fromMap(String id, Map<String, dynamic> data) {
    return Template(
      templateId: id,
      name: data['name'],
      category: data['category'],
      isPremium: data['ispremium'],
      price: data['price'],
      frontCover: data['frontCover'],
    );
  }

  // Method to convert the object to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'ispremium': isPremium,
      'price': price,
      'frontCover': frontCover,
    };
  }
}

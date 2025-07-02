import '../../domain/entities/template_entity.dart';

class TemplateModel extends TemplateEntity {
  const TemplateModel({
    required super.templateId,
    required super.name,
    required super.category,
    required super.isPremium,
    super.price,
    required super.frontCover,
  });

  // Factory method to create an instance from Firestore data
  factory TemplateModel.fromMap(String id, Map<String, dynamic> data) {
    return TemplateModel(
      templateId: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      isPremium: data['ispremium'] ?? false,
      price: data['price'],
      frontCover: data['frontCover'] ?? '',
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

  // Convert from entity to model
  factory TemplateModel.fromEntity(TemplateEntity entity) {
    return TemplateModel(
      templateId: entity.templateId,
      name: entity.name,
      category: entity.category,
      isPremium: entity.isPremium,
      price: entity.price,
      frontCover: entity.frontCover,
    );
  }

  // Convert to entity
  TemplateEntity toEntity() {
    return TemplateEntity(
      templateId: templateId,
      name: name,
      category: category,
      isPremium: isPremium,
      price: price,
      frontCover: frontCover,
    );
  }
}

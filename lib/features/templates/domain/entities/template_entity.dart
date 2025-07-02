import 'package:equatable/equatable.dart';

class TemplateEntity extends Equatable {
  final String templateId;
  final String name;
  final String category;
  final bool isPremium;
  final int? price; // Null for free templates
  final String frontCover;

  const TemplateEntity({
    required this.templateId,
    required this.name,
    required this.category,
    required this.isPremium,
    this.price,
    required this.frontCover,
  });

  @override
  List<Object?> get props => [
        templateId,
        name,
        category,
        isPremium,
        price,
        frontCover,
      ];
}

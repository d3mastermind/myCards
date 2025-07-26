import '../entities/template_entity.dart';

abstract class TemplatesRepository {
  Future<List<TemplateEntity>> getAllTemplates(
      {int limit = 20, String? startAfterId});
}

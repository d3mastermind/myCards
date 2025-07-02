import '../entities/template_entity.dart';

abstract class TemplatesRepository {
  Future<List<TemplateEntity>> getAllTemplates();
}

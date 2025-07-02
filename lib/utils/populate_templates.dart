import 'dart:developer';

import 'package:mycards/class/template.dart';
import 'package:mycards/data/template_data.dart';
import 'package:mycards/services/template_service.dart';

/// Utility function to populate Firestore with existing template data
/// This should be called once to migrate from local data to Firestore
class TemplatePopulator {
  static final TemplateService _templateService = TemplateService();

  /// Populate Firestore with templates from local data
  static Future<void> populateTemplates() async {
    try {
      print('Starting template population...');

      // Get existing templates to avoid duplicates
      final existingTemplates = await _templateService.getAllTemplates();
      final existingIds = existingTemplates.map((t) => t.templateId).toSet();

      int addedCount = 0;
      int skippedCount = 0;

      for (final templateMap in templateData) {
        final template = Template(
          templateId: templateMap['templateId'],
          name: templateMap['name'],
          category: templateMap['category'],
          isPremium: templateMap['ispremium'],
          price: templateMap['price'],
          frontCover: templateMap['frontCover'],
        );

        // Skip if template already exists
        if (existingIds.contains(template.templateId)) {
          print('Skipping existing template: ${template.name}');
          skippedCount++;
          continue;
        }

        // Add template to Firestore
        log(template.toMap().toString());
        final docId = await _templateService.addTemplate(template);
        print('Added template: ${template.name} with ID: $docId');
        addedCount++;
      }

      print('Template population completed!');
      print('Added: $addedCount templates');
      print('Skipped: $skippedCount templates');
    } catch (e) {
      print('Error populating templates: $e');
      rethrow;
    }
  }

  /// Clear all templates from Firestore (use with caution!)
  static Future<void> clearAllTemplates() async {
    try {
      print('Clearing all templates...');
      final templates = await _templateService.getAllTemplates();

      for (final template in templates) {
        await _templateService.deleteTemplate(template.templateId);
        print('Deleted template: ${template.name}');
      }

      print('All templates cleared!');
    } catch (e) {
      print('Error clearing templates: $e');
      rethrow;
    }
  }

  /// Update existing templates with new data
  static Future<void> updateExistingTemplates() async {
    try {
      print('Updating existing templates...');

      int updatedCount = 0;

      for (final templateMap in templateData) {
        final template = Template(
          templateId: templateMap['templateId'],
          name: templateMap['name'],
          category: templateMap['category'],
          isPremium: templateMap['ispremium'],
          price: templateMap['price'],
          frontCover: templateMap['frontCover'],
        );

        // Check if template exists
        final existingTemplate =
            await _templateService.getTemplateById(template.templateId);

        if (existingTemplate != null) {
          await _templateService.updateTemplate(template.templateId, template);
          print('Updated template: ${template.name}');
          updatedCount++;
        } else {
          print('Template not found: ${template.name}');
        }
      }

      print('Template update completed!');
      print('Updated: $updatedCount templates');
    } catch (e) {
      print('Error updating templates: $e');
      rethrow;
    }
  }
}

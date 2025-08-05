import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/di/service_locator.dart';
import 'package:mycards/features/templates/domain/repositories/template_repository.dart';
import '../models/template_model.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  final FirebaseFirestore firestore;
  final String _collection = 'templates';

  const TemplatesRepositoryImpl({required this.firestore});

  @override
  Future<List<TemplateModel>> getAllTemplates(
      {int limit = 20, String? startAfterId}) async {
    try {
      log("[TemplatesRepositoryImpl] Fetching templates");
      Query query = firestore.collection(_collection).orderBy('name');

      // If startAfterId is null and limit is large (1000+), load all templates
      if (startAfterId == null && limit >= 1000) {
        log("[TemplatesRepositoryImpl] Loading all templates without pagination");
        final QuerySnapshot snapshot = await query.get();
        final templates = snapshot.docs
            .map((doc) => TemplateModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        log("[TemplatesRepositoryImpl] Loaded ${templates.length} templates (all)");
        return templates;
      }

      // Apply pagination for normal requests
      query = query.limit(limit);

      if (startAfterId != null) {
        log("[TemplatesRepositoryImpl] Loading templates after ID: $startAfterId");
        final DocumentSnapshot startAfterDoc =
            await firestore.collection(_collection).doc(startAfterId).get();
        query = query.startAfterDocument(startAfterDoc);
      } else {
        log("[TemplatesRepositoryImpl] Loading first page of templates");
      }

      final QuerySnapshot snapshot = await query.get();
      final templates = snapshot.docs
          .map((doc) =>
              TemplateModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      log("[TemplatesRepositoryImpl] Loaded ${templates.length} templates (paginated)");
      return templates;
    } catch (e) {
      log("[TemplatesRepositoryImpl] Error fetching templates: $e");
      throw Exception('Failed to fetch templates: $e');
    }
  }
}

final templateRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepositoryImpl(
    firestore: ref.read(fireStoreProvider),
  );
});

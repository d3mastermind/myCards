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
      log("[TemplatesRepositoryImpl] Fetching templates with pagination");
      Query query = firestore.collection(_collection).orderBy('name');

      // If startAfterId is null, load all templates without pagination
      if (startAfterId == null) {
        log("[TemplatesRepositoryImpl] Loading all templates without pagination");
        final QuerySnapshot snapshot = await query.get();
        return snapshot.docs
            .map((doc) => TemplateModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      }

      // Apply pagination
      query = query.limit(limit);
      final DocumentSnapshot startAfterDoc =
          await firestore.collection(_collection).doc(startAfterId).get();
      query = query.startAfterDocument(startAfterDoc);
      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              TemplateModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
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

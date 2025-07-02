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
  Future<List<TemplateModel>> getAllTemplates() async {
    try {
      final QuerySnapshot snapshot =
          await firestore.collection(_collection).orderBy('name').get();

      return snapshot.docs
          .map((doc) =>
              TemplateModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }
}

final templateRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepositoryImpl(
    firestore: ref.read(fireStoreProvider),
  );
});

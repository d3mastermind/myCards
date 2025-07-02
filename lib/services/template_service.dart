import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycards/class/template.dart';

class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'templates';

  // Cache for templates to avoid repeated API calls
  List<Template>? _cachedTemplates;
  DateTime? _lastFetched;
  final Duration _cacheExpiry = const Duration(minutes: 30);

  // Get all templates from Firestore
  Future<List<Template>> getAllTemplates() async {
    try {
      // Return cached data if available and not expired
      if (_cachedTemplates != null &&
          _lastFetched != null &&
          DateTime.now().difference(_lastFetched!) < _cacheExpiry) {
        return _cachedTemplates!;
      }

      final QuerySnapshot snapshot =
          await _firestore.collection(_collection).orderBy('name').get();

      final List<Template> templates = snapshot.docs
          .map((doc) =>
              Template.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Update cache
      _cachedTemplates = templates;
      _lastFetched = DateTime.now();

      return templates;
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  // Get templates by category
  Future<List<Template>> getTemplatesByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) =>
              Template.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates by category: $e');
    }
  }

  // Get premium templates
  Future<List<Template>> getPremiumTemplates() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('ispremium', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) =>
              Template.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch premium templates: $e');
    }
  }

  // Get free templates
  Future<List<Template>> getFreeTemplates() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('ispremium', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) =>
              Template.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch free templates: $e');
    }
  }

  // Search templates by name
  Future<List<Template>> searchTemplates(String query) async {
    try {
      // Get all templates first (since Firestore doesn't support case-insensitive search natively)
      final allTemplates = await getAllTemplates();

      // Filter templates based on the search query
      return allTemplates
          .where((template) =>
              template.name.toLowerCase().contains(query.toLowerCase()) ||
              template.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search templates: $e');
    }
  }

  // Add a new template (for admin/testing purposes)
  Future<String> addTemplate(Template template) async {
    try {
      final DocumentReference docRef =
          await _firestore.collection(_collection).add(template.toMap());

      // Clear cache to ensure fresh data on next fetch
      _cachedTemplates = null;
      _lastFetched = null;

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add template: $e');
    }
  }

  // Update an existing template
  Future<void> updateTemplate(String templateId, Template template) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(templateId)
          .update(template.toMap());

      // Clear cache to ensure fresh data on next fetch
      _cachedTemplates = null;
      _lastFetched = null;
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  // Delete a template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _firestore.collection(_collection).doc(templateId).delete();

      // Clear cache to ensure fresh data on next fetch
      _cachedTemplates = null;
      _lastFetched = null;
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  // Clear cache manually
  void clearCache() {
    _cachedTemplates = null;
    _lastFetched = null;
  }

  // Get template by ID
  Future<Template?> getTemplateById(String templateId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(templateId).get();

      if (doc.exists) {
        return Template.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch template: $e');
    }
  }
}

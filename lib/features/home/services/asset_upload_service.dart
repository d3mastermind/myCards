import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycards/class/template.dart';

class AssetUploadService {
  static final AssetUploadService _instance = AssetUploadService._internal();
  factory AssetUploadService() => _instance;
  AssetUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Map of folder names to category names for better naming
  final Map<String, String> _folderToCategoryMap = {
    'birthday': 'Birthday',
    'chinese_new_year': 'Chinese New Year',
    'christmas': 'Christmas',
    'diwali': 'Diwali',
    'easter': 'Easter',
    'fathers_day': "Father's Day",
    'good_friday': 'Good Friday',
    'graduation': 'Graduation',
    'halloween': 'Halloween',
    'independence': 'Independence Day',
    'mothers_day': "Mother's Day",
    'new_year': 'New Year',
    'others': 'Others',
    'ramadan': 'Ramadan',
    'valentine': 'Valentine',
    'vesak_day': 'Vesak Day',
    'wedding': 'Wedding',
  };

  // List of card folders and their files (predefined based on assets structure)
  final Map<String, List<String>> _cardAssets = {
    'birthday': [
      'FO113F68AC145HH.png',
      'FO3D53543E41l.png',
      'FO3D53543E41e.png',
      'FO3D53543E41j.png',
      'FO3D53543E41a.png',
      'FO3D53543E41g.png',
      'FO3D53543E41f.png',
      'FO3D53543E41i.png',
      'FO3D53543E41k.png',
      'FO3D53543E41b.png',
      'FO3D53543E41h.png',
      'FO3D53543E41c.png',
      'FO3D53543E41d.png',
      'FO41361234F42a-1.png',
      'FO41361234F42e-1.png',
      'FO41361234F42i-1.png',
      'FO41361234F42c-2.png',
      'FO41361234F42h.png',
      'FO41361234F42g-1.png',
      'FO41361234F42b-1.png',
      'FO41361234F42d-2.png',
      'FO41361234F42f-1.png',
      'FO82032D2E402f-1.png',
      'FO82032D2E402h.png',
      'FO82032D2E402d-1.png',
      'FO82032D2E402g-2.png',
      'FO82032D2E402e.png',
    ],
    'chinese_new_year': [
      'FO41361234F42e.png',
      'FO41361234F42d-1.png',
      'FO41361234F42f.png',
      'FO82032D2E402L.png',
      'FO82032D2E402m.png',
      'FO82032D2E402k.png',
    ],
    'christmas': [
      'FO41361234F42a-5.png',
      'FO113F68AC145u.png',
      'FO82032D2E402c-2.png',
      'FO82032D2E402a-8.png',
      'FO82032D2E402b-1.png',
    ],
    'diwali': [
      'FO41361234F42b-3.png',
      'FO82032D2E402o-1.png',
    ],
    'easter': [
      'FO41361234F42c-4.png',
    ],
    'fathers_day': [
      'FO113F68AC145KK.png',
      'FO113F68AC145l.png',
    ],
    'good_friday': [
      'FO113F68AC145h.png',
    ],
    'graduation': [
      'FO113F68AC145y.png',
      'FO41361234F42c-1.png',
      'FO41361234F42d-4.png',
    ],
    'halloween': [
      'FO113F68AC145m.png',
    ],
    'independence': [
      'FO41361234F42b-4.png',
    ],
    'mothers_day': [
      'FO113F68AC145d.png',
      'FO113F68AC145AA.png',
      'FO113F68AC145b.png',
      'FO113F68AC145DD.png',
      'FO113F68AC145LL.png',
    ],
    'new_year': [
      'FO41361234F42e-2.png',
      'FO41361234F42f-2.png',
    ],
    'others': [
      'FO41361234F42a-3.png',
      'FO41361234F42b-2.png',
      'FO113F68AC145FF.png',
      'FO113F68AC145f.png',
      'FO113F68AC145CC.png',
      'FO113F68AC145e.png',
      'FO113F68AC145g.png',
      'FO113F68AC145p.png',
      'FO113F68AC145BB.png',
      'FO113F68AC145a.png',
      'FO113F68AC145n.png',
      'FO113F68AC145k.png',
      'FO113F68AC145o.png',
      'FO113F68AC145II.png',
      'FO113F68AC145j.png',
      'FO113F68AC145i.png',
      'FO113F68AC145JJ.png',
      'FO113F68AC145z.png',
      'FO113F68AC145t.png',
      'FO113F68AC145w.png',
      'FO113F68AC145x.png',
      'FO113F68AC145s.png',
      'FO113F68AC145r.png',
    ],
    'ramadan': [
      'FO41361234F42c-3.png',
      'FO82032D2E402n.png',
    ],
    'valentine': [
      'FO113F68AC145v.png',
      'FO41361234F42f-3.png',
      'FO41361234F42c.png',
      'FO82032D2E402i-1.png',
      'FO82032D2E402j-2.png',
    ],
    'vesak_day': [
      'FO41361234F42a-4.png',
    ],
    'wedding': [
      'FO41361234F42g.png',
      'FO41361234F42h-1.png',
      'FO113F68AC145GG.png',
      'FO41361234F42h-2.png',
      'FO41361234F42j-1.png',
      'FO41361234F42l.png',
      'FO41361234F42k-1.png',
      'FO41361234F42m-1.png',
      'FO41361234F42n.png',
      'FO41361234F42p.png',
      'FO41361234F42b.png',
      'FO41361234F42a.png',
    ],
  };

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Upload all card assets to Firebase Storage and create Firestore documents
  Future<Map<String, dynamic>> uploadAllCardAssets({
    Function(String)? onProgress,
    Function(String)? onError,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to upload assets');
    }

    // Debug authentication info
    final user = _auth.currentUser;
    print('Upload Service - User authenticated: ${user != null}');
    print('Upload Service - User ID: ${user?.uid}');
    print('Upload Service - User email: ${user?.email}');

    final results = <String, dynamic>{
      'totalProcessed': 0,
      'successful': 0,
      'failed': 0,
      'errors': <String>[],
      'templates': <Template>[],
    };

    int totalAssets = 0;
    for (final files in _cardAssets.values) {
      totalAssets += files.length;
    }

    int processedCount = 0;
    onProgress?.call('Starting upload of $totalAssets assets...');

    try {
      // Check if templates collection already has documents to avoid duplicates
      final existingTemplates = await _firestore.collection('templates').get();
      final existingIds = existingTemplates.docs.map((doc) => doc.id).toSet();

      for (final entry in _cardAssets.entries) {
        final folderName = entry.key;
        final files = entry.value;
        final category = _folderToCategoryMap[folderName] ?? folderName;

        onProgress?.call('Processing $category category...');

        for (final fileName in files) {
          processedCount++;
          final templateId = fileName.replaceAll('.png', '');

          // Skip if template already exists
          if (existingIds.contains(templateId)) {
            onProgress?.call(
                '[$processedCount/$totalAssets] Skipping existing: $fileName');
            results['totalProcessed']++;
            continue;
          }

          try {
            onProgress
                ?.call('[$processedCount/$totalAssets] Uploading: $fileName');

            // Load asset as bytes
            final assetPath = 'assets/cards/$folderName/$fileName';
            print('Loading asset: $assetPath');

            final ByteData assetData = await rootBundle.load(assetPath);
            final Uint8List bytes = assetData.buffer.asUint8List();
            print(
                'Asset loaded successfully: $fileName (${bytes.length} bytes)');

            // Upload to Firebase Storage
            final storageRef =
                _storage.ref().child('templates/$folderName/$fileName');
            print(
                'Uploading to Firebase Storage: templates/$folderName/$fileName');

            final uploadTask = storageRef.putData(
              bytes,
              SettableMetadata(
                contentType: 'image/png',
                customMetadata: {
                  'originalPath': assetPath,
                  'category': category,
                  'uploadedBy': _auth.currentUser!.uid,
                  'uploadedAt': DateTime.now().toIso8601String(),
                },
              ),
            );

            // Wait for upload to complete
            final snapshot = await uploadTask;
            final downloadUrl = await snapshot.ref.getDownloadURL();
            print('Upload successful: $fileName -> $downloadUrl');

            // Create template name from filename and category
            final templateName = _generateTemplateName(fileName, category);

            // Create Template object
            final template = Template(
              templateId: templateId,
              name: templateName,
              category: category,
              isPremium: true,
              price: 10,
              frontCover: downloadUrl,
            );

            // Add to Firestore with custom document ID
            await _firestore
                .collection('templates')
                .doc(templateId)
                .set(template.toMap());
            print('Firestore document created: $templateId');

            results['successful']++;
            results['templates'].add(template);
            onProgress
                ?.call('[$processedCount/$totalAssets] ✅ Completed: $fileName');
          } catch (e) {
            results['failed']++;
            final errorMsg = 'Failed to process $fileName: $e';
            results['errors'].add(errorMsg);
            onError?.call(errorMsg);
            onProgress
                ?.call('[$processedCount/$totalAssets] ❌ Failed: $fileName');
            print('Error processing $fileName: $e');
          }

          results['totalProcessed']++;
        }
      }

      onProgress?.call(
          '🎉 Upload completed! Processed: ${results['totalProcessed']}, Successful: ${results['successful']}, Failed: ${results['failed']}');
    } catch (e) {
      final errorMsg = 'Upload process failed: $e';
      results['errors'].add(errorMsg);
      onError?.call(errorMsg);
      throw Exception(errorMsg);
    }

    return results;
  }

  // Generate a human-readable template name from filename and category
  String _generateTemplateName(String fileName, String category) {
    // Remove file extension
    final baseName = fileName.replaceAll('.png', '');

    // Create descriptive names based on category and filename patterns
    return _createDescriptiveName(baseName, category);
  }

  // Create descriptive template names based on patterns and category
  String _createDescriptiveName(String baseName, String category) {
    // Name variations for different categories
    final Map<String, List<String>> nameTemplates = {
      'Birthday': [
        'Colorful Birthday Celebration',
        'Happy Birthday Wishes',
        'Birthday Party Special',
        'Joyful Birthday Greetings',
        'Birthday Surprise Card',
        'Sweet Birthday Moments',
        'Birthday Festive Design',
        'Cheerful Birthday Card',
        'Birthday Cake Delight',
        'Special Birthday Wishes',
        'Birthday Joy & Happiness',
        'Elegant Birthday Design',
        'Fun Birthday Celebration',
        'Birthday Memory Card',
        'Vibrant Birthday Greetings',
        'Birthday Bliss Design',
        'Classic Birthday Wishes',
        'Modern Birthday Card',
        'Artistic Birthday Special',
        'Birthday Love & Care',
        'Magical Birthday Moments',
        'Birthday Dreams Come True',
        'Sparkling Birthday Card',
        'Birthday Wonderland',
        'Heartfelt Birthday Wishes',
        'Birthday Sunshine Design',
        'Golden Birthday Special',
      ],
      'Wedding': [
        'Elegant Wedding Invitation',
        'Royal Wedding Design',
        'Classic Wedding Card',
        'Romantic Wedding Wishes',
        'Beautiful Wedding Ceremony',
        'Wedding Love Story',
        'Traditional Wedding Design',
        'Modern Wedding Invitation',
        'Wedding Celebration Card',
        'Dreamy Wedding Wishes',
        'Wedding Bliss Design',
        'Sacred Wedding Moments',
      ],
      'Christmas': [
        'Merry Christmas Wishes',
        'Christmas Joy & Peace',
        'Festive Christmas Design',
        'Christmas Magic Card',
        'Holiday Christmas Greetings',
      ],
      'Valentine': [
        'Love & Romance Card',
        'Valentine Special Wishes',
        'Romantic Valentine Design',
        'Valentine Love Story',
        'Sweet Valentine Moments',
      ],
      'Mother\'s Day': [
        'Special Mom Appreciation',
        'Mother\'s Love & Care',
        'Beautiful Mom Wishes',
        'Mother\'s Day Special',
        'Mom\'s Day Celebration',
      ],
      'Father\'s Day': [
        'Best Dad Ever',
        'Father\'s Day Special',
      ],
      'Graduation': [
        'Graduation Success Card',
        'Achievement Celebration',
        'Graduation Congratulations',
      ],
      'Diwali': [
        'Happy Diwali Wishes',
        'Festival of Lights',
      ],
      'Ramadan': [
        'Ramadan Mubarak Wishes',
        'Blessed Ramadan Card',
      ],
      'Chinese New Year': [
        'Chinese New Year Greetings',
        'Lunar New Year Wishes',
        'Prosperity & Fortune Card',
        'New Year Blessings',
        'Golden New Year Design',
        'Traditional New Year Card',
      ],
      'New Year': [
        'Happy New Year Wishes',
        'New Year Celebration',
      ],
      'Easter': [
        'Easter Blessings Card',
      ],
      'Halloween': [
        'Spooky Halloween Card',
      ],
      'Independence Day': [
        'Independence Day Pride',
      ],
      'Good Friday': [
        'Good Friday Blessings',
      ],
      'Vesak Day': [
        'Vesak Day Blessings',
      ],
      'Others': [
        'Beautiful Greeting Card',
        'Special Occasion Wishes',
        'Elegant Design Card',
        'Artistic Greeting Design',
        'Classic Greeting Card',
        'Modern Greeting Design',
        'Colorful Greeting Card',
        'Stylish Design Card',
        'Creative Greeting Design',
        'Unique Greeting Card',
        'Premium Design Card',
        'Sophisticated Greeting',
        'Trendy Design Card',
        'Luxury Greeting Card',
        'Designer Greeting Card',
        'Custom Design Card',
        'Professional Greeting',
        'Minimalist Design Card',
        'Bold Greeting Design',
        'Vintage Style Card',
        'Contemporary Greeting',
        'Artistic Expression Card',
        'Creative Masterpiece',
      ],
    };

    // Get templates for the category
    final templates = nameTemplates[category] ?? nameTemplates['Others']!;

    // Use a hash of the base name to consistently assign the same name to the same file
    final hash = baseName.hashCode.abs();
    final index = hash % templates.length;

    return templates[index];
  }

  // Get upload progress for existing uploads
  Future<Map<String, dynamic>> getUploadStatus() async {
    try {
      final templatesSnapshot = await _firestore.collection('templates').get();
      final totalTemplates = templatesSnapshot.docs.length;

      int totalAssets = 0;
      for (final files in _cardAssets.values) {
        totalAssets += files.length;
      }

      return {
        'totalAssets': totalAssets,
        'uploadedTemplates': totalTemplates,
        'remainingAssets': totalAssets - totalTemplates,
        'isComplete': totalTemplates >= totalAssets,
      };
    } catch (e) {
      throw Exception('Failed to get upload status: $e');
    }
  }

  // Clear all uploaded templates (use with caution!)
  Future<void> clearAllTemplates() async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to clear templates');
    }

    try {
      final batch = _firestore.batch();
      final templatesSnapshot = await _firestore.collection('templates').get();

      for (final doc in templatesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear templates: $e');
    }
  }
}

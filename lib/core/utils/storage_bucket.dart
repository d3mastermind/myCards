import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycards/core/utils/logger.dart';

/// Key used for the Hive box that will store all local cache data
const localCacheBox = "local_cache";

/// A utility class that manages local data persistence using Hive
///
/// [StorageBucket] provides methods to store and retrieve various data types:
/// - Built-in types (String, bool)
/// - Complex objects (using JSON serialization)
/// - Lists of objects
///
/// Usage Example:
/// ```dart
/// // Initialize Hive before using StorageBucket
/// await Hive.initFlutter();
/// await Hive.openBox(localCacheBox);
///
/// // Create an instance of StorageBucket (Preferrablely with a singleton pattern)
/// final StorageBucket = StorageBucket();
/// ```
class StorageBucket {
  // Commented out secure storage option - may be needed for sensitive data in future
  // final secureStorage = const FlutterSecureStorage();

  /// The Hive box instance used for all storage operations
  late final Box _localCache;

  /// Constructor initializes the Hive box for local storage
  ///
  /// Note: Ensure Hive is initialized and the box is opened before creating this class
  /// through `Hive.initFlutter()` and `Hive.openBox(localCacheBox)`
  StorageBucket() {
    _localCache = Hive.box(localCacheBox);
  }

  /// Stores a String value with the specified key
  ///
  /// Example:
  /// ```dart
  /// await StorageBucket.storeBuiltInType('username', 'john_doe');
  /// ```
  Future<void> storeBuiltInType(String key, String value) async {
    await _localCache.put(key, value);
  }

  /// Retrieves a previously stored String value using its key
  ///
  /// Returns null if the key doesn't exist
  ///
  /// Example:
  /// ```dart
  /// String? username = await StorageBucket.getCachedBuiltInType('username');
  /// ```
  Future<String?> getCachedBuiltInType(String key) async {
    return await _localCache.get(key);
  }

  /// Stores a complex object by converting it to JSON
  ///
  /// The object must have a toJson method or function provided
  ///
  /// Parameters:
  /// - key: Unique identifier for the stored object
  /// - object: The object to store
  /// - toJson: Function that converts the object to a Map<String, dynamic>
  ///
  /// Example:
  /// ```dart
  /// final user = User(id: '1', name: 'John');
  /// await StorageBucket.storeObject('currentUser', user, User.toJson);
  /// ```
  Future<void> storeObject<T>(
    String key,
    T object,
    Map<String, dynamic> Function(T obj) toJson,
  ) async {
    final json = toJson(object);
    final jsonString = jsonEncode(json);
    await _localCache.put(key, jsonString);
  }

  /// Retrieves a complex object using its key and a fromJson function
  ///
  /// Parameters:
  /// - key: Unique identifier for the stored object
  /// - fromJson: Function that creates an object from a Map<String, dynamic>
  ///
  /// Returns:
  /// - The deserialized object of type T or null if not found
  ///
  /// Example:
  /// ```dart
  /// User? currentUser = StorageBucket.getCachedObject('currentUser', User.fromJson);
  /// ```
  T? getCachedObject<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final jsonString = _localCache.get(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    }
    return null;
  }

  /// Stores a list of objects by converting each to JSON
  ///
  /// Parameters:
  /// - listKey: Unique identifier for the stored list
  /// - objects: List of objects to store
  /// - toJson: Function that converts each object to a Map<String, dynamic>
  ///
  /// Example:
  /// ```dart
  /// final products = [Product(id: '1'), Product(id: '2')];
  /// await StorageBucket.storeObjectList('recentProducts', products, Product.toJson);
  /// ```
  Future<void> storeObjectList<T>(
    String listKey,
    List<T> objects,
    Map<String, dynamic> Function(T obj) toJson,
  ) async {
    try {
      final List<Map<String, dynamic>> jsonList = objects.map(toJson).toList();
      final String jsonString = jsonEncode(jsonList);
      await _localCache.put(listKey, jsonString);
    } catch (e) {
      AppLogger.logError(
        "Error trying to store List of Objects in cached memory",
        tag: "StorageBucket",
      );
    }
  }

  /// Retrieves a list of objects using the list key and a fromJson function
  ///
  /// Parameters:
  /// - listKey: Unique identifier for the stored list
  /// - fromJson: Function that creates an object from a Map<String, dynamic>
  ///
  /// Returns:
  /// - A list of deserialized objects of type T or null if not found or on error
  ///
  /// Example:
  /// ```dart
  /// List<Product>? recentProducts = StorageBucket.getObjectList('recentProducts', Product.fromJson);
  /// ```
  List<T>? getObjectList<T>(
    String listKey,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final String? jsonString = _localCache.get(listKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.logError(
        "Error trying to get List of Objects from cached memory",
        tag: "StorageBucket",
      );
    }

    return null;
  }

  /// Deletes a stored value by its key
  ///
  /// Example:
  /// ```dart
  /// await StorageBucket.deleteStoredBuiltInType('username');
  /// ```
  Future<void> deleteStoredBuiltInType(String key) async {
    await _localCache.delete(key);
  }

  /// Stores a boolean value with the specified key
  ///
  /// Example:
  /// ```dart
  /// await StorageBucket.storeBool('isLoggedIn', true);
  /// ```
  Future<void> storeBool(String key, bool value) async {
    await _localCache.put(key, value);
  }

  /// Retrieves a previously stored boolean value using its key
  ///
  /// Returns null if the key doesn't exist
  ///
  /// Example:
  /// ```dart
  /// bool? isLoggedIn = StorageBucket.getBool('isLoggedIn');
  /// ```
  bool? getBool(String key) {
    return _localCache.get(key) as bool?;
  }
}

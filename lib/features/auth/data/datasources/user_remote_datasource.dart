import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  Future<bool> userExists(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'users';

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await firestore
          .collection(_collection)
          .doc(user.userId)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection(_collection).doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await firestore
          .collection(_collection)
          .doc(user.userId)
          .update(updatedUser.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection(_collection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }
}

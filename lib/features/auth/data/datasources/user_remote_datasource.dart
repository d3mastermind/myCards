import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'users';

  UserRemoteDataSourceImpl({required this.firestore});

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
}

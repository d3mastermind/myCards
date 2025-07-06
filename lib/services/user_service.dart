import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycards/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:mycards/features/auth/data/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UserRemoteDataSource _userDataSource;

  UserService._internal() {
    _userDataSource = UserRemoteDataSourceImpl(firestore: _firestore);
  }

  // Create user document in Firestore after successful authentication
  Future<void> createUserDocument({
    required String email,
    String? phoneNumber,
    String? name,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if user document already exists
      final bool exists = await _userDataSource.userExists(currentUser.uid);
      if (exists) {
        print('User document already exists for: ${currentUser.uid}');
        return;
      }

      // Create new user document
      final UserModel user = UserModel(
        userId: currentUser.uid,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
        creditBalance: 10, // Default credit balance
        purchasedCards: [],
        likedCards: [],
        receivedCards: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userDataSource.createUser(user);

      // Create credits subcollection with initial balance
      await _createInitialCredits(currentUser.uid);

      print(
          'User document and credits created successfully for: ${currentUser.uid}');
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  // Create initial credits subcollection
  Future<void> _createInitialCredits(String userId) async {
    try {
      // Create credits/balance document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('balance')
          .set({
        'balance': 10,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create initial transaction record
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
        'userId': userId,
        'amount': 10,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'purchase',
        'status': 'completed',
        'description': 'Welcome bonus credits',
        'paymentMethod': 'signup_bonus',
      });

      print('Initial credits created for user: $userId');
    } catch (e) {
      print('Error creating initial credits: $e');
      throw Exception('Failed to create initial credits: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      return await _userDataSource.getUser(currentUser.uid);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _userDataSource.updateUser(user);
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // Add card to purchased cards
  Future<void> addPurchasedCard(String cardId) async {
    try {
      final UserModel? currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final List<String> updatedPurchasedCards =
          List.from(currentUser.purchasedCards);
      if (!updatedPurchasedCards.contains(cardId)) {
        updatedPurchasedCards.add(cardId);
      }

      final updatedUser = currentUser.copyWith(
        purchasedCards: updatedPurchasedCards,
        updatedAt: DateTime.now(),
      );

      await _userDataSource.updateUser(updatedUser);
    } catch (e) {
      print('Error adding purchased card: $e');
      throw Exception('Failed to add purchased card: $e');
    }
  }

  // Add card to liked cards
  Future<void> addLikedCard(String cardId) async {
    try {
      final UserModel? currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final List<String> updatedLikedCards = List.from(currentUser.likedCards);
      if (!updatedLikedCards.contains(cardId)) {
        updatedLikedCards.add(cardId);
      }

      final updatedUser = currentUser.copyWith(
        likedCards: updatedLikedCards,
        updatedAt: DateTime.now(),
      );

      await _userDataSource.updateUser(updatedUser);
    } catch (e) {
      print('Error adding liked card: $e');
      throw Exception('Failed to add liked card: $e');
    }
  }

  // Add card to received cards
  Future<void> addReceivedCard(String cardId) async {
    try {
      final UserModel? currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final List<String> updatedReceivedCards =
          List.from(currentUser.receivedCards);
      if (!updatedReceivedCards.contains(cardId)) {
        updatedReceivedCards.add(cardId);
      }

      final updatedUser = currentUser.copyWith(
        receivedCards: updatedReceivedCards,
        updatedAt: DateTime.now(),
      );

      await _userDataSource.updateUser(updatedUser);
    } catch (e) {
      print('Error adding received card: $e');
      throw Exception('Failed to add received card: $e');
    }
  }


}

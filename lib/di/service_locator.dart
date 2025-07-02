import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final fireStoreProvider = Provider<FirebaseFirestore>((ref) => firestore);




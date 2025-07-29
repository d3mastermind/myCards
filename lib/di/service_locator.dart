import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/core/utils/storage_bucket.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final fireStoreProvider = Provider<FirebaseFirestore>((ref) => firestore);

final storageBucketProvider = Provider<StorageBucket>((ref) => StorageBucket());

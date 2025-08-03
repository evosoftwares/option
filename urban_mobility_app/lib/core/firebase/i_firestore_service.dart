import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFirestoreService {
  FirebaseFirestore get instance;

  CollectionReference<T> collectionWithConverter<T>({
    required String path,
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  });

  Future<DocumentReference> add(String path, Map<String, dynamic> data);

  Future<void> set(String docPath, Map<String, dynamic> data, {bool merge = true});

  Future<void> update(String docPath, Map<String, dynamic> data);

  Future<DocumentSnapshot> get(String docPath);

  Stream<DocumentSnapshot> watchDoc(String docPath);

  Stream<QuerySnapshot> watchCollection(String path, {Query Function(Query)? queryBuilder});
}
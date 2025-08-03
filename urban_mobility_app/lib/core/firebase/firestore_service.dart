import 'package:cloud_firestore/cloud_firestore.dart';
import 'i_firestore_service.dart';

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  FirebaseFirestore get instance => _db;

  @override
  CollectionReference<T> collectionWithConverter<T>({
    required String path,
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return _db.collection(path).withConverter<T>(
          fromFirestore: fromFirestore,
          toFirestore: toFirestore,
        );
  }

  @override
  Future<DocumentReference> add(String path, Map<String, dynamic> data) async {
    return _db.collection(path).add(data);
  }

  @override
  Future<void> set(String docPath, Map<String, dynamic> data, {bool merge = true}) async {
    await _db.doc(docPath).set(data, SetOptions(merge: merge));
  }

  @override
  Future<void> update(String docPath, Map<String, dynamic> data) async {
    await _db.doc(docPath).update(data);
  }

  @override
  Future<DocumentSnapshot> get(String docPath) {
    return _db.doc(docPath).get();
  }

  @override
  Stream<DocumentSnapshot> watchDoc(String docPath) {
    return _db.doc(docPath).snapshots();
  }

  @override
  Stream<QuerySnapshot> watchCollection(String path, {Query Function(Query)? queryBuilder}) {
    Query query = _db.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}
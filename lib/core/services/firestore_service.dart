import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    _validatePath(path);
    return _firestore.collection(path.trim());
  }

  DocumentReference<Map<String, dynamic>> document(String path) {
    _validatePath(path);
    return _firestore.doc(path.trim());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) =>
      document(path).get();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String path) =>
      document(path).snapshots();

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String path, {
    Query<Map<String, dynamic>> Function(
      Query<Map<String, dynamic>> query,
    )? build,
  }) {
    Query<Map<String, dynamic>> query = collection(path);
    if (build != null) query = build(query);
    return query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
    String path, {
    Query<Map<String, dynamic>> Function(
      Query<Map<String, dynamic>> query,
    )? build,
  }) {
    Query<Map<String, dynamic>> query = collection(path);
    if (build != null) query = build(query);
    return query.snapshots();
  }

  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) => document(path).set(
        Map<String, dynamic>.from(data),
        SetOptions(merge: merge),
      );

  Future<void> updateDocument(String path, Map<String, dynamic> data) =>
      document(path).update(Map<String, dynamic>.from(data));

  Future<void> deleteDocument(String path) => document(path).delete();

  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) => collection(collectionPath).add(Map<String, dynamic>.from(data));

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) => _firestore.runTransaction<T>(action);

  WriteBatch batch() => _firestore.batch();

  void _validatePath(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'path', 'Path cannot be empty.');
    }
  }
}

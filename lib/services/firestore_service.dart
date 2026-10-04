import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // =========================================================
  // Current user
  // =========================================================

  User? get currentUser => _auth.currentUser;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    return user.uid;
  }

  // =========================================================
  // USER
  // =========================================================

  Future<void> createOrUpdateUser({
    required String name,
    required String email,
    String profileImage = '',
  }) async {
    final uid = currentUserId;

    await _usersCollection.doc(uid).set(
      {
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = currentUserId;

    final snapshot = await _usersCollection.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // =========================================================
  // CREATE POST
  // =========================================================

  Future<String> addPost(PostModel post) async {
    final uid = currentUserId;

    final document = _postsCollection.doc();

    final postData = post.toFirestore();

    postData['id'] = document.id;
    postData['userId'] = uid;
    postData['createdAt'] = FieldValue.serverTimestamp();

    await document.set(postData);

    return document.id;
  }

  // =========================================================
  // GET ALL POSTS
  // =========================================================

  Stream<List<PostModel>> postsStream() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (document) {
                return PostModel.fromJson({
                  ...document.data(),
                  'id': document.id,
                });
              },
            ).toList();
          },
        );
  }

  // =========================================================
  // GET CURRENT USER POSTS
  // =========================================================

  Stream<List<PostModel>> myPostsStream() {
    final uid = currentUserId;

    return _postsCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) {
            final posts = snapshot.docs.map(
              (document) {
                return PostModel.fromJson({
                  ...document.data(),
                  'id': document.id,
                });
              },
            ).toList();

            // Sorted locally so no composite Firestore index is needed.
            // Posts whose server timestamp is still pending go first.
            posts.sort((a, b) {
              final aDate = a.createdAt;
              final bDate = b.createdAt;

              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return -1;
              if (bDate == null) return 1;

              return bDate.compareTo(aDate);
            });

            return posts;
          },
        );
  }

  // =========================================================
  // GET ONE POST
  // =========================================================

  Future<PostModel?> getPost(String postId) async {
    final document = await _postsCollection.doc(postId).get();

    if (!document.exists) {
      return null;
    }

    return PostModel.fromJson({
      ...document.data()!,
      'id': document.id,
    });
  }

  // =========================================================
  // UPDATE POST
  // =========================================================

  Future<void> updatePost(PostModel post) async {
    final uid = currentUserId;

    final document = await _postsCollection.doc(post.id).get();

    if (!document.exists) {
      throw Exception('Post not found.');
    }

    final existingData = document.data();

    if (existingData == null || existingData['userId'] != uid) {
      throw Exception('You can only update your own posts.');
    }

    final updatedData = post.toFirestore();

    // Keep the original creation time.
    updatedData.remove('createdAt');

    // Keep the original post ID.
    updatedData.remove('id');

    // Keep the original owner.
    updatedData.remove('userId');

    await _postsCollection.doc(post.id).update(
      updatedData,
    );
  }

  // =========================================================
  // DELETE POST
  // =========================================================

  Future<void> deletePost(String postId) async {
    final uid = currentUserId;

    final document = await _postsCollection.doc(postId).get();

    if (!document.exists) {
      return;
    }

    final data = document.data();

    if (data == null || data['userId'] != uid) {
      throw Exception('You can only delete your own posts.');
    }

    await _postsCollection.doc(postId).delete();
  }
}
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';

// =============================================================================
// STATE
// =============================================================================

@immutable
class PostsState {
  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  /// All posts, newest first, exactly as stored in Firestore.
  final List<PostModel> posts;

  /// True until the first Firestore snapshot arrives.
  final bool isLoading;

  /// Last stream error (if any). Shown as a friendly message by the UI.
  final Object? error;

  /// Posts that belong to [userId].
  List<PostModel> postsOf(String? userId) {
    if (userId == null || userId.isEmpty) return const [];

    return posts.where((post) => post.userId == userId).toList();
  }
}

// =============================================================================
// CUBIT
// =============================================================================

/// Firestore is the single source of truth.
///
/// Firestore `posts` stream -> PostsCubit -> Home / My Posts / Saved.
///
/// Create / update / delete go straight to Firestore; the UI updates when the
/// stream emits the new snapshot, so no local copy has to be kept in sync.
class PostsCubit extends Cubit<PostsState> {
  PostsCubit({
    FirestoreService? firestoreService,
    FirebaseAuth? auth,
  })  : _firestore = firestoreService ?? FirestoreService.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const PostsState(isLoading: true)) {
    // Start / stop listening to posts when the user logs in / out.
    _authSubscription = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirestoreService _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<PostModel>>? _postsSubscription;
  String? _listeningForUid;

  String? get currentUserId => _auth.currentUser?.uid;

  // ---------------------------------------------------------------------------
  // STREAM
  // ---------------------------------------------------------------------------

  void _onAuthChanged(User? user) {
    if (user == null) {
      _listeningForUid = null;
      _postsSubscription?.cancel();
      _postsSubscription = null;
      _safeEmit(const PostsState());
      return;
    }

    // Already listening for this user.
    if (_listeningForUid == user.uid && _postsSubscription != null) {
      return;
    }

    _listen(user.uid);
  }

  void _listen(String uid) {
    _postsSubscription?.cancel();
    _listeningForUid = uid;

    _safeEmit(
      PostsState(
        posts: state.posts,
        isLoading: true,
      ),
    );

    _postsSubscription = _firestore.postsStream().listen(
      (posts) {
        _safeEmit(
          PostsState(
            posts: posts,
          ),
        );
      },
      onError: (Object error) {
        debugPrint('[PostsCubit] posts stream error: $error');

        _safeEmit(
          PostsState(
            posts: state.posts,
            error: error,
          ),
        );
      },
    );
  }

  /// Re-subscribes to Firestore (e.g. after an error).
  void refresh() {
    final uid = currentUserId;

    if (uid != null) {
      _listen(uid);
    }
  }

  // ---------------------------------------------------------------------------
  // WRITES (Firestore is updated; the stream updates the UI)
  // ---------------------------------------------------------------------------

  /// Creates a post and returns its Firestore document ID.
  Future<String> addPost(PostModel post) {
    return _firestore.addPost(post);
  }

  /// Updates an existing post (id, userId and createdAt are preserved).
  Future<void> updatePost(PostModel post) {
    return _firestore.updatePost(post);
  }

  /// Deletes the post document from Firestore.
  ///
  /// Images are stored on Cloudinary, so there is no Firebase Storage
  /// deletion here.
  Future<void> deletePost(PostModel post) {
    return _firestore.deletePost(post.id);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _safeEmit(PostsState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() async {
    await _postsSubscription?.cancel();
    await _authSubscription?.cancel();

    return super.close();
  }
}
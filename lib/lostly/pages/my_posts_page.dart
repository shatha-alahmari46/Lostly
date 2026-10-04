import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/app_language.dart';
import '/cubits/posts_cubit.dart';
import '/models/post_model.dart';
import '/utils/post_ui.dart';
import 'create_post_page.dart';
import 'item_details_page.dart';

/// Shows only the posts of the signed-in user, live from Firestore
/// (through PostsCubit). Edit / delete write directly to Firestore.
class MyPostsPage extends StatefulWidget {
  const MyPostsPage({
    super.key,
    required this.appLanguage,
  });

  final AppLanguage appLanguage;

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  static const Color rose = Color(0xFFB66568);
  static const Color roseLight = Color(0xFFF3DDE0);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  bool get isArabic => widget.appLanguage.isArabic;

  // Firestore models of the posts currently shown, by document id.
  Map<String, PostModel> _postsById = const {};

  bool _isDeleting = false;

  final Set<String> _savedIds = <String>{};

  String get _savedKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'saved_posts_$uid';
  }

  @override
  void initState() {
    super.initState();
    widget.appLanguage.addListener(_onLanguageChanged);
    _loadSavedIds();
  }

  @override
  void dispose() {
    widget.appLanguage.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedKey) ?? const <String>[];

    if (!mounted) return;

    setState(() {
      _savedIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future<void> _persistSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, _savedIds.toList());
  }

  bool _isSaved(Map<String, dynamic> item) {
    return _savedIds.contains(item['id']?.toString());
  }

  Future<void> _toggleSaved(Map<String, dynamic> item) async {
    final id = item['id']?.toString();

    if (id == null || id.isEmpty) return;

    if (mounted) {
      setState(() {
        if (_savedIds.contains(id)) {
          _savedIds.remove(id);
        } else {
          _savedIds.add(id);
        }
      });
    } else {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    }

    await _persistSavedIds();
  }

  String get pageTitle => isArabic ? 'منشوراتي' : 'My Posts';

  String categoryName(String category) {
    if (!isArabic) {
      return category;
    }

    switch (category) {
      case 'All':
        return 'الكل';
      case 'Electronics':
        return 'إلكترونيات';
      case 'Accessories':
        return 'إكسسوارات';
      case 'Documents':
        return 'مستندات';
      case 'Bags':
        return 'حقائب';
      case 'Keys':
        return 'مفاتيح';
      case 'Clothing':
        return 'ملابس';
      case 'Books':
        return 'كتب';
      case 'Jewelry':
        return 'مجوهرات';
      case 'Others':
        return 'أخرى';
      default:
        return category;
    }
  }

  String statusName(String status) {
    if (!isArabic) {
      return status;
    }

    switch (status) {
      case 'Lost':
        return 'مفقود';
      case 'Found':
        return 'تم العثور عليه';
      default:
        return status;
    }
  }

  String timeName(String time) {
    if (!isArabic) {
      return time;
    }

    switch (time) {
      case 'Just now':
        return 'الآن';
      case 'Today':
        return 'اليوم';
      case 'Yesterday':
        return 'أمس';
      default:
        return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsCubit = context.watch<PostsCubit>();
    final postsState = postsCubit.state;
    final uid = postsCubit.currentUserId;

    // Only the current user's posts.
    final myPosts = postsState.postsOf(uid);

    _postsById = {
      for (final post in myPosts) post.id: post,
    };

    final posts = myPosts
        .map((post) => PostUi.toItem(post, isArabic: isArabic))
        .toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 25,
            color: darkBrown,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          pageTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: postsState.isLoading && posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: rose,
                strokeWidth: 2.2,
              ),
            )
          : posts.isEmpty
              ? _emptyState(context)
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    // Card size/shape kept exactly as before.
                    crossAxisCount: 1,
                    crossAxisSpacing: 0.30,
                    mainAxisSpacing: 11.8,
                    mainAxisExtent: 250,
                  ),
                  itemBuilder: (context, index) {
                    final item = posts[index];

                    return _postCard(context, item);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: rose,
        elevation: 0,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.home_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  // ================================================================
  // POST CARD
  // ================================================================

  Widget _postCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final String rawName = item['name']?.toString() ?? '';

    final String name = rawName.trim().isNotEmpty
        ? rawName
        : (isArabic ? 'غرض بدون اسم' : 'Unnamed item');

    final String status = item['status']?.toString() ?? 'Lost';

    final String category =
        item['category']?.toString() ?? 'Others';

    final String time =
        item['time']?.toString() ?? 'Just now';

    final String location =
        item['location']?.toString() ?? '';

    final String? imageUrl =
        item['imageUrl']?.toString();

    final IconData icon = item['icon'] is IconData
        ? item['icon'] as IconData
        : Icons.category_outlined;

    final Color color = item['color'] is Color
        ? item['color'] as Color
        : rose;

    final Color imageBackground =
        item['background'] is Color
            ? item['background'] as Color
            : roseLight;

    final bool isFound = status == 'Found';

    final bool isSaved = _isSaved(item);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsPage(
              item: item,
              isSaved: isSaved,
              onToggleSaved: () {
                _toggleSaved(item);
              },
            ),
          ),
        );

        // Re-read favorites after returning from the details page.
        // This keeps My Posts synchronized with SharedPreferences.
        if (!mounted) return;

        await _loadSavedIds();
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: darkBrown.withValues(alpha: 0.055),
          ),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.045),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // IMAGE
            // ==========================================================

            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(7),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: imageBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl != null &&
                              imageUrl.trim().isNotEmpty
                          ? _buildImage(
                              imageUrl,
                              icon,
                              color,
                            )
                          : _imageFallback(
                              icon,
                              color,
                            ),
                    ),

                    // --------------------------------------------------
                    // STATUS
                    // --------------------------------------------------

                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isFound
                              ? const Color(0xFFE4EBDD)
                                  .withValues(alpha: 0.95)
                              : roseLight.withValues(alpha: 0.95),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        child: Text(
                          statusName(status),
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isFound
                                ? const Color(0xFF71876D)
                                : rose,
                          ),
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // CATEGORY ICON
                    // --------------------------------------------------

                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cardColor.withValues(
                            alpha: 0.94,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 14,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // INFORMATION
            // ==========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                11,
                1,
                11,
                11,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------------------
                  // NAME + MENU
                  // ----------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13.5,
                            fontWeight:
                                FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // SAVE BUTTON
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _toggleSaved(item);
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 14,
                            color: isSaved ? rose : mutedBrown,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      GestureDetector(
                        behavior:
                            HitTestBehavior.opaque,
                        onTap: () {
                          _showPostOptions(
                            context,
                            item,
                          );
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration:
                              BoxDecoration(
                            color: background,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            size: 16,
                            color: mutedBrown,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // ----------------------------------------------------
                  // CATEGORY + TIME
                  // ----------------------------------------------------

                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          categoryName(category),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9.5,
                            fontWeight:
                                FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.schedule_rounded,
                        size: 10.5,
                        color:
                            mutedBrown.withValues(
                          alpha: 0.75,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        timeName(time),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 9,
                          color: mutedBrown,
                        ),
                      ),
                    ],
                  ),

                  // ----------------------------------------------------
                  // LOCATION
                  // ----------------------------------------------------

                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color:
                              mutedBrown.withValues(
                            alpha: 0.75,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9,
                              color: mutedBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // OPTIONS
  // ================================================================

  void _showPostOptions(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedBrown.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment:
                      AlignmentDirectional.centerStart,
                  child: Text(
                    item['name']?.toString() ??
                        (isArabic ? 'المنشور' : 'Post'),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                      color: darkBrown,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // EDIT

                _optionTile(
                  icon: Icons.edit_outlined,
                  title: isArabic
                      ? 'تعديل المنشور'
                      : 'Edit Post',
                  color: darkBrown,
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final post =
                        _postsById[item['id']?.toString()];

                    if (post == null) return;

                    final navigator = Navigator.of(context);
                    final messenger =
                        ScaffoldMessenger.of(context);

                    // CreatePostPage updates Firestore; the list
                    // refreshes automatically from the stream.
                    final saved =
                        await navigator.push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            CreatePostPage(
                          initialPost: post,
                          appLanguage:
                              widget.appLanguage,
                        ),
                      ),
                    );

                    if (!mounted ||
                        saved != true) {
                      return;
                    }

                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor:
                            darkBrown,
                        behavior:
                            SnackBarBehavior.floating,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        content: Text(
                          isArabic
                              ? 'تم تحديث المنشور بنجاح.'
                              : 'Post updated successfully.',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        duration:
                            const Duration(
                          seconds: 2,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 5),

                // DELETE

                _optionTile(
                  icon:
                      Icons.delete_outline_rounded,
                  title: isArabic
                      ? 'حذف المنشور'
                      : 'Delete Post',
                  color:
                      const Color(0xFFC9796E),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _confirmDelete(
                      context,
                      item,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // OPTION TILE
  // ================================================================

  Widget _optionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12.5,
                fontWeight:
                    FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DELETE CONFIRMATION
  // ================================================================

  void _confirmDelete(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            isArabic
                ? 'حذف المنشور؟'
                : 'Delete Post?',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من رغبتك في حذف "${item['name'] ?? 'هذا المنشور'}"؟'
                : 'Are you sure you want to delete "${item['name'] ?? 'this post'}"?',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12.5,
              height: 1.4,
              color: mutedBrown,
            ),
          ),
          actions: [
            // CANCEL

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                isArabic
                    ? 'إلغاء'
                    : 'Cancel',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  color: mutedBrown,
                ),
              ),
            ),

            // DELETE

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _deletePost(
                  context,
                  item,
                );
              },
              child: Text(
                isArabic
                    ? 'حذف'
                    : 'Delete',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFFC9796E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // DELETE
  // ================================================================

  Future<void> _deletePost(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final post = _postsById[item['id']?.toString()];

    if (post == null || _isDeleting) return;

    _isDeleting = true;

    final messenger = ScaffoldMessenger.of(context);
    final postsCubit = context.read<PostsCubit>();

    String message;

    try {
      // Deletes the Firestore document.
      await postsCubit.deletePost(post);

      // Remove the deleted post from the local favorites.
      _savedIds.remove(post.id);
      await _persistSavedIds();

      message = isArabic
          ? 'تم حذف المنشور بنجاح.'
          : 'Post deleted successfully.';
    } catch (e) {
      debugPrint('[MyPosts] Delete failed: $e');

      message = PostUi.errorMessage(e, isArabic: isArabic);
    } finally {
      _isDeleting = false;
    }

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: darkBrown,
        behavior:
            SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
          ),
        ),
        duration:
            const Duration(seconds: 2),
      ),
    );
  }

  // ================================================================
  // IMAGE
  // ================================================================

  Widget _buildImage(
    String imageUrl,
    IconData icon,
    Color color,
  ) {
    // Cloudinary / Internet image
    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(
            icon,
            color,
          );
        },
      );
    }

    // Local asset image
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(
            icon,
            color,
          );
        },
      );
    }

    // Old local file paths
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _imageFallback(
          icon,
          color,
        );
      },
    );
  }

  // ================================================================
  // FALLBACK IMAGE
  // ================================================================

  Widget _imageFallback(
    IconData icon,
    Color color,
  ) {
    return Center(
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _emptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 35,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  const BoxDecoration(
                color: roseLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.post_add_rounded,
                size: 34,
                color: rose,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              isArabic
                  ? 'لا توجد منشورات بعد.'
                  : 'No posts yet.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 19,
                fontWeight:
                    FontWeight.w600,
                color: darkBrown,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              isArabic
                  ? 'أنشئ منشورًا للإبلاغ عن غرض مفقود أو تم العثور عليه.'
                  : 'Create a post to report a lost or found item.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 12.5,
                height: 1.35,
                color: mutedBrown,
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                // The new post appears here automatically
                // through the Firestore stream.
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreatePostPage(
                      appLanguage:
                          widget.appLanguage,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration:
                    BoxDecoration(
                  color: rose,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Text(
                  isArabic
                      ? 'أنشئ أول منشور لك'
                      : 'Create your first post',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cubits/posts_cubit.dart';
import '../../models/post_model.dart';
import '../../utils/post_ui.dart';

import 'saved_page.dart';
import '/app_language.dart';
import 'item_details_page.dart';
import 'categories_page.dart';
import 'create_post_page.dart';
import 'my_posts_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.appLanguage,
  });

  final AppLanguage appLanguage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color rose = Color(0xFFB66568);
  static const Color roseLight = Color(0xFFF3DDE0);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  bool get isArabic => widget.appLanguage.isArabic;

  String _categoryName(String category) {
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

  String _statusName(String status) {
    if (!isArabic) {
      return status;
    }

    switch (status) {
      case 'Found':
        return 'تم العثور عليه';
      case 'Lost':
        return 'مفقود';
      default:
        return status;
    }
  }

  // ===========================================================================
  // STATE
  // ===========================================================================

  int _currentIndex = 0;

  String selectedCategory = 'All';

  String searchText = '';

  // IDs of the posts saved by the current user (persisted per user).
  final Set<String> _savedIds = <String>{};

  // Latest items built from Firestore (used by the Saved page).
  List<Map<String, dynamic>> _latestItems = const [];

  // Current profile image selected by the user.
  String? _profileImagePath;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    widget.appLanguage.addListener(_onLanguageChanged);

    _loadSavedIds();
    _loadProfileImage();
  }

  @override
  void dispose() {
    widget.appLanguage.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ===========================================================================
  // SAVED ITEMS
  // ===========================================================================

  String get _savedKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'saved_posts_$uid';
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

  Future<void> _loadProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_$uid');

    if (!mounted) return;

    if (savedPath != null &&
        savedPath.isNotEmpty &&
        File(savedPath).existsSync()) {
      setState(() {
        _profileImagePath = savedPath;
      });
    } else {
      setState(() {
        _profileImagePath = null;
      });
    }
  }

  Future<void> _persistSavedIds() async {
    final key = _savedKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, _savedIds.toList());
  }

  bool _isSaved(Map<String, dynamic> item) {
    return _savedIds.contains(item['id']?.toString());
  }

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'All',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFFB66568),
      'lightColor': Color(0xFFF3DDE0),
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices_other_rounded,
      'color': Color(0xFF6E8FA3),
      'lightColor': Color(0xFFE2EDF2),
    },
    {
      'name': 'Accessories',
      'icon': Icons.watch_outlined,
      'color': Color(0xFF9A789A),
      'lightColor': Color(0xFFECE2EC),
    },
    {
      'name': 'Documents',
      'icon': Icons.description_outlined,
      'color': Color(0xFFB58A55),
      'lightColor': Color(0xFFF2E8D8),
    },
    {
      'name': 'Bags',
      'icon': Icons.backpack_outlined,
      'color': Color(0xFF7E9276),
      'lightColor': Color(0xFFE4EBDD),
    },
    {
      'name': 'Keys',
      'icon': Icons.key_outlined,
      'color': Color(0xFFB47B61),
      'lightColor': Color(0xFFF0DFD6),
    },
    {
      'name': 'Clothing',
      'icon': Icons.checkroom_outlined,
      'color': Color(0xFF7885A5),
      'lightColor': Color(0xFFE4E8F2),
    },
    {
      'name': 'Books',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF9B765F),
      'lightColor': Color(0xFFEEE2D9),
    },
    {
      'name': 'Jewelry',
      'icon': Icons.diamond_outlined,
      'color': Color(0xFFAA7184),
      'lightColor': Color(0xFFF0DEE4),
    },
    {
      'name': 'Others',
      'icon': Icons.more_horiz_rounded,
      'color': Color(0xFF7E827D),
      'lightColor': Color(0xFFE7E8E5),
    },
  ];

  // ===========================================================================
  // FILTERED ITEMS
  // ===========================================================================

  List<Map<String, dynamic>> _filterItems(
    List<Map<String, dynamic>> items,
  ) {
    final query = searchText.trim().toLowerCase();

    return items.where((item) {
      final category = item['category']?.toString() ?? '';
      final status = item['status']?.toString() ?? '';

      final matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;

      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final searchable = [
        item['name'],
        item['location'],
        item['brand'],
        item['itemColor'],
        item['description'],
        category,
        status,
        _categoryName(category),
        _statusName(status),
      ].map(
        (value) => (value ?? '').toString().toLowerCase(),
      );

      return searchable.any(
        (value) => value.contains(query),
      );
    }).toList();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final postsState = context.watch<PostsCubit>().state;

    // Firestore -> PostsCubit -> UI
    //
    // There are NO demo/test cards here.
    // Every card displayed on Home comes from Firestore.
    final List<Map<String, dynamic>> items = postsState.posts
        .map(
          (PostModel post) => PostUi.toItem(
            post,
            isArabic: isArabic,
          ),
        )
        .toList();

    _latestItems = items;

    final filteredItems = _filterItems(items);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------------------------------
                // TOP BAR
                // -----------------------------------------------------------------

                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image(
                            image: AssetImage('assets/avatar8.png'),
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      _topIcon(
                        Icons.notifications_none_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsPage(
                                appLanguage: widget.appLanguage,
                              ),
                            ),
                          );

                          if (!mounted) return;

                          await _loadProfileImage();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rose.withValues(alpha: 0.18),
                            ),
                          ),
                          child: ClipOval(
                            child: _profileImagePath != null &&
                                    _profileImagePath!.isNotEmpty &&
                                    File(_profileImagePath!).existsSync()
                                ? Image.file(
                                    File(_profileImagePath!),
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/avatar10.png',
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 21),

                // -----------------------------------------------------------------
                // GREETING
                // -----------------------------------------------------------------

                Text(
                  isArabic
                      ? 'اعثر على ما يهمك'
                      : 'Find what matters.',
                  textAlign:
                      isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isArabic
                      ? 'ابحث عن الأشياء المفقودة أو ساعد شخصًا في استعادة ما يخصه'
                      : 'Find lost things or help someone get theirs back.',
                  textAlign:
                      isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12.5,
                    height: 1.0,
                    color: mutedBrown,
                  ),
                ),

                const SizedBox(height: 18),

                // -----------------------------------------------------------------
                // SEARCH
                // -----------------------------------------------------------------

                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: darkBrown.withValues(alpha: 0.07),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withValues(alpha: 0.035),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: rose,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      color: darkBrown,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: mutedBrown,
                        size: 21,
                      ),
                      hintText: isArabic
                          ? 'ابحث عن المفقودات أو الموجودات...'
                          : 'Search for lost or found items...',
                      hintStyle: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        color: Color(0xFFAAA09A),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // -----------------------------------------------------------------
                // CATEGORIES TITLE
                // -----------------------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isArabic ? 'التصنيفات' : 'Categories',
                        textAlign:
                            isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCategoriesPage,
                      child: Text(
                        isArabic ? 'عرض الكل' : 'See all',
                        textAlign:
                            isArabic ? TextAlign.left : TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: rose,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // -----------------------------------------------------------------
                // HOME CATEGORIES
                // -----------------------------------------------------------------

                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(width: 10);
                    },
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return _categoryCard(
                        name: _categoryName(
                          category['name'] as String,
                        ),
                        icon: category['icon'] as IconData,
                        color: category['color'] as Color,
                        lightColor:
                            category['lightColor'] as Color,
                        isSelected:
                            selectedCategory ==
                                category['name'],
                        onTap: () {
                          setState(() {
                            selectedCategory =
                                category['name'] as String;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // -----------------------------------------------------------------
                // ITEMS TITLE
                // -----------------------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCategory == 'All'
                            ? (isArabic
                                ? 'أحدث الأغراض'
                                : 'Latest Items')
                            : _categoryName(selectedCategory),
                        textAlign:
                            isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // -----------------------------------------------------------------
                // ITEMS
                // -----------------------------------------------------------------

                postsState.isLoading && items.isEmpty
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 35),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: rose,
                            strokeWidth: 2.2,
                          ),
                        ),
                      )
                    : filteredItems.isEmpty
                        ? _emptyItems(
                            hasError:
                                postsState.error != null &&
                                    items.isEmpty,
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: filteredItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 0.01,
                              mainAxisSpacing: 15.8,

                              // DO NOT CHANGE THIS CARD SIZE.
                              mainAxisExtent: 270,
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];

                              return _itemCard(
                                item: item,
                                name:
                                    item['name']?.toString() ?? '',
                                status:
                                    item['status']?.toString() ??
                                        'Lost',
                                time:
                                    item['time']?.toString() ?? '',
                                category:
                                    item['category']?.toString() ??
                                        'Others',
                                icon: item['icon'] as IconData,
                                color: item['color'] as Color,
                                background:
                                    item['background'] as Color,
                                imageUrl:
                                    item['imageUrl']?.toString(),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),

      // -------------------------------------------------------------------------
      // BOTTOM NAVIGATION
      // -------------------------------------------------------------------------

      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // ===========================================================================
  // CREATE POST
  // ===========================================================================

  Future<void> _openCreatePost() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(
          appLanguage: widget.appLanguage,
        ),
      ),
    );
  }

  // ===========================================================================
  // OPEN MY POSTS
  // ===========================================================================

  Future<void> _openMyPosts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyPostsPage(
          appLanguage: widget.appLanguage,
        ),
      ),
    );
  }

  // ===========================================================================
  // OPEN CATEGORIES
  // ===========================================================================

  Future<void> _openCategoriesPage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          categories: categories,
          selectedCategory: selectedCategory,
          appLanguage: widget.appLanguage,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedCategory = result;
    });
  }

  // ===========================================================================
  // OPEN SAVED
  // ===========================================================================

  Future<void> _openSavedPage() async {
    final savedItems =
        _latestItems.where((item) => _isSaved(item)).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedPage(
          savedItems: savedItems,
          onRemoveItem: (item) {
            final id = item['id']?.toString();

            if (id == null) return;

            if (mounted) {
              setState(() {
                _savedIds.remove(id);
              });
            } else {
              _savedIds.remove(id);
            }

            _persistSavedIds();
          },
          onToggleSaved: _toggleSaved,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ===========================================================================
  // TOGGLE SAVED ITEM
  // ===========================================================================

  void _toggleSaved(Map<String, dynamic> item) {
    final id = item['id']?.toString();

    if (id == null || id.isEmpty) return;

    void toggle() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    }

    if (mounted) {
      setState(toggle);
    } else {
      toggle();
    }

    _persistSavedIds();
  }

  // ===========================================================================
  // TOP ICON
  // ===========================================================================

  Widget _topIcon(
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: darkBrown.withValues(alpha: 0.07),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: darkBrown,
        ),
      ),
    );
  }

  // ===========================================================================
  // HOME CATEGORY CARD
  // ===========================================================================

  Widget _categoryCard({
    required String name,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78,
        decoration: BoxDecoration(
          color: isSelected ? lightColor : cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.38)
                : darkBrown.withValues(alpha: 0.055),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 9.5,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: isSelected ? color : darkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ITEM CARD
  // ===========================================================================

  Widget _itemCard({
    required Map<String, dynamic> item,
    required String name,
    required String status,
    required String time,
    required String category,
    required IconData icon,
    required Color color,
    required Color background,
    String? imageUrl,
  }) {
    final bool isFound = status == 'Found';
    final bool isSaved = _isSaved(item);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsPage(
              item: item,
              isSaved: _isSaved(item),
              onToggleSaved: () {
                _toggleSaved(item);
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: darkBrown.withValues(alpha: 0.055),
          ),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(7),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl != null &&
                              imageUrl.trim().isNotEmpty
                          ? _buildItemImage(
                              imageUrl,
                              icon,
                              color,
                            )
                          : _imageFallback(
                              icon,
                              color,
                            ),
                    ),

                    // STATUS
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
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
                            color:
                                Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Text(
                          _statusName(status),
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isFound
                                ? const Color(0xFF71876D)
                                : rose,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // INFORMATION
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // SAVE BUTTON
                      GestureDetector(
                        behavior:
                            HitTestBehavior.opaque,
                        onTap: () {
                          _toggleSaved(item);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(3),
                          child: AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 180,
                            ),
                            transitionBuilder:
                                (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              isSaved
                                  ? Icons
                                      .favorite_rounded
                                  : Icons
                                      .favorite_border_rounded,
                              key: ValueKey(isSaved),
                              size: 16,
                              color: isSaved
                                  ? rose
                                  : mutedBrown.withValues(
                                      alpha: 0.75,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _categoryName(category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isArabic
                        ? TextAlign.right
                        : TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 9.5,
                      color: mutedBrown,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 11,
                        color:
                            mutedBrown.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        time,
                        textAlign: isArabic
                            ? TextAlign.right
                            : TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 9,
                          color: mutedBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ITEM IMAGE
  // ===========================================================================

  Widget _buildItemImage(
    String imageUrl,
    IconData icon,
    Color color,
  ) {
    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(icon, color);
        },
      );
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(icon, color);
        },
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(icon, color);
        },
      );
    }

    return _imageFallback(icon, color);
  }

  // ===========================================================================
  // IMAGE FALLBACK
  // ===========================================================================

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

  // ===========================================================================
  // EMPTY ITEMS
  // ===========================================================================

  Widget _emptyItems({bool hasError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 35,
            color: mutedBrown.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            hasError
                ? (isArabic
                    ? 'تعذر تحميل المنشورات. تحقق من الاتصال.'
                    : 'Could not load posts. Check your connection.')
                : (isArabic
                    ? 'لم يتم العثور على عناصر.'
                    : 'No items found.'),
            textAlign:
                isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12,
              color: mutedBrown,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION
  // ===========================================================================

  Widget _bottomNavigationBar() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(
              color: darkBrown.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home_rounded,
                  label: isArabic
                      ? 'الرئيسية'
                      : 'Home',
                  index: 0,
                ),

                _navItem(
                  icon: Icons.add_box_outlined,
                  label: isArabic
                      ? 'منشوراتي'
                      : 'My Posts',
                  index: 1,
                  onTap: _openMyPosts,
                ),

                GestureDetector(
                  onTap: _openCreatePost,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration:
                        const BoxDecoration(
                      color: rose,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ),

                _navItem(
                  icon: Icons.favorite_border_rounded,
                  label: isArabic
                      ? 'المحفوظات'
                      : 'Saved',
                  index: 3,
                  onTap: _openSavedPage,
                ),

                _navItem(
                  icon: Icons.person_outline_rounded,
                  label: isArabic
                      ? 'حسابي'
                      : 'Profile',
                  index: 4,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SettingsPage(
                          appLanguage:
                              widget.appLanguage,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // NAV ITEM
  // ===========================================================================

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onTap,
  }) {
    final bool selected =
        _currentIndex == index;

    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() {
              _currentIndex = index;
            });
          },
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color:
                  selected ? rose : mutedBrown,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: selected
                    ? rose
                    : mutedBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
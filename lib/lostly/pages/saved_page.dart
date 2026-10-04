import 'package:flutter/material.dart';

import 'item_details_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({
    super.key,
    this.savedItems = const [],
    required this.onRemoveItem,
    this.onToggleSaved,
  });

  final List<Map<String, dynamic>> savedItems;

  final void Function(Map<String, dynamic> item) onRemoveItem;

  /// Called when the heart is toggled on the item details page.
  final void Function(Map<String, dynamic> item)? onToggleSaved;

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const Color rose = Color(0xFFB66568);
  static const Color roseLight = Color(0xFFF3DDE0);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  late List<Map<String, dynamic>> savedItems;

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();

    savedItems = List<Map<String, dynamic>>.from(
      widget.savedItems,
    );
  }

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
      case 'Other':
        return 'أخرى';
      default:
        return category;
    }
  }

  String _statusName(String status) {
    if (!isArabic) {
      return status;
    }

    switch (status.toLowerCase()) {
      case 'lost':
        return 'مفقود';
      case 'found':
        return 'تم العثور عليه';
      default:
        return status;
    }
  }

  // ===========================================================================
  // REMOVE SAVED ITEM
  // ===========================================================================

  void _removeSavedItem(int index) {
    final item = savedItems[index];

    setState(() {
      savedItems.removeAt(index);
    });

    // Tell HomePage that this item was removed.
    widget.onRemoveItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          isArabic
              ? 'تمت إزالة الغرض من المحفوظات.'
              : 'Item removed from saved.',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =========================================================================
      // APP BAR
      // =========================================================================

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          // arrow_back_rounded already flips automatically in RTL.
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
          isArabic ? 'المحفوظات' : 'Saved',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),

        centerTitle: true,
      ),

      // =========================================================================
      // BODY
      // =========================================================================

      body: savedItems.isEmpty
          ? _emptyState()
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                30,
              ),

              physics: const BouncingScrollPhysics(),

              itemCount: savedItems.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 0.30,
                mainAxisSpacing: 11.8,

                // DO NOT CHANGE THE CARD SIZE.
                mainAxisExtent: 250,
              ),

              itemBuilder: (context, index) {
                return _savedCard(
                  savedItems[index],
                  index,
                );
              },
            ),
    );
  }

  // ===========================================================================
  // SAVED CARD
  // ===========================================================================

  Widget _savedCard(
    Map<String, dynamic> item,
    int index,
  ) {
    final String rawName = item['name']?.toString() ?? '';

    final String name = rawName.trim().isNotEmpty
        ? rawName
        : (isArabic ? 'غرض غير معروف' : 'Unknown item');

    final String category =
        item['category']?.toString() ?? 'Others';

    final String status =
        item['status']?.toString() ?? 'Lost';

    final String location =
        item['location']?.toString() ?? '';

    final String? imageUrl =
        item['imageUrl']?.toString();

    final IconData icon =
        item['icon'] is IconData
            ? item['icon'] as IconData
            : Icons.inventory_2_outlined;

    final Color itemColor =
        item['color'] is Color
            ? item['color'] as Color
            : rose;

    final Color itemBackground =
        item['background'] is Color
            ? item['background'] as Color
            : roseLight;

    final bool isFound =
        status.toLowerCase() == 'found';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsPage(
              item: item,
              isSaved: true,
              onToggleSaved: () {
                final id = item['id'];
                final stillSaved = savedItems.any((s) => s['id'] == id);

                widget.onToggleSaved?.call(item);

                if (!mounted) return;

                setState(() {
                  if (stillSaved) {
                    savedItems.removeWhere((s) => s['id'] == id);
                  } else {
                    savedItems.add(item);
                  }
                });
              },
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: darkBrown.withValues(
              alpha: 0.055,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(
                alpha: 0.045,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ===================================================================
            // IMAGE
            // ===================================================================

            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(7),
                clipBehavior: Clip.antiAlias,

                decoration: BoxDecoration(
                  color: itemBackground,
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildImage(
                        imageUrl,
                        icon,
                        itemColor,
                      ),
                    ),

                    // =============================================================
                    // STATUS
                    // =============================================================

                    Positioned(
                      top: 9,
                      left: 9,

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: isFound
                              ? const Color(
                                  0xFFE4EBDD,
                                ).withValues(
                                  alpha: 0.95,
                                )
                              : roseLight.withValues(
                                  alpha: 0.95,
                                ),

                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Text(
                          _statusName(status),

                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w700,
                            color: isFound
                                ? const Color(
                                    0xFF71876D,
                                  )
                                : rose,
                          ),
                        ),
                      ),
                    ),

                    // =============================================================
                    // REMOVE FROM SAVED
                    // =============================================================

                    Positioned(
                      top: 9,
                      right: 9,

                      child: GestureDetector(
                        onTap: () {
                          _removeSavedItem(index);
                        },

                        child: Container(
                          width: 31,
                          height: 31,

                          decoration:
                              BoxDecoration(
                            color: cardColor.withValues(
                              alpha: 0.95,
                            ),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 17,
                            color: rose,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===================================================================
            // INFORMATION
            // ===================================================================

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
                  // =================================================================
                  // NAME
                  // =================================================================

                  Text(
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

                  const SizedBox(height: 5),

                  // =================================================================
                  // CATEGORY
                  // =================================================================

                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,

                        decoration:
                            BoxDecoration(
                          color: itemColor,
                          shape:
                              BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          _categoryName(category),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9.5,
                            fontWeight:
                                FontWeight.w500,
                            color: itemColor,
                          ),
                        ),
                      ),

                      if (location.isNotEmpty) ...[
                        const SizedBox(width: 5),

                        const Icon(
                          Icons.location_on_outlined,
                          size: 10.5,
                          color: mutedBrown,
                        ),

                        const SizedBox(width: 3),

                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              fontFamily:
                                  'serif',
                              fontSize: 9,
                              color:
                                  mutedBrown,
                            ),
                          ),
                        ),
                      ],
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
  // IMAGE
  // ===========================================================================

  Widget _buildImage(
    String? imageUrl,
    IconData icon,
    Color color,
  ) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return _imageFallback(
        icon,
        color,
      );
    }

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

    return _imageFallback(
      icon,
      color,
    );
  }

  // ===========================================================================
  // FALLBACK
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
  // EMPTY STATE
  // ===========================================================================

  Widget _emptyState() {
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
              width: 78,
              height: 78,

              decoration:
                  const BoxDecoration(
                color: roseLight,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.favorite_border_rounded,
                size: 36,
                color: rose,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              isArabic
                  ? 'لا توجد محفوظات بعد'
                  : 'No saved items yet',
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

            const SizedBox(height: 8),

            Text(
              isArabic
                  ? 'احفظ الأغراض التي تهمك لتتمكن من الوصول إليها بسهولة لاحقًا.'
                  : 'Save items that matter to you so you can easily find them later.',
              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 12.5,
                height: 1.5,
                color: mutedBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
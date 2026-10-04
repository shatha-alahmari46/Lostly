import 'package:flutter/material.dart';

import 'chat_page.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({
    super.key,
    required this.item,
    this.isSaved = false,
    this.onToggleSaved,
  });

  final Map<String, dynamic> item;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late bool _isSaved;

  static const Color rose = Color(0xFFB66568);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  void didUpdateWidget(covariant ItemDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
  }

  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });

    widget.onToggleSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    // Empty strings from Firestore are treated as "not provided".
    String field(String key) {
      final value = widget.item[key]?.toString().trim() ?? '';
      return value;
    }

    String orDefault(String value, String fallback) {
      return value.isNotEmpty ? value : fallback;
    }

    final String name = orDefault(
      field('name'),
      isArabic ? 'غرض غير معروف' : 'Unknown item',
    );

    final String status = orDefault(field('status'), 'Lost');

    final String category = orDefault(field('category'), 'Others');

    final String location = orDefault(
      field('location'),
      isArabic ? 'لم يتم تحديد الموقع' : 'Location not provided',
    );

    final String date = orDefault(
      field('date'),
      isArabic ? 'لم يتم تحديد التاريخ' : 'Date not provided',
    );

    // Clock time ("2:30 PM") first, then the card's relative time.
    final String time = orDefault(
      orDefault(field('itemTime'), field('time')),
      isArabic ? 'لم يتم تحديد الوقت' : 'Time not provided',
    );

    final String color = orDefault(
      field('itemColor'),
      isArabic ? 'غير محدد' : 'Not specified',
    );

    final String brand = orDefault(
      field('brand'),
      isArabic ? 'غير محدد' : 'Not specified',
    );

    final String description = orDefault(
      field('description'),
      isArabic ? 'لا يوجد وصف.' : 'No description provided.',
    );

    final IconData icon = widget.item['icon'] is IconData
        ? widget.item['icon'] as IconData
        : Icons.inventory_2_outlined;

    final Color itemColor = widget.item['color'] is Color
        ? widget.item['color'] as Color
        : rose;

    final Color itemBackground = widget.item['background'] is Color
        ? widget.item['background'] as Color
        : const Color(0xFFF3DDE0);

    final String? imageUrl =
        widget.item['imageUrl']?.toString();

    final bool isFound =
        status.toLowerCase() == 'found';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // TOP BAR
              // ==============================================================

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: darkBrown.withValues(
                            alpha: 0.07,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 21,
                        color: darkBrown,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        isArabic ? 'تفاصيل الغرض' : 'Item Details',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // HEART
                  // ==========================================================

                  GestureDetector(
                    onTap: _toggleSaved,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: darkBrown.withValues(
                            alpha: 0.07,
                          ),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(
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
                          _isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(_isSaved),
                          size: 20,
                          color: _isSaved
                              ? rose
                              : darkBrown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // IMAGE
              // ==============================================================

              Container(
                width: double.infinity,
                height: 285,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: itemBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: darkBrown.withValues(
                      alpha: 0.055,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _itemImage(
                        imageUrl: imageUrl,
                        icon: icon,
                        color: itemColor,
                      ),
                    ),

                    Positioned(
                      top: 13,
                      left: 13,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          _statusName(
                            status,
                            isArabic,
                          ),
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10,
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

              const SizedBox(height: 20),

              // ==============================================================
              // TITLE
              // ==============================================================

              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _categoryName(
                  category,
                  isArabic,
                ),
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  color: itemColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 22),

              // ==============================================================
              // INFORMATION
              // ==============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: darkBrown.withValues(
                      alpha: 0.055,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      icon: Icons.location_on_outlined,
                      title:
                          isArabic ? 'الموقع' : 'Location',
                      value: location,
                    ),

                    const SizedBox(height: 15),

                    _infoRow(
                      icon: Icons.calendar_today_outlined,
                      title:
                          isArabic ? 'التاريخ' : 'Date',
                      value: date,
                    ),

                    const SizedBox(height: 15),

                    _infoRow(
                      icon: Icons.schedule_rounded,
                      title:
                          isArabic ? 'الوقت' : 'Time',
                      value: time,
                    ),

                    const SizedBox(height: 15),

                    _infoRow(
                      icon: Icons.palette_outlined,
                      title:
                          isArabic ? 'اللون' : 'Color',
                      value: color,
                    ),

                    const SizedBox(height: 15),

                    _infoRow(
                      icon: Icons.sell_outlined,
                      title: isArabic
                          ? 'العلامة التجارية'
                          : 'Brand',
                      value: brand,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // DESCRIPTION
              // ==============================================================

              Text(
                isArabic ? 'الوصف' : 'Description',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 9),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: darkBrown.withValues(
                      alpha: 0.055,
                    ),
                  ),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12.5,
                    height: 1.6,
                    color: mutedBrown,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==============================================================
              // ACTION
              // ==============================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    _showActionSheet(
                      context,
                      isFound,
                      isArabic,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),
                  child: Text(
                    isFound
                        ? (isArabic
                            ? 'هذا غرضي'
                            : 'This is my item')
                        : (isArabic
                            ? 'وجدت هذا الغرض'
                            : 'I found this item'),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTION BOTTOM SHEET
  // ===========================================================================

  void _showActionSheet(
    BuildContext context,
    bool isFound,
    bool isArabic,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            18,
            24,
            28,
          ),
          decoration: const BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedBrown.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3DDE0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFound
                        ? Icons
                            .check_circle_outline_rounded
                        : Icons.search_rounded,
                    color: rose,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  isFound
                      ? (isArabic
                          ? 'هل هذا غرضك؟'
                          : 'Is this your item?')
                      : (isArabic
                          ? 'هل وجدت هذا الغرض؟'
                          : 'Did you find this item?'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isFound
                      ? (isArabic
                          ? 'يمكنك المتابعة للتواصل مع الشخص الذي وجده.'
                          : 'You can continue to contact the person who found it.')
                      : (isArabic
                          ? 'يمكنك المتابعة للتواصل مع الشخص الذي أبلغ عنه.'
                          : 'You can continue to contact the person who reported it.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12.5,
                    height: 1.5,
                    color: mutedBrown,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the sheet, then open the chat from the
                      // page's navigator (the sheet context is gone).
                      final navigator = Navigator.of(context);

                      navigator.pop();

                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            item: widget.item,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rose,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isFound
                          ? (isArabic
                              ? 'متابعة'
                              : 'Continue')
                          : (isArabic
                              ? 'نعم، وجدته'
                              : 'Yes, I found it'),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      isArabic ? 'إلغاء' : 'Cancel',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: mutedBrown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TRANSLATIONS
  // ===========================================================================

  String _statusName(
    String value,
    bool isArabic,
  ) {
    if (!isArabic) return value;

    switch (value.toLowerCase()) {
      case 'found':
        return 'تم العثور عليه';

      case 'lost':
        return 'مفقود';

      default:
        return value;
    }
  }

  String _categoryName(
    String value,
    bool isArabic,
  ) {
    if (!isArabic) return value;

    switch (value.toLowerCase()) {
      case 'all':
        return 'الكل';

      case 'electronics':
        return 'إلكترونيات';

      case 'accessories':
        return 'إكسسوارات';

      case 'documents':
        return 'مستندات';

      case 'bags':
        return 'حقائب';

      case 'keys':
        return 'مفاتيح';

      case 'clothing':
        return 'ملابس';

      case 'books':
        return 'كتب';

      case 'jewelry':
        return 'مجوهرات';

      case 'others':
      case 'other':
        return 'أخرى';

      default:
        return value;
    }
  }

  // ===========================================================================
  // ITEM IMAGE
  // ===========================================================================

  Widget _itemImage({
    required String? imageUrl,
    required IconData icon,
    required Color color,
  }) {
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
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageFallback(
            icon,
            color,
          );
        },
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _imageFallback(
          icon,
          color,
        );
      },
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF3DDE0),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: rose,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 9.5,
                  color: mutedBrown,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: darkBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        size: 70,
        color: color,
      ),
    );
  }
}
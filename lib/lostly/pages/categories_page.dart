import 'package:flutter/material.dart';
import '/app_language.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.appLanguage,
  });

  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final AppLanguage appLanguage;

  static const Color rose = Color(0xFFB66568);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  String get pageTitle {
    return appLanguage.isArabic ? 'التصنيفات' : 'Categories';
  }

  String get pageSubtitle {
    return appLanguage.isArabic
        ? 'ابحث عمّا تبحث عنه.'
        : 'Find what you are looking for.';
  }

  String translatedCategoryName(String name) {
    if (!appLanguage.isArabic) {
      return name;
    }

    switch (name) {
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
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pageSubtitle,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 13,
                color: mutedBrown,
              ),
            ),
            const SizedBox(height: 22),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];

                final String name = category['name'];

                final IconData icon = category['icon'];

                final Color color = category['color'];

                final Color lightColor = category['lightColor'];

                final bool isSelected = selectedCategory == name;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, name);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? lightColor : cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? color.withValues(alpha: 0.40)
                            : darkBrown.withValues(alpha: 0.055),
                        width: isSelected ? 1.3 : 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: lightColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 24,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          translatedCategoryName(name),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? color : darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '/app_language.dart';
import '/cubits/posts_cubit.dart';
import '/models/post_model.dart';
import '/services/firestore_service.dart';
import '/services/cloudinary_service.dart';
import '/utils/post_ui.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
    this.initialPost,
    required this.appLanguage,
  });

  final PostModel? initialPost;
  final AppLanguage appLanguage;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  static const Color rose = Color(0xFFB66568);
  static const Color roseLight = Color(0xFFF3DDE0);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _colorController =
      TextEditingController();

  final TextEditingController _brandController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _type = 'Lost';
  String _category = 'Electronics';

  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;

  String? _existingImageUrl;

  bool _isSaving = false;

  final List<String> _categories = [
    'Electronics',
    'Accessories',
    'Documents',
    'Bags',
    'Keys',
    'Clothing',
    'Books',
    'Jewelry',
    'Others',
  ];

  bool get _isEditing => widget.initialPost != null;

  bool get _isArabic => widget.appLanguage.isArabic;

  String _categoryName(String category) {
    if (!_isArabic) {
      return category;
    }

    switch (category) {
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

  String get _pageTitle {
    if (_isEditing) {
      return _isArabic ? 'تعديل المنشور' : 'Edit Post';
    }

    return _isArabic ? 'إنشاء منشور' : 'Create Post';
  }

  String get _pageSubtitle {
    if (_isEditing) {
      return _isArabic
          ? 'حدّث تفاصيل منشورك.'
          : 'Update the details of your post.';
    }

    return _isArabic
        ? 'ساعد غرضًا مفقودًا في العودة إلى صاحبه.'
        : 'Help an item find its way home.';
  }

  String get _photoTitle {
    return _isArabic ? 'الصورة' : 'Photo';
  }

  String get _itemNameTitle {
    return _isArabic ? 'اسم الغرض' : 'Item Name';
  }

  String get _categoryTitle {
    return _isArabic ? 'التصنيف' : 'Category';
  }

  String get _locationTitle {
    return _isArabic ? 'الموقع' : 'Location';
  }

  String get _colorTitle {
    return _isArabic ? 'اللون' : 'Color';
  }

  String get _brandTitle {
    return _isArabic ? 'العلامة التجارية' : 'Brand';
  }

  String get _descriptionTitle {
    return _isArabic ? 'الوصف' : 'Description';
  }

  String get _lostText {
    return _isArabic ? 'مفقود' : 'Lost';
  }

  String get _foundText {
    return _isArabic ? 'تم العثور عليه' : 'Found';
  }

  @override
  void initState() {
    super.initState();

    final item = widget.initialPost;

    if (item != null) {
      _nameController.text = item.name;

      _locationController.text = item.location;

      _colorController.text = item.itemColor;

      _brandController.text = item.brand;

      _descriptionController.text = item.description;

      if (item.status == 'Lost' || item.status == 'Found') {
        _type = item.status;
      }

      if (_categories.contains(item.category)) {
        _category = item.category;
      }

      if (item.imageUrl.trim().isNotEmpty) {
        _existingImageUrl = item.imageUrl;
      }
    }
  }

  Map<String, dynamic> _categoryData(String category) {
    switch (category) {
      case 'Electronics':
        return {
          'icon': Icons.devices_other_rounded,
          'color': const Color(0xFF6E8FA3),
          'lightColor': const Color(0xFFE2EDF2),
        };

      case 'Accessories':
        return {
          'icon': Icons.watch_outlined,
          'color': const Color(0xFF9A789A),
          'lightColor': const Color(0xFFECE2EC),
        };

      case 'Documents':
        return {
          'icon': Icons.description_outlined,
          'color': const Color(0xFFB58A55),
          'lightColor': const Color(0xFFF2E8D8),
        };

      case 'Bags':
        return {
          'icon': Icons.backpack_outlined,
          'color': const Color(0xFF7E9276),
          'lightColor': const Color(0xFFE4EBDD),
        };

      case 'Keys':
        return {
          'icon': Icons.key_rounded,
          'color': const Color(0xFFB47B61),
          'lightColor': const Color(0xFFF0DFD6),
        };

      case 'Clothing':
        return {
          'icon': Icons.checkroom_outlined,
          'color': const Color(0xFF7885A5),
          'lightColor': const Color(0xFFE4E8F2),
        };

      case 'Books':
        return {
          'icon': Icons.menu_book_rounded,
          'color': const Color(0xFF9B765F),
          'lightColor': const Color(0xFFEEE2D9),
        };

      case 'Jewelry':
        return {
          'icon': Icons.diamond_outlined,
          'color': const Color(0xFFAA7184),
          'lightColor': const Color(0xFFF0DEE4),
        };

      case 'Others':
        return {
          'icon': Icons.category_outlined,
          'color': const Color(0xFF7E827D),
          'lightColor': const Color(0xFFE7E8E5),
        };

      default:
        return {
          'icon': Icons.category_outlined,
          'color': mutedBrown,
          'lightColor': const Color(0xFFEFEAE6),
        };
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _colorController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = image;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Widget _buildCurrentImage() {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_existingImageUrl != null &&
        _existingImageUrl!.trim().isNotEmpty) {
      final imageUrl = _existingImageUrl!;

      if (imageUrl.startsWith('http://') ||
          imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) {
            return _imagePlaceholder();
          },
        );
      }

      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder();
        },
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: roseLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_outlined,
            color: rose,
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isArabic ? 'إضافة صورة' : 'Add a photo',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _isArabic
              ? 'الصورة الواضحة تساعد الآخرين على التعرّف على الغرض.'
              : 'A clear photo helps others identify the item.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 9.5,
            color: mutedBrown,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // SUBMIT POST
  // ================================================================

  Future<void> _submitPost() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final currentUser = FirestoreService.instance.currentUser;

    if (currentUser == null) {
      _showMessage(
        _isArabic
            ? 'يجب تسجيل الدخول أولًا.'
            : 'Please log in first.',
      );
      return;
    }

    // Read the cubit before any await.
    final postsCubit = context.read<PostsCubit>();

    final existing = widget.initialPost;

    setState(() {
      _isSaving = true;
    });

    try {
      // ------------------------------------------------------------
      // IMAGE
      // ------------------------------------------------------------
      //
      // A newly selected image is uploaded to Cloudinary.
      // The returned secure URL is then saved in Firestore.
      //
      // If no new image was selected, keep the existing image URL.
      // If the existing image was removed, the saved URL becomes empty.
      // ------------------------------------------------------------

      String imageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.instance.uploadImage(
          File(_selectedImage!.path),
        );

        debugPrint(
          '[CreatePost] Image uploaded successfully.',
        );
      }

      // ------------------------------------------------------------
      // BUILD POST MODEL
      // ------------------------------------------------------------

      final now = DateTime.now();

      final post = PostModel(
        id: existing?.id ?? '',
        name: _nameController.text.trim(),
        status: _type,
        time: existing?.time ??
            PostUi.formatClock(
              now,
              isArabic: false,
            ),
        category: _category,
        location: _locationController.text.trim(),
        date: existing?.date ??
            PostUi.formatDate(
              now,
              isArabic: false,
            ),
        itemColor: _colorController.text.trim(),
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        userId: existing?.userId ?? currentUser.uid,
        createdAt: existing?.createdAt,
      );

      // ------------------------------------------------------------
      // SAVE TO FIRESTORE
      // ------------------------------------------------------------

      if (existing == null || existing.id.isEmpty) {
        final postId = await postsCubit.addPost(post);

        debugPrint(
          '[CreatePost] Post created: $postId',
        );
      } else {
        await postsCubit.updatePost(post);

        debugPrint(
          '[CreatePost] Post updated: ${existing.id}',
        );
      }

      if (!mounted) return;

      // Home / My Posts update automatically through
      // the Firestore stream.
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint(
        '[CreatePost] Save failed (${e.runtimeType}): $e',
      );

      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        PostUi.errorMessage(
          e,
          isArabic: _isArabic,
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'serif',
        fontSize: 12,
        color: mutedBrown,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              size: 19,
              color: mutedBrown,
            ),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: darkBrown.withValues(alpha: 0.06),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: darkBrown.withValues(alpha: 0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: rose,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: darkBrown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkBrown,
            size: 25,
          ),
        ),
        title: Text(
          _pageTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            6,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pageSubtitle,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  color: mutedBrown,
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================================
              // LOST / FOUND
              // ==========================================================

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: darkBrown.withValues(alpha: 0.055),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'Lost';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _type == 'Lost'
                                ? roseLight
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                          child: Text(
                            _lostText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _type == 'Lost'
                                  ? rose
                                  : mutedBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'Found';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: _type == 'Found'
                                ? const Color(0xFFE4EBDD)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                          child: Text(
                            _foundText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _type == 'Found'
                                  ? const Color(0xFF7E9276)
                                  : mutedBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================================
              // PHOTO
              // ==========================================================

              _sectionTitle(_photoTitle),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 145,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: darkBrown.withValues(alpha: 0.07),
                    ),
                  ),
                  child: _selectedImage == null &&
                          _existingImageUrl == null
                      ? _imagePlaceholder()
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(17),
                              child: _buildCurrentImage(),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.92,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: darkBrown,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _isArabic
                                      ? 'اضغط للتغيير'
                                      : 'Tap to change',
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================================
              // ITEM NAME
              // ==========================================================

              _sectionTitle(_itemNameTitle),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: _isArabic
                      ? 'مثال: AirPods'
                      : 'e.g. AirPods',
                  icon: Icons.inventory_2_outlined,
                ),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  color: darkBrown,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return _isArabic
                        ? 'يرجى إدخال اسم الغرض.'
                        : 'Please enter the item name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==========================================================
              // CATEGORY
              // ==========================================================

              _sectionTitle(_categoryTitle),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: darkBrown.withValues(alpha: 0.06),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                  ),
                  dropdownColor: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: mutedBrown,
                    size: 21,
                  ),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    color: darkBrown,
                  ),
                  selectedItemBuilder: (context) {
                    return _categories.map((category) {
                      final data =
                          _categoryData(category);

                      return Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  data['lightColor'] as Color,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Icon(
                              data['icon'] as IconData,
                              color:
                                  data['color'] as Color,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _categoryName(category),
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  items: _categories.map(
                    (category) {
                      final data =
                          _categoryData(category);

                      final Color color =
                          data['color'] as Color;

                      final Color lightColor =
                          data['lightColor'] as Color;

                      final IconData icon =
                          data['icon'] as IconData;

                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: lightColor,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Text(
                              _categoryName(category),
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 12,
                                color: darkBrown,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _category = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================================
              // LOCATION
              // ==========================================================

              _sectionTitle(_locationTitle),

              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration(
                  hint: _isArabic
                      ? 'مثال: مكتبة الجامعة'
                      : 'e.g. University Library',
                  icon: Icons.location_on_outlined,
                ),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  color: darkBrown,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return _isArabic
                        ? 'يرجى إدخال الموقع.'
                        : 'Please enter the location.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // ==========================================================
              // COLOR + BRAND
              // ==========================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(_colorTitle),
                        TextFormField(
                          controller: _colorController,
                          decoration: _inputDecoration(
                            hint: _isArabic
                                ? 'مثال: أبيض'
                                : 'e.g. White',
                          ),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(_brandTitle),
                        TextFormField(
                          controller: _brandController,
                          decoration: _inputDecoration(
                            hint: _isArabic
                                ? 'مثال: Apple'
                                : 'e.g. Apple',
                          ),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==========================================================
              // DESCRIPTION
              // ==========================================================

              _sectionTitle(_descriptionTitle),

              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: _inputDecoration(
                  hint: _isArabic
                      ? 'أضف تفاصيل قد تساعد في التعرّف على الغرض...'
                      : 'Add details that may help identify the item...',
                ),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  height: 1.4,
                  color: darkBrown,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return _isArabic
                        ? 'يرجى إضافة وصف.'
                        : 'Please add a description.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              // ==========================================================
              // SAVE / POST BUTTON
              // ==========================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? (_isArabic
                                  ? 'حفظ التغييرات'
                                  : 'Save Changes')
                              : _type == 'Lost'
                                  ? (_isArabic
                                      ? 'نشر غرض مفقود'
                                      : 'Post Lost Item')
                                  : (_isArabic
                                      ? 'نشر غرض تم العثور عليه'
                                      : 'Post Found Item'),
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
}
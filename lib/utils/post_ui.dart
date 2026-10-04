import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';

/// Helpers that adapt [PostModel] (Firestore data) to the
/// `Map<String, dynamic>` item structure the existing UI cards use.
class PostUi {
  PostUi._();

  // ===========================================================================
  // CATEGORY VISUALS (same values as CreatePostPage)
  // ===========================================================================

  static Map<String, dynamic> categoryVisuals(String category) {
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
      default:
        return {
          'icon': Icons.category_outlined,
          'color': const Color(0xFF7E827D),
          'lightColor': const Color(0xFFE7E8E5),
        };
    }
  }

  // ===========================================================================
  // POST -> ITEM MAP
  // ===========================================================================

  static Map<String, dynamic> toItem(
    PostModel post, {
    required bool isArabic,
  }) {
    final visuals = categoryVisuals(post.category);
    final createdAt = post.createdAt;

    return <String, dynamic>{
      'id': post.id,
      'name': post.name,
      'status': post.status,

      // Relative time for cards ("3h ago").
      'time': relativeTime(
        createdAt,
        isArabic: isArabic,
      ),

      'category': post.category,
      'icon': visuals['icon'],
      'color': visuals['color'],
      'background': visuals['lightColor'],

      // Cloudinary secure URL.
      'imageUrl': post.imageUrl.trim().isEmpty ? null : post.imageUrl,

      'location': post.location,

      'date': createdAt != null
          ? formatDate(
              createdAt,
              isArabic: isArabic,
            )
          : post.date,

      // Clock time for the details page ("2:30 PM").
      'itemTime': createdAt != null
          ? formatClock(
              createdAt,
              isArabic: isArabic,
            )
          : post.time,

      'itemColor': post.itemColor,
      'brand': post.brand,
      'description': post.description,
      'userId': post.userId,
    };
  }

  // ===========================================================================
  // DATE / TIME FORMATTING (no extra packages needed)
  // ===========================================================================

  static const List<String> _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static String formatDate(
    DateTime date, {
    required bool isArabic,
  }) {
    final local = date.toLocal();

    if (isArabic) {
      return '${local.day} ${_monthsAr[local.month - 1]} ${local.year}';
    }

    return '${_monthsEn[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String formatClock(
    DateTime date, {
    required bool isArabic,
  }) {
    final local = date.toLocal();

    final hour12 = local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute = local.minute
        .toString()
        .padLeft(2, '0');

    final isPm = local.hour >= 12;

    if (isArabic) {
      return '$hour12:$minute ${isPm ? 'م' : 'ص'}';
    }

    return '$hour12:$minute ${isPm ? 'PM' : 'AM'}';
  }

  static String relativeTime(
    DateTime? date, {
    required bool isArabic,
  }) {
    // A null createdAt means the server timestamp is still pending,
    // i.e. the post was created a moment ago.
    if (date == null) {
      return isArabic ? 'الآن' : 'Just now';
    }

    final diff = DateTime.now().difference(
      date.toLocal(),
    );

    if (diff.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Just now';
    }

    if (diff.inHours < 1) {
      return isArabic
          ? 'منذ ${diff.inMinutes} دقيقة'
          : '${diff.inMinutes}m ago';
    }

    if (diff.inDays < 1) {
      return isArabic
          ? 'منذ ${diff.inHours} ساعة'
          : '${diff.inHours}h ago';
    }

    if (diff.inDays < 7) {
      return isArabic
          ? 'منذ ${diff.inDays} يوم'
          : '${diff.inDays}d ago';
    }

    return formatDate(
      date,
      isArabic: isArabic,
    );
  }

  // ===========================================================================
  // USER-FACING ERROR MESSAGES
  // ===========================================================================

  static String errorMessage(
    Object error, {
    required bool isArabic,
  }) {
    if (error is FirebaseAuthException) {
      return isArabic
          ? 'يجب تسجيل الدخول أولًا.'
          : 'Please log in first.';
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return isArabic
              ? 'ليست لديك صلاحية لتنفيذ هذا الإجراء.'
              : 'You do not have permission to do this.';

        case 'unavailable':
        case 'network-request-failed':
          return isArabic
              ? 'تحقق من اتصال الإنترنت وحاول مرة أخرى.'
              : 'Check your internet connection and try again.';

        case 'not-found':
          return isArabic
              ? 'لم يعد هذا المنشور موجودًا.'
              : 'This post no longer exists.';
      }
    }

    final text = error.toString();

    if (text.contains('User is not signed in')) {
      return isArabic
          ? 'يجب تسجيل الدخول أولًا.'
          : 'Please log in first.';
    }

    if (text.contains('only update your own') ||
        text.contains('only delete your own')) {
      return isArabic
          ? 'يمكنك تعديل أو حذف منشوراتك فقط.'
          : 'You can only edit or delete your own posts.';
    }

    if (text.contains('Post not found')) {
      return isArabic
          ? 'لم يعد هذا المنشور موجودًا.'
          : 'This post no longer exists.';
    }

    if (text.contains('Image upload failed') ||
        text.contains('Could not upload image') ||
        text.contains('Cloudinary')) {
      return isArabic
          ? 'تعذر رفع الصورة. تحقق من اتصال الإنترنت وحاول مرة أخرى.'
          : 'The image could not be uploaded. Check your internet connection and try again.';
    }

    return isArabic
        ? 'حدث خطأ غير متوقع. حاول مرة أخرى.'
        : 'Something went wrong. Please try again.';
  }
}
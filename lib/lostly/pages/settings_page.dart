import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/app_language.dart';
import 'login_pages.dart';
import 'notifications_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.appLanguage,
    this.onLanguageChanged,
    this.currentLanguage = 'English',
  });

  final AppLanguage appLanguage;
  final ValueChanged<String>? onLanguageChanged;
  final String currentLanguage;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
  // STATE
  // ===========================================================================

  late String language;

  bool notificationsEnabled = true;

  String? _profileImagePath;

  final ImagePicker _imagePicker = ImagePicker();

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    language = widget.appLanguage.isArabic ? 'العربية' : 'English';

    _loadProfileImage();
  }

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  bool get isArabic => language == 'العربية';

  String get settingsTitle => isArabic ? 'الإعدادات' : 'Settings';

  String get preferencesTitle => isArabic ? 'التفضيلات' : 'Preferences';

  String get notificationsTitle => isArabic ? 'الإشعارات' : 'Notifications';

  String get notificationsOnSubtitle =>
      isArabic ? 'الإشعارات مفعّلة' : 'Notifications are on';

  String get notificationsOffSubtitle =>
      isArabic ? 'الإشعارات متوقفة' : 'Notifications are off';

  String get languageTitle => isArabic ? 'اللغة' : 'Language';

  String get aboutTitle => isArabic ? 'عن Lostly' : 'About Lostly';

  String get aboutSubtitle =>
      isArabic ? 'تعرّف أكثر على التطبيق' : 'Learn more about the app';

  String get logoutTitle => isArabic ? 'تسجيل الخروج' : 'Log Out';

  String get profileTitle => isArabic ? 'الحساب' : 'Account';

  String get changePhotoText => isArabic ? 'تغيير الصورة' : 'Change photo';

  // ===========================================================================
  // CURRENT USER
  // ===========================================================================

  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get userName {
    final name = currentUser?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return isArabic ? 'المستخدم' : 'User';
  }

  String get userEmail {
    final email = currentUser?.email?.trim();

    if (email != null && email.isNotEmpty) {
      return email;
    }

    return '';
  }

  // ===========================================================================
  // LOAD PROFILE IMAGE
  // ===========================================================================

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPath = prefs.getString(_profileImageKey);

    if (!mounted) return;

    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);

      if (await file.exists()) {
        setState(() {
          _profileImagePath = savedPath;
        });
      }
    }
  }

  String get _profileImageKey {
    final uid = currentUser?.uid ?? 'guest';

    return 'profile_image_$uid';
  }

  // ===========================================================================
  // PICK PROFILE IMAGE
  // ===========================================================================

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_profileImageKey, pickedImage.path);

      if (!mounted) return;

      setState(() {
        _profileImagePath = pickedImage.path;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: rose,
          content: Text(
            isArabic ? 'تعذر اختيار الصورة.' : 'Unable to select the image.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // PROFILE IMAGE
  // ===========================================================================

  Widget _profileImage() {
    final path = _profileImagePath;

    if (path != null && path.isNotEmpty) {
      final file = File(path);

      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    return Image.asset('assets/avatar10.png', fit: BoxFit.cover);
  }

  // ===========================================================================
  // PROFILE SECTION
  // ===========================================================================

  Widget _profileSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: roseLight,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(child: _profileImage()),
              ),
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: rose,
                  shape: BoxShape.circle,
                  border: Border.all(color: background, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        if (userEmail.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11.5,
              color: mutedBrown,
            ),
          ),
        ],
        const SizedBox(height: 7),
        Text(
          changePhotoText,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: rose,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          settingsTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _profileSection(),

            const SizedBox(height: 28),

            Text(
              preferencesTitle,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: mutedBrown,
              ),
            ),

            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.notifications_none_rounded,
              title: notificationsTitle,
              subtitle: notificationsEnabled
                  ? notificationsOnSubtitle
                  : notificationsOffSubtitle,
              trailing: Switch(
                value: notificationsEnabled,
                activeTrackColor: roseLight,
                activeThumbColor: rose,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),

            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.language_rounded,
              title: languageTitle,
              subtitle: language,
              onTap: _chooseLanguage,
            ),

            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.info_outline_rounded,
              title: aboutTitle,
              subtitle: aboutSubtitle,
              onTap: _showAbout,
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: roseLight.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: rose, size: 21),
                    const SizedBox(width: 14),
                    Text(
                      logoutTitle,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: rose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CHOOSE LANGUAGE
  // ===========================================================================

  void _chooseLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        final bool arabic = isArabic;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arabic ? 'اللغة' : 'Language',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 18),

              _languageOption(context: sheetContext, title: 'English'),

              const SizedBox(height: 10),

              _languageOption(context: sheetContext, title: 'العربية'),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // LANGUAGE OPTION
  // ===========================================================================

  Widget _languageOption({
    required BuildContext context,
    required String title,
  }) {
    final bool selected = language == title;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await widget.appLanguage.changeLanguage(title);

        if (!context.mounted) return;

        setState(() {
          language = title;
        });

        widget.onLanguageChanged?.call(title);

        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? roseLight : background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? rose.withValues(alpha: 0.3)
                : darkBrown.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: darkBrown,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: rose, size: 21),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ABOUT
  // ===========================================================================

  void _showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final bool arabic = isArabic;

        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            arabic ? 'عن Lostly' : 'About Lostly',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
          content: Text(
            arabic
                ? 'Lostly هو تطبيق للمفقودات والموجودات يساعد المستخدمين على الإبلاغ عن الأشياء المفقودة، واكتشاف الأشياء التي تم العثور عليها، وإعادة المفقودات إلى أصحابها.'
                : 'Lostly is a lost and found platform that helps people report missing belongings, discover found items, and reconnect them with their owners.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 13,
              height: 1.6,
              color: mutedBrown,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                arabic ? 'إغلاق' : 'Close',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                  color: rose,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // LOG OUT
  // ===========================================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final bool arabic = isArabic;

        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            arabic ? 'تسجيل الخروج' : 'Log Out',
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
          content: Text(
            arabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to log out?',
            style: const TextStyle(fontFamily: 'serif', color: mutedBrown),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                arabic ? 'إلغاء' : 'Cancel',
                style: const TextStyle(fontFamily: 'serif', color: mutedBrown),
              ),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final navigator = Navigator.of(context);

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginPage(appLanguage: widget.appLanguage),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                arabic ? 'تسجيل الخروج' : 'Log Out',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w700,
                  color: rose,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SETTINGS TILE
  // ===========================================================================

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: darkBrown.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: roseLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: rose, size: 21),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: darkBrown,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        color: mutedBrown,
                      ),
                    ),
                  ],
                ),
              ),

              if (trailing != null)
                trailing
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: mutedBrown,
                  size: 21,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

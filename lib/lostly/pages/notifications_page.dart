import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Possible match found',
      'arabicTitle': 'تم العثور على تطابق محتمل',
      'description': 'An item similar to your lost item was posted.',
      'arabicDescription': 'تم نشر غرض مشابه للغرض الذي فقدته.',
      'time': '10',
      'unit': 'min',
      'icon': Icons.search_rounded,
      'unread': true,
    },
    {
      'title': 'New message',
      'arabicTitle': 'رسالة جديدة',
      'description': 'Someone contacted you about an item.',
      'arabicDescription': 'تواصل معك شخص بخصوص غرض.',
      'time': '1',
      'unit': 'hour',
      'icon': Icons.chat_bubble_outline_rounded,
      'unread': true,
    },
    {
      'title': 'Post updated',
      'arabicTitle': 'تم تحديث المنشور',
      'description': 'Your post information was updated.',
      'arabicDescription': 'تم تحديث معلومات منشورك.',
      'time': '3',
      'unit': 'hour',
      'icon': Icons.inventory_2_outlined,
      'unread': false,
    },
  ];

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  bool get isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  // ===========================================================================
  // MARK ALL AS READ
  // ===========================================================================

  void _markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification['unread'] = false;
      }
    });
  }

  // ===========================================================================
  // MARK ONE AS READ
  // ===========================================================================

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['unread'] = false;
    });
  }

  // ===========================================================================
  // TIME
  // ===========================================================================

  String _timeText(Map<String, dynamic> notification) {
    final String time = notification['time'].toString();

    final String unit = notification['unit'].toString();

    if (!isArabic) {
      switch (unit) {
        case 'min':
          return '$time min ago';

        case 'hour':
          return time == '1' ? '1 hour ago' : '$time hours ago';

        default:
          return '$time ago';
      }
    }

    switch (unit) {
      case 'min':
        return 'منذ $time دقيقة';

      case 'hour':
        return 'منذ $time ساعة';

      default:
        return 'منذ $time';
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = notifications.any(
      (notification) => notification['unread'] == true,
    );

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

          child: Column(
            children: [
              // =================================================================
              // TOP BAR
              // =================================================================

              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // -----------------------------------------------------------
                    // TITLE
                    // -----------------------------------------------------------

                    Center(
                      child: Text(
                        isArabic ? 'الإشعارات' : 'Notifications',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                        ),
                      ),
                    ),

                    // -----------------------------------------------------------
                    // READ ALL
                    // -----------------------------------------------------------

                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: hasUnread ? _markAllAsRead : null,
                        child: Text(
                          isArabic ? 'قراءة الكل' : 'Read all',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hasUnread
                                ? rose
                                : mutedBrown.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),

                    // -----------------------------------------------------------
                    // BACK BUTTON
                    // -----------------------------------------------------------

                    Align(
                      alignment: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          isArabic
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          size: 25,
                          color: darkBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =================================================================
              // NOTIFICATIONS
              // =================================================================

              ...List.generate(notifications.length, (index) {
                final notification = notifications[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _notificationCard(notification, index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // NOTIFICATION CARD
  // ===========================================================================

  Widget _notificationCard(
    Map<String, dynamic> notification,
    int index,
  ) {
    final bool unread = notification['unread'] == true;

    final IconData icon = notification['icon'] as IconData;

    return GestureDetector(
      onTap: () {
        _markAsRead(index);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        width: double.infinity,

        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),

        decoration: BoxDecoration(
          color: unread ? roseLight.withValues(alpha: 0.65) : cardColor,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: darkBrown.withValues(alpha: 0.045),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ================================================================
            // UNREAD DOT
            // ================================================================

            Container(
              width: 7,
              height: 7,

              margin: const EdgeInsets.only(top: 8),

              decoration: BoxDecoration(
                color: unread ? rose : Colors.transparent,

                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 9),

            // ================================================================
            // TEXT
            // ================================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Text(
                    isArabic
                        ? notification['arabicTitle']
                        : notification['title'],

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    isArabic
                        ? notification['arabicDescription']
                        : notification['description'],

                    textAlign: TextAlign.center,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      height: 1.35,
                      color: mutedBrown,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _timeText(notification),

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 9,
                      color: Color(0xFFA69A94),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 9),

            // ================================================================
            // ICON
            // ================================================================

            Container(
              width: 43,
              height: 43,

              decoration: BoxDecoration(
                color: unread
                    ? roseLight
                    : const Color(0xFFFFF0E7),

                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(
                icon,
                size: 19,
                color: rose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
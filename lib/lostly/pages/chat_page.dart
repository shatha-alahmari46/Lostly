import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color rose = Color(0xFFB66568);
  static const Color roseLight = Color(0xFFF3DDE0);
  static const Color darkBrown = Color(0xFF3D2924);
  static const Color mutedBrown = Color(0xFF8F817B);
  static const Color background = Color(0xFFFFF1E4);
  static const Color cardColor = Color(0xFFFFFBF7);

  final TextEditingController _messageController =
      TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();

    _messages.add({
      'message':
          'Hi! I think I found your ${widget.item['name'] ?? 'item'}.',
      'isMe': true,
      'time': 'Now',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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

  // Times are stored as 'Now' and translated when displayed, so the
  // language can change without leaving English text behind.
  String _timeLabel(String time) {
    if (time == 'Now') {
      return isArabic ? 'الآن' : 'Now';
    }

    return time;
  }

  String _categoryName(String category) {
    if (!isArabic) {
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
      case 'Other':
        return 'أخرى';
      default:
        return category;
    }
  }

  String _initialMessage() {
    final name = widget.item['name'] ?? 'item';

    if (isArabic) {
      return 'مرحبًا! أعتقد أنني وجدت $name الخاص بك.';
    }

    return 'Hi! I think I found your $name.';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add({
        'message': text,
        'isMe': true,
        'time': 'Now',
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        widget.item['name']?.toString() ??
            (isArabic ? 'غرض غير معروف' : 'Unknown item');

    final String category =
        widget.item['category']?.toString() ?? 'Electronics';

    final String status =
        widget.item['status']?.toString() ?? 'Lost';

    final IconData icon =
        widget.item['icon'] is IconData
            ? widget.item['icon'] as IconData
            : Icons.headphones_rounded;

    final Color itemColor =
        widget.item['color'] is Color
            ? widget.item['color'] as Color
            : rose;

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // TOP BAR
            // ================================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                8,
              ),
              child: Row(
                children: [
                  // BACK BUTTON

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
                            alpha: 0.06,
                          ),
                        ),
                      ),
                      // arrow_back_rounded already flips in RTL.
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 21,
                        color: darkBrown,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // OWNER ICON

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: roseLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 21,
                      color: rose,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // OWNER INFO

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'مالك الغرض'
                              : 'Item Owner',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          isArabic
                              ? 'بخصوص $name'
                              : 'Regarding $name',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9.5,
                            color: mutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ================================================================
            // ITEM SUMMARY
            // ================================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                width: double.infinity,
                height: 68,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: darkBrown.withValues(
                      alpha: 0.055,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // STATUS

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            status.toLowerCase() ==
                                    'found'
                                ? const Color(
                                    0xFFE4EBDD,
                                  )
                                : roseLight,
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                      child: Text(
                        _statusName(status),
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              status.toLowerCase() ==
                                      'found'
                                  ? const Color(
                                      0xFF71876D,
                                    )
                                  : rose,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ITEM INFO

                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _categoryName(category),
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9,
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 9),

                    // ITEM ICON

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: roseLight,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: itemColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================================================================
            // MESSAGES
            // ================================================================

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  16,
                ),
                physics:
                    const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message =
                      _messages[index];

                  final bool isMe =
                      message['isMe'] == true;

                  return Align(
                    alignment: isMe
                        ? AlignmentDirectional
                            .centerEnd
                        : AlignmentDirectional
                            .centerStart,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 250,
                      ),
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      padding:
                          const EdgeInsets.fromLTRB(
                        13,
                        10,
                        13,
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? rose
                            : cardColor,
                        borderRadius:
                            BorderRadius.only(
                          topLeft:
                              const Radius.circular(
                            15,
                          ),
                          topRight:
                              const Radius.circular(
                            15,
                          ),
                          bottomLeft:
                              Radius.circular(
                            isMe ? 15 : 4,
                          ),
                          bottomRight:
                              Radius.circular(
                            isMe ? 4 : 15,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0
                                ? _initialMessage()
                                : message['message']
                                    .toString(),
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              height: 1.35,
                              color: isMe
                                  ? Colors.white
                                  : darkBrown,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            _timeLabel(
                              message['time'].toString(),
                            ),
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 8,
                              color: isMe
                                  ? Colors.white
                                      .withValues(
                                    alpha: 0.72,
                                  )
                                  : mutedBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================================================================
            // MESSAGE INPUT
            // ================================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                12,
              ),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(
                    color: darkBrown.withValues(
                      alpha: 0.045,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // SEND BUTTON

                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration:
                          const BoxDecoration(
                        color: rose,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 21,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // TEXT FIELD

                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: TextField(
                        controller:
                            _messageController,
                        textDirection:
                            isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        textAlign:
                            isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11.5,
                          color: darkBrown,
                        ),
                        decoration:
                            InputDecoration(
                          border:
                              InputBorder.none,
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          hintText: isArabic
                              ? 'اكتب رسالة...'
                              : 'Write a message...',
                          hintStyle:
                              const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11.5,
                            color: mutedBrown,
                          ),
                        ),
                        onSubmitted: (_) {
                          _sendMessage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
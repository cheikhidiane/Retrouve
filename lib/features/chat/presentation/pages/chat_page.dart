import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.conversationId});

  final String? conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  final _messages = <_Message>[
    _Message(
      id: '0',
      text: 'Match confirmé le 24 mai 2026',
      senderId: 'system',
      timestamp: DateTime(2026, 5, 24, 14, 0),
      isSystem: true,
    ),
    _Message(
      id: '1',
      text: 'Bonjour ! J\'ai bien trouvé votre iPhone 14 Pro. Il est en bon état.',
      senderId: 'other',
      timestamp: DateTime(2026, 5, 24, 14, 5),
    ),
    _Message(
      id: '2',
      text: 'Merci beaucoup ! Je le cherchais partout. Où pouvons-nous nous retrouver ?',
      senderId: 'me',
      timestamp: DateTime(2026, 5, 24, 14, 7),
    ),
    _Message(
      id: '3',
      text: 'Je suis disponible au Plateau demain matin vers 9h. Ça vous convient ?',
      senderId: 'other',
      timestamp: DateTime(2026, 5, 24, 14, 10),
    ),
    _Message(
      id: '4',
      text: 'Parfait, je serai là. Merci infiniment !',
      senderId: 'me',
      timestamp: DateTime(2026, 5, 24, 14, 12),
    ),
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(
        id: '${_messages.length}',
        text: text,
        senderId: 'me',
        timestamp: DateTime.now(),
      ));
      _messageCtrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildMatchBanner(),
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColor.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColor.dividerColor),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: AppColor.textSecondary, size: 16),
        ),
      ),
      title: Row(
        children: [
          AppAvatar(name: 'Fatou Seck', size: 36),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Fatou Seck', style: AppTextStyle.headlineSmall),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColor.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: AppColor.teal, size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            'Vérifié',
                            style: AppTextStyle.labelSmall
                                .copyWith(color: AppColor.teal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('En ligne',
                    style: AppTextStyle.labelSmall
                        .copyWith(color: AppColor.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColor.teal, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'iPhone 14 Pro noir — Match 87%',
              style: AppTextStyle.labelMedium.copyWith(color: AppColor.teal),
            ),
          ),
          Icon(Icons.chevron_right, color: AppColor.teal, size: 16.sp),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final showDate = i == 0 ||
            _messages[i - 1].timestamp.day != msg.timestamp.day;

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.timestamp),
            if (msg.isSystem)
              _SystemMessage(message: msg)
            else
              _BubbleMessage(message: msg),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColor.dividerColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              '${date.day}/${date.month}/${date.year}',
              style: AppTextStyle.labelSmall,
            ),
          ),
          Expanded(child: Divider(color: AppColor.dividerColor)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        border: Border(top: BorderSide(color: AppColor.dividerColor)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.background,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColor.dividerColor),
                ),
                child: TextField(
                  controller: _messageCtrl,
                  focusNode: _focusNode,
                  style: AppTextStyle.bodyMedium,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  cursorColor: AppColor.teal,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: AppTextStyle.bodyMedium
                        .copyWith(color: AppColor.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColor.teal,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded,
                    color: AppColor.background, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleMessage extends StatelessWidget {
  const _BubbleMessage({required this.message});
  final _Message message;

  bool get isMe => message.senderId == 'me';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            AppAvatar(name: 'Fatou Seck', size: 28),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  constraints: BoxConstraints(maxWidth: 0.7.sw),
                  decoration: BoxDecoration(
                    color: isMe ? AppColor.teal : AppColor.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                      bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: isMe ? AppColor.background : AppColor.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyle.labelSmall,
                ),
              ],
            ),
          ),
          if (isMe) SizedBox(width: 4.w),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColor.surfaceLight,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(message.text, style: AppTextStyle.labelSmall),
        ),
      ),
    );
  }
}

class _Message {
  const _Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.isSystem = false,
  });

  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isSystem;
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/chat/domain/repositories/chat_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/chat_message_entity.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.conversationId});

  /// This is actually the matchId (the confirmed match this thread belongs
  /// to), preserved as `conversationId` for backward-compat with the
  /// original route wiring.
  final String? conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  List<ChatMessageEntity> _messages = [];
  MatchEntity? _match;
  ItemEntity? _lostItem;
  String? _myUserId;
  bool _isSending = false;

  String get _matchId => widget.conversationId ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await getIt<AuthRepository>().getCurrentUser();
    final match = await getIt<MatchRepository>().getById(_matchId);
    final messages = await getIt<ChatRepository>().getMessages(_matchId);
    ItemEntity? lost;
    if (match != null) {
      lost = await getIt<ItemRepository>().getById(match.lostItemId);
    }
    if (!mounted) return;
    setState(() {
      _myUserId = me?.id;
      _match = match;
      _messages = messages;
      _lostItem = lost;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    final senderId = _myUserId;
    if (text.isEmpty || senderId == null || _isSending) return;

    setState(() => _isSending = true);
    _messageCtrl.clear();

    final message = await getIt<ChatRepository>().sendMessage(
      matchId: _matchId,
      senderId: senderId,
      text: text,
    );

    if (!mounted) return;
    setState(() {
      _messages = [..._messages, message];
      _isSending = false;
    });
    _scrollToBottom();
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
          const AppAvatar(name: 'Autre utilisateur', size: 36),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Autre utilisateur',
                        style: AppTextStyle.headlineSmall),
                    SizedBox(width: 6.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                    style:
                        AppTextStyle.labelSmall.copyWith(color: AppColor.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchBanner() {
    final title = _lostItem?.title ?? 'Objet';
    final score = _match?.score ?? 0;
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
              '$title — Match $score%',
              style: AppTextStyle.labelMedium.copyWith(color: AppColor.teal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Aucun message pour le moment.\nDites bonjour !',
          textAlign: TextAlign.center,
          style: AppTextStyle.bodySmall,
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final showDate =
            i == 0 || _messages[i - 1].createdAt.day != msg.createdAt.day;
        final isMe = msg.senderId == _myUserId;

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.createdAt),
            if (msg.isSystem)
              _SystemMessage(message: msg)
            else
              _BubbleMessage(message: msg, isMe: isMe),
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
      padding: EdgeInsets.fromLTRB(
          16.w, 10.h, 16.w, 10.h + MediaQuery.of(context).viewInsets.bottom),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                decoration: const BoxDecoration(
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
  const _BubbleMessage({required this.message, required this.isMe});

  final ChatMessageEntity message;
  final bool isMe;

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
            const AppAvatar(name: 'Autre utilisateur', size: 28),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${message.createdAt.minute.toString().padLeft(2, '0')}',
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
  final ChatMessageEntity message;

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

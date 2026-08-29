import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
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
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

/// Lists every confirmed match the current user is part of, with a
/// preview of the last chat message, and lets them re-open the
/// conversation — this is the only entry point back into `ChatPage` once
/// the user has navigated away from the "match confirmed" screen.
class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  List<_Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    DataRefreshBus.instance.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    DataRefreshBus.instance.version.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => _load();

  Future<void> _load() async {
    final me = await getIt<AuthRepository>().getCurrentUser();
    final allMatches = await getIt<MatchRepository>().getAll();
    final allItems = await getIt<ItemRepository>().getAll();
    final itemsById = {for (final i in allItems) i.id: i};

    final confirmed = allMatches
        .where((m) => m.status == MatchStatus.confirmed)
        .where((m) {
      if (me == null) return true;
      final lost = itemsById[m.lostItemId];
      final found = itemsById[m.foundItemId];
      return lost?.ownerId == me.id || found?.ownerId == me.id;
    }).toList();

    final conversations = <_Conversation>[];
    for (final match in confirmed) {
      final messages = await getIt<ChatRepository>().getMessages(match.id);
      final lost = itemsById[match.lostItemId];
      final last = messages.isEmpty ? null : messages.last;
      conversations.add(
        _Conversation(match: match, item: lost, lastMessage: last),
      );
    }
    conversations.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ??
          a.match.confirmedAt ??
          a.match.createdAt;
      final bTime = b.lastMessage?.createdAt ??
          b.match.confirmedAt ??
          b.match.createdAt;
      return bTime.compareTo(aTime);
    });

    if (!mounted) return;
    setState(() {
      _conversations = conversations;
      _isLoading = false;
    });
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 2) return 'Hier';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        title: Text('Messages', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.teal))
          : _conversations.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      'Aucune conversation pour le moment.\nElles '
                      'apparaîtront ici dès qu\'un match sera confirmé.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium
                          .copyWith(color: AppColor.textSecondary),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColor.teal,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      final convo = _conversations[i];
                      final title = convo.item?.title ?? 'Objet';
                      final preview = convo.lastMessage?.text ??
                          'Aucun message pour le moment';
                      final time = convo.lastMessage != null
                          ? _relativeTime(convo.lastMessage!.createdAt)
                          : _relativeTime(
                              convo.match.confirmedAt ?? convo.match.createdAt);

                      return GestureDetector(
                        onTap: () => context.pushNamed(
                          'messages-chat',
                          pathParameters: {'id': convo.match.id},
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppColor.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const AppAvatar(name: 'Autre utilisateur', size: 46),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: AppTextStyle.headlineSmall),
                                    SizedBox(height: 4.h),
                                    Text(
                                      preview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(time, style: AppTextStyle.labelSmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.match,
    required this.item,
    required this.lastMessage,
  });

  final MatchEntity match;
  final ItemEntity? item;
  final ChatMessageEntity? lastMessage;
}

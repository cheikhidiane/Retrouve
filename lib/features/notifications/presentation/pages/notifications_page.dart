import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/notifications/domain/repositories/notification_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/notification_entity.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationEntity> _notifications = [];
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
    final all = await getIt<NotificationRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _notifications = all;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    await getIt<NotificationRepository>().markAllRead();
    await _load();
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 2) return 'Hier';
    return '${date.day}/${date.month}';
  }

  ({IconData icon, Color color}) _visualFor(NotificationType type) {
    switch (type) {
      case NotificationType.newMatch:
        return (icon: Icons.compare_arrows, color: AppColor.teal);
      case NotificationType.matchConfirmed:
        return (icon: Icons.shield_outlined, color: AppColor.appSuccess);
      case NotificationType.newMessage:
        return (icon: Icons.chat_bubble_outline, color: AppColor.blue);
      case NotificationType.itemRecovered:
        return (icon: Icons.check_circle_outline, color: AppColor.appSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColor.dividerColor),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColor.textSecondary, size: 16),
          ),
        ),
        title: Text('Notifications', style: AppTextStyle.headlineSmall),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: _markAllRead,
              child: Center(
                child: Text(
                  'Tout lire',
                  style:
                      AppTextStyle.labelMedium.copyWith(color: AppColor.teal),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    'Aucune notification pour le moment.',
                    style: AppTextStyle.bodySmall,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) {
                      final notif = _notifications[i];
                      final visual = _visualFor(notif.type);
                      return _NotifCard(
                        icon: visual.icon,
                        color: visual.color,
                        title: notif.title,
                        body: notif.body,
                        time: _relativeTime(notif.createdAt),
                        isUnread: !notif.isRead,
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isUnread ? AppColor.teal.withOpacity(0.05) : AppColor.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isUnread
              ? AppColor.teal.withOpacity(0.2)
              : AppColor.dividerColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: AppTextStyle.headlineSmall),
                    ),
                    if (isUnread)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.teal,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(body, style: AppTextStyle.bodySmall.copyWith(height: 1.4)),
                SizedBox(height: 6.h),
                Text(time, style: AppTextStyle.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

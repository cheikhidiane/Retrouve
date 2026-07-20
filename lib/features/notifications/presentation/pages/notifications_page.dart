import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static final _mockNotifs = [
    _Notif(
      icon: Icons.compare_arrows,
      color: AppColor.teal,
      title: 'Nouveau match trouvé !',
      body: 'Votre iPhone 14 correspond à une annonce.',
      time: 'Il y a 5 min',
      isUnread: true,
    ),
    _Notif(
      icon: Icons.shield_outlined,
      color: AppColor.appWarning,
      title: 'Vérification en attente',
      body: 'Répondez à la question secrète pour confirmer.',
      time: 'Il y a 2h',
      isUnread: true,
    ),
    _Notif(
      icon: Icons.check_circle_outline,
      color: AppColor.appSuccess,
      title: 'Objet récupéré',
      body: 'Votre portefeuille a été récupéré avec succès.',
      time: 'Hier',
      isUnread: false,
    ),
    _Notif(
      icon: Icons.search,
      color: AppColor.blue,
      title: 'Nouvelle annonce proche',
      body: 'Un objet trouvé correspond à votre zone.',
      time: '23 mai',
      isUnread: false,
    ),
  ];

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
            child: Center(
              child: Text(
                'Tout lire',
                style: AppTextStyle.labelMedium
                    .copyWith(color: AppColor.teal),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        itemCount: _mockNotifs.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (_, i) => _NotifCard(notif: _mockNotifs[i]),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.notif});
  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: notif.isUnread
            ? AppColor.teal.withOpacity(0.05)
            : AppColor.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: notif.isUnread
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
              color: notif.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(notif.icon, color: notif.color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notif.title,
                          style: AppTextStyle.headlineSmall),
                    ),
                    if (notif.isUnread)
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
                Text(notif.body,
                    style: AppTextStyle.bodySmall.copyWith(height: 1.4)),
                SizedBox(height: 6.h),
                Text(notif.time, style: AppTextStyle.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notif {
  const _Notif({
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
}

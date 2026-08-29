import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/cards/app_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _activeCount = 0;
  int _matchingRate = 0;
  int _recoveredCount = 0;
  List<_ResolutionItem> _resolutions = [];
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
    final items = await getIt<ItemRepository>().getAll();
    final matches = await getIt<MatchRepository>().getAll();

    final itemsById = {for (final i in items) i.id: i};
    final confirmed = matches
        .where((m) => m.status == MatchStatus.confirmed)
        .toList()
      ..sort((a, b) => (b.confirmedAt ?? b.createdAt)
          .compareTo(a.confirmedAt ?? a.createdAt));

    final active = items.where((i) => !i.isMatched).length;
    final matchingRate =
        items.isEmpty ? 0 : ((matches.length / items.length) * 100).round();

    final resolutions = confirmed.take(5).map((m) {
      final lost = itemsById[m.lostItemId];
      final found = itemsById[m.foundItemId];
      final route = lost != null && found != null
          ? '${lost.location} → ${found.location}'
          : '';
      return _ResolutionItem(
        lost?.title ?? 'Objet',
        route,
        '${m.score}%',
        _relativeTime(m.confirmedAt ?? m.createdAt),
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _activeCount = active;
      _matchingRate = matchingRate;
      _recoveredCount = confirmed.length;
      _resolutions = resolutions;
      _isLoading = false;
    });
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
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
        title: Text('Retrouvé — Dashboard', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildKpiRow(),
                    SizedBox(height: 24.h),
                    Text('Activité (7 derniers jours)',
                        style: AppTextStyle.headlineSmall),
                    SizedBox(height: 16.h),
                    _buildActivityChart(),
                    SizedBox(height: 24.h),
                    Text('Objets récupérés', style: AppTextStyle.headlineSmall),
                    SizedBox(height: 16.h),
                    _resolutions.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Text(
                              'Aucun objet récupéré pour le moment.',
                              style: AppTextStyle.bodySmall,
                            ),
                          )
                        : _buildRecentResolutions(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            value: '$_activeCount',
            label: 'Annonces\nactives',
            color: AppColor.teal,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _KpiCard(
            value: '$_matchingRate%',
            label: 'Taux de\nmatching',
            color: AppColor.appWarning,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _KpiCard(
            value: '$_recoveredCount',
            label: 'Objets\nrécupérés',
            color: AppColor.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart() {
    final data = [0.3, 0.5, 0.4, 0.8, 0.6, 0.9, 0.7];
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return AppCard(
      child: Column(
        children: [
          SizedBox(
            height: 120.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + i * 50),
                          height: data[i] * 100.h,
                          decoration: BoxDecoration(
                            gradient: i == 5
                                ? AppColor.tealGradient
                                : LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColor.teal.withOpacity(0.4),
                                      AppColor.teal.withOpacity(0.1),
                                    ],
                                  ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(6.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(days[i], style: AppTextStyle.labelSmall),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResolutions() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(_resolutions.length, (i) {
          final item = _resolutions[i];
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColor.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.check_circle_outline,
                          color: AppColor.teal, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTextStyle.headlineSmall),
                          Text(item.route, style: AppTextStyle.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColor.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(item.score,
                              style: AppTextStyle.labelSmall.copyWith(
                                  color: AppColor.teal,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 2.h),
                        Text(item.time, style: AppTextStyle.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < _resolutions.length - 1)
                Divider(color: AppColor.dividerColor, height: 1, indent: 68.w),
            ],
          );
        }),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyle.displayMedium.copyWith(
              color: color,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(label, style: AppTextStyle.labelSmall.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _ResolutionItem {
  const _ResolutionItem(this.title, this.route, this.score, this.time);

  final String title;
  final String route;
  final String score;
  final String time;
}

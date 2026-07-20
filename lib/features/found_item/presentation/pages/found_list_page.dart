import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/cards/item_card.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/category_chip.dart';

class FoundListPage extends StatefulWidget {
  const FoundListPage({super.key});

  @override
  State<FoundListPage> createState() => _FoundListPageState();
}

class _FoundListPageState extends State<FoundListPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  static const _categories = [
    'Tout',
    'Téléphone',
    'Portefeuille',
    'Clés',
    'Sac',
    'Bijou',
    'Document',
  ];

  static final _mockItems = [
    _MockFoundItem(
      title: 'iPhone 14 Pro noir',
      category: 'Téléphone',
      location: 'Plateau, Dakar',
      date: 'Hier, 14h30',
      matchScore: 87,
    ),
    _MockFoundItem(
      title: 'Portefeuille en cuir brun',
      category: 'Portefeuille',
      location: 'Almadies, Dakar',
      date: '23 mai 2026',
      matchScore: 72,
    ),
    _MockFoundItem(
      title: 'Clés Toyota Corolla',
      category: 'Clés',
      location: 'Mermoz, Dakar',
      date: '22 mai 2026',
      matchScore: 45,
    ),
    _MockFoundItem(
      title: 'Sac à dos Nike bleu',
      category: 'Sac',
      location: 'Université Dakar',
      date: '21 mai 2026',
      matchScore: null,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        title: Text('Objets trouvés', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AppTextField(
              controller: _searchCtrl,
              hint: 'Rechercher un objet...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return CategoryChip(
                  label: cat,
                  isSelected: _selectedCategory == cat ||
                      (cat == 'Tout' && _selectedCategory == null),
                  onTap: () => setState(
                    () => _selectedCategory = cat == 'Tout' ? null : cat,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              itemCount: _mockItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final item = _mockItems[i];
                return ItemCard(
                  title: item.title,
                  category: item.category,
                  location: item.location,
                  date: item.date,
                  type: ItemType.found,
                  matchScore: item.matchScore,
                  onTap: () => context.pushNamed(
                    'match-potential',
                    pathParameters: {'id': '$i'},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockFoundItem {
  const _MockFoundItem({
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    this.matchScore,
  });

  final String title;
  final String category;
  final String location;
  final String date;
  final int? matchScore;
}

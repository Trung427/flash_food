import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/assets_constantes.dart';
import 'package:flash_food/Core/font_size.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flash_food/Presentation/Auth/screens/default_field.dart';
import 'package:flash_food/Presentation/Base/base.dart';
import 'package:flash_food/Presentation/Foods/screens/recent_search_item.dart';
import 'package:flash_food/Presentation/Models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flash_food/Presentation/Base/provider/food_provider.dart';
import 'package:flash_food/Core/Routes/routes_name.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  String keyword = '';
  int selectedCategoryIndex = -1; // -1 là tất cả

  String get selectedCategoryName =>
      selectedCategoryIndex == -1 ? '' : categories[selectedCategoryIndex].designation;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    List foods = foodProvider.searchFoods(keyword);
    // Lọc theo loại nếu có chọn
    if (selectedCategoryIndex != -1) {
      final cate = categories[selectedCategoryIndex].designation.toLowerCase();
      foods = foods.where((f) => f.category.toLowerCase() == cate).toList();
    }
    return Scaffold(
      appBar: buildAppBar(buildContext: context, screenTitle: "Tìm kiếm"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              // Thanh chọn loại (không có mục Tất cả)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final isSelected = selectedCategoryIndex == idx;
                    final borderColor = Pallete.orangePrimary;
                    final category = categories[idx];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedCategoryIndex == idx) {
                            selectedCategoryIndex = -1; // Bỏ chọn, về tất cả
                          } else {
                            selectedCategoryIndex = idx;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Pallete.orangePrimary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                          boxShadow: isSelected
                              ? [BoxShadow(color: borderColor.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2))]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Image.asset(category.link, width: 22, height: 22),
                            const SizedBox(width: 6),
                            Text(
                              category.designation,
                              style: TextStyle(
                                color: isSelected ? Colors.white : borderColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                  });
                },
              ),
              const Gap(24),
              // Hiển thị danh sách món nếu: (1) đã nhập từ khóa, hoặc (2) đã chọn một mục loại
              if (keyword.isNotEmpty || selectedCategoryIndex != -1) ...[
                if (foodProvider.isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!foodProvider.isLoading && foods.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Không tìm thấy món ăn phù hợp.', style: TextStyle(color: Colors.grey)),
                  ),
                if (!foodProvider.isLoading && foods.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foods.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      final cate = categories.firstWhere(
                        (c) => c.designation.toLowerCase() == food.category.toLowerCase(),
                        orElse: () => categories[0],
                      );
                      return ListTile(
                        leading: Image.asset(
                          cate.link,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(food.name),
                        subtitle: Text('${food.price.toInt()} VND'),
                        onTap: () {
                          Navigator.pushNamed(context, RoutesName.aboutMenu, arguments: food);
                        },
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

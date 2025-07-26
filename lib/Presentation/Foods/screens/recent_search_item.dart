import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/font_size.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flash_food/Core/assets_constantes.dart';

class RecentSearchItem extends StatelessWidget {
  final String category;
  const RecentSearchItem({Key? key, this.category = 'burger'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: getHeight(16)),
      child: SizedBox(
        height: getHeight(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  null,
                  size: getSize(20),
                  color: Pallete.neutral60,
                  // Sẽ thay bằng Image.asset bên dưới
                ),
                Image.asset(
                  _getFoodIcon(category),
                  width: getSize(20),
                  height: getSize(20),
                  fit: BoxFit.contain,
                ),
                const Gap(12),
                Text('Burger',
                    style: TextStyles.bodyLargeRegular
                        .copyWith(color: Pallete.neutral100, fontSize: getFontSize(FontSizes.large))),
              ],
            ),
            Icon(
              Icons.close,
              size: getSize(20),
              color: Pallete.neutral60,
            )
          ],
        ),
      ),
    );
  }
}

String _getFoodIcon(String category) {
  switch (category.toLowerCase()) {
    case 'burger':
      return AssetsConstants.burger;
    case 'pizza':
      return AssetsConstants.pizza;
    case 'drink':
      return AssetsConstants.drink;
    case 'taco':
      return AssetsConstants.taco;
    default:
      return AssetsConstants.ordinaryBurger;
  }
}

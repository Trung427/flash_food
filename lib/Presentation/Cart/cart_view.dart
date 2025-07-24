import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/font_size.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flash_food/Presentation/Auth/screens/default_button.dart';
import 'package:flash_food/Presentation/Base/base.dart';
import 'package:flash_food/Presentation/Base/food_item.dart';
import 'package:flash_food/Presentation/Cart/screens/cart_item_food.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flash_food/Presentation/Base/models/food_model.dart';
import 'package:flash_food/Core/assets_constantes.dart';
import 'package:provider/provider.dart';
import '../Base/provider/cart_provider.dart';
import 'package:intl/intl.dart';
import '../Base/services/order_service.dart';
import '../Auth/provider/auth_provider.dart';
import '../Foods/Views/payment_view.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final total = cart.totalPrice.toInt();
        return Scaffold(
          appBar: buildAppBar(buildContext: context, screenTitle: "Giỏ hàng của tôi", isBackup: false),
          body: Column(
            children: [
              if (cart.error != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cart.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => cart.clearError(),
                      ),
                    ],
                  ),
                ),
              
              if (cart.isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              Expanded(
                child: cart.items.isEmpty && !cart.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có món nào trong giỏ hàng', 
                              style: TextStyle(fontSize: 18, color: Colors.grey[600])
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: item.food.images.isNotEmpty
                                        ? Image.asset(item.food.images[0], width: 56, height: 56, fit: BoxFit.cover)
                                        : Container(width: 56, height: 56, color: Colors.grey[200]),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.food.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 4),
                                        Text(formatCurrency(item.food.price.toInt()), style: TextStyle(color: Colors.orange, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline, color: Colors.orange),
                                        onPressed: cart.isLoading ? null : () {
                                          if (item.quantity > 1) {
                                            cart.updateQuantity(item.food, item.quantity - 1);
                                          }
                                        },
                                      ),
                                      Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, color: Colors.orange),
                                        onPressed: cart.isLoading ? null : () {
                                          cart.updateQuantity(item.food, item.quantity + 1);
                                        },
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: cart.isLoading ? null : () {
                                      cart.removeFromCart(item.food);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(formatCurrency(total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          readNumber(total),
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: (cart.items.isEmpty || cart.isLoading)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentView(cartItems: cart.items, total: total),
                              ),
                            );
                          },
                    child: Text('Đặt hàng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)} VND";
  }

  String readNumber(int number) {
    if (number == 0) return 'không đồng';

    final units = [
      '',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín'
    ];
    final teens = [
      'mười',
      'mười một',
      'mười hai',
      'mười ba',
      'mười bốn',
      'mười lăm',
      'mười sáu',
      'mười bảy',
      'mười tám',
      'mười chín'
    ];
    final tens = [
      '',
      '',
      'hai mươi',
      'ba mươi',
      'bốn mươi',
      'năm mươi',
      'sáu mươi',
      'bảy mươi',
      'tám mươi',
      'chín mươi'
    ];
    final thousands = [
      '',
      'nghìn',
      'triệu',
      'tỷ',
      'nghìn tỷ',
      'triệu tỷ',
      'tỷ tỷ'
    ];

    String convertLessThanOneThousand(int n) {
      String str = '';
      int hundred = n ~/ 100;
      int ten = (n % 100) ~/ 10;
      int unit = n % 10;

      if (hundred > 0) {
        str += '${units[hundred]} trăm';
        if (ten == 0 && unit > 0) str += ' linh';
      }
      if (ten > 1) {
        str += ' ${tens[ten]}';
        if (unit > 0) str += ' ${units[unit]}';
      } else if (ten == 1) {
        str += ' ${teens[unit]}';
      } else if (unit > 0) {
        str += ' ${units[unit]}';
      }
      return str.trim();
    }

    if (number == 0) return 'không đồng';

    int i = 0;
    String words = '';
    while (number > 0) {
      int n = number % 1000;
      if (n != 0) {
        String prefix = convertLessThanOneThousand(n);
        if (i > 0) prefix += ' ${thousands[i]}';
        words = '$prefix $words';
      }
      number ~/= 1000;
      i++;
    }
    words = words.trim();
    words = words[0].toUpperCase() + words.substring(1);
    return '$words đồng';
  }
}

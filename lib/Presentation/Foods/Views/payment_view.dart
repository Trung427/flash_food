import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/assets_constantes.dart';
import 'package:flash_food/Core/font_size.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flash_food/Presentation/Auth/screens/default_button.dart';
import 'package:flash_food/Presentation/Base/base.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../Base/provider/cart_provider.dart';
import '../../Base/services/order_service.dart';
import '../../Auth/provider/auth_provider.dart';
import 'package:flash_food/Presentation/Models/category_model.dart';
// import 'package:qr_flutter/qr_flutter.dart'; // Tạm thời comment để tránh lỗi

class PaymentView extends StatefulWidget {
  final List cartItems;
  final int total;
  const PaymentView({Key? key, required this.cartItems, required this.total}) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xác nhận đơn hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Danh sách món đã chọn:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.cartItems.map<Widget>((item) => ListTile(
              leading: Image.asset(
                categories.firstWhere(
                  (c) => c.designation.toLowerCase() == item.food.category.toLowerCase(),
                  orElse: () => categories[0],
                ).link,
                width: 40,
                height: 40,
              ),
              title: Text(item.food.name),
              subtitle: Text('${item.food.price.toInt()} VND x${item.quantity}'),
              trailing: Text('${(item.food.price * item.quantity).toInt()} VND'),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.total} VND', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            SizedBox(height: 24),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Địa chỉ giao hàng'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Ghi chú'),
            ),
            SizedBox(height: 12),
            Text('Phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              value: 'cod',
              groupValue: _selectedPaymentMethod,
              onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              title: Text('Thanh toán khi nhận hàng'),
            ),
            RadioListTile<String>(
              value: 'qr',
              groupValue: _selectedPaymentMethod,
              onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              title: Text('Mã QR'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_selectedPaymentMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng chọn phương thức thanh toán!'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final baseUrl = 'http://10.0.2.2:3000'; // Hoặc lấy từ config
                final orderService = OrderService(baseUrl: baseUrl, token: authProvider.token!);
                if (_selectedPaymentMethod == 'qr') {
                  // Tạm thời tắt chức năng QR code
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chức năng thanh toán QR đang bảo trì!'), backgroundColor: Colors.orange),
                  );
                  return;
                  // showDialog(
                  //   context: context,
                  //   barrierDismissible: false,
                  //   builder: (context) {
                  //     Future.delayed(Duration(seconds: 10), () {
                  //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  //     });
                  //     return AlertDialog(
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  //       title: Text('Quét mã QR để thanh toán'),
                  //       content: Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           QrImage(
                  //             data: 'Ngân hàng: MB Bank\nTên: NGUYEN VAN A\nSTK: 0123456789',
                  //             version: QrVersions.auto,
                  //             size: 200.0,
                  //           ),
                  //           SizedBox(height: 16),
                  //           Text('Vui lòng quét mã QR bằng app ngân hàng để thanh toán.\n(Quét giả lập, tự động xác nhận sau 10 giây)',
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  //           ),
                  //           SizedBox(height: 8),
                  //           CircularProgressIndicator(),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ).then((_) async {
                  //   // Sau khi đóng dialog (sau 10s), tiến hành tạo đơn hàng
                  //   try {
                  //     await orderService.createOrder(
                  //       List.from(widget.cartItems),
                  //       address: _addressController.text,
                  //       note: _noteController.text,
                  //       paymentMethod: _selectedPaymentMethod!,
                  //     );
                  //     await cartProvider.clearCart();
                  //     if (mounted) {
                  //       Navigator.popUntil(context, (route) => route.isFirst);
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('Đặt hàng thành công! Xem đơn hàng tại mục Hồ sơ.'),),
                  //       );
                  //     }
                  //   } catch (e) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Lỗi khi đặt hàng: $e'), backgroundColor: Colors.red),
                  //     );
                  //   }
                  // });
                } else {
                  // Thanh toán khi nhận hàng
                  try {
                    await orderService.createOrder(
                      List.from(widget.cartItems),
                      address: _addressController.text,
                      note: _noteController.text,
                      paymentMethod: _selectedPaymentMethod!,
                    );
                    await cartProvider.clearCart();
                    if (mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đặt hàng thành công! Xem đơn hàng tại mục Hồ sơ.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi đặt hàng: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text('Xác nhận đặt hàng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
